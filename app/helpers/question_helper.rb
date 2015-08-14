module QuestionHelper
	require 'htmlentities'
	CODER = HTMLEntities.new

	# create_title
	# create the html for question number, title, type
	def create_title qnum, question, qtype=nil
		return "<strong>#{qnum}. #{question}</strong><br/>"
	end

	# ---------------------------------------------------------------------------------- #
	# build_multi_choice                           
	# 
	# Given question and question field information, create the question as an html string
	# that may be passed back to the view for rendering.
	#
	# This function is used for radio buttons and check boxes
	# @params question   the hash holding information for the question we need to create
	# @params model      the name of the model, such as design_detail, baseline_characteristic, etc.
	# @params category  used when questions are entered by arm or by outcome, and is appended to the names and ids of fields
	# ---------------------------------------------------------------------------------- #
	def build_multi_choice question, model, category = nil
		# get the extension to add for any category present
		cat_ext = category.nil? ? '' : "-#{category.id}"

		question[:q_type] = 'radio' if question[:q_type] == 'yesno'  # get rid of the pesky
		str = ""
		
		# for each field in the question, create the input and subquestion if applicable
		question[:fields].each do |field|
			#checked = field[:f_checked].present? ? 'checked' : ''
			checked, subq_val = get_answer(field, category, 'multi-choice')

			checkbox_array = question[:q_type] == 'checkbox' ? '[]' : ''
			str += "<input type='#{question[:q_type]}' class='cbox question_#{question[:q_type]}_input editable_field' section_name='#{model}' option_id=#{field[:f_id]} "\
					"obj_id='#{question[:q_id]}' name='#{model}[#{question[:q_id]}#{cat_ext}]#{checkbox_array}' group_id='#{category.nil? ? '' : category.id}' value='#{CODER.encode(field[:f_text].to_s.gsub('"','\"'))}' "\
					" id='#{model}_#{question[:q_id]}#{cat_ext}' #{checked}/><label>#{field[:f_text]}</label>"
			if field[:f_has_subq] == true
				disabled = 'disabled'
				if category.nil?
					disabled = '' if field[:f_checked].present?
				else
					if field[category.id].present?
						disabled = '' if field[category.id][:f_checked].present?
					end
				end
				str += "...<span class='#{question[:q_type]}_group_#{question[:q_id]}#{cat_ext.gsub('-','_')} editable_field' id='option_#{field[:f_id]}#{cat_ext.gsub('-','_')}_sq_span'>"
				#disabled = field[:f_checked].present? ? '' : 'disabled'

				checkbox_field_indicator = question[:q_type] == 'checkbox' ? "[#{field[:f_id]}]" : ""
				str += create_subquestion(question[:q_id], model, field[:f_subq], subq_val, disabled, cat_ext, checkbox_field_indicator)
				str += "</span>"
			end			
			str += "<br/>"
		end
		# if this is a radio question, give the user the option to clear all previously selected elements
		if question[:q_type] == 'radio'
			str += "<br/><a href='#' class='clear_selection_link' question_name='#{@data[:model]}[#{question[:q_id]}#{cat_ext}]' "\
				   ">Clear Selections</a><br/>"
		end

		return str
	end

	# ---------------------------------------------------------------------------------- #
	# build_dropdown                         
	# 
	# Given question and question field information, create the dropdown box as an html string
	# that may be passed back to the view for rendering.
	#
	# This function is used for select boxes (dropdowns)
	# ---------------------------------------------------------------------------------- #
	def build_dropdown question, model, category = nil
		# get the extension to add for any category present
		cat_ext = category.nil? ? '' : "-#{category.id}"

		# for each field in the question, create the input and subquestion if applicable
		str = "<select class='question_select_input editable_field' title='Make Your Selection' "\
				"section_name='#{model}' obj_id='#{question[:q_id]}' group_id='#{category.nil? ? '' : category.id}' "\
				" name='#{model}[#{question[:q_id]}#{cat_ext}]' id='#{model}_#{question[:q_id]}#{cat_ext}'>"

		str += "<option value=''>-- Make Your Selection --</option>"
		field_selected = nil
		still_no_answer = true
		subq_val = ''
		question[:fields].each do |field|
			#selected = ''
			selected, tmp = get_answer(field,category,'dropdown')
			#if field[:f_checked].present?
			if selected == 'SELECTED'
				field_selected = field
				still_no_answer = false
				subq_val = tmp
			end

			str += "<option meta='#{field[:checked]}' value='#{CODER.encode(field[:f_text].to_s.gsub('"','\"'))}' #{selected}>"\
				   "#{field[:f_text]}#{'...' if field[:f_has_subq] == true}</option>"
		end
		str += "</select> &nbsp; <span id='select_#{question[:q_id]}#{cat_ext.gsub("-","_")}_sq_span'>"
		unless field_selected.nil?
			if field_selected[:f_has_subq]
				str += create_subquestion(question[:q_id], model, field_selected[:f_subq], subq_val, '', cat_ext)
			end
		end
		str += "</span><br/>"
		return str
	end

	# ---------------------------------------------------------------------------------- #
	# build_matrix
	#
	# Given the question and field information, build a matrix question as an html string
	# that may be rendered in the view.
	# ---------------------------------------------------------------------------------- #
	def build_matrix question, model, category=nil
		# get the extension to add for any category present
		cat_ext = category.nil? ? '' : "-#{category.id}"

		columns = question[:fields][:columns]
		rows = question[:fields][:rows]
		# start the matrix table
		str = "<table class='matrix_question editable_field' id='question_#{question[:q_id]}_matrix'><tr><td></td>"

		# add column headers
		columns.each do |col|
			str += "<td class='title'><center>#{col[:c_text]}</center></td>"
		end
		str += "</tr><tr>"

		# for each row
		iter = 0
		other_row = nil

		rows.each do |row|
			
			if row[:r_rnum] == -1  # if it's the other option, wait until the end.
				other_row = row
				next
			end

			# add the row title
			str += "<tr class='#{cycle('odd','even')}'><td class='title' align='left'>#{row[:r_text]}</td>"
			for iter in 0..columns.length - 1
				if ['matrix_radio','matrix_checkbox'].include?(question[:q_type])
					str += "<td>#{generate_matrix_input(question[:q_type], row, columns[iter][:c_text], model, question[:q_id], category)}</td>"
				
				elsif question[:q_type] == 'matrix_select'
					str += "<td>#{generate_matrix_dropdown_input(question[:q_type], row, columns[iter], model, question[:q_id], question[:q_has_matrix_other], category)}</td>"

				else
					str += "<td>-- err --</td>"
				end
			end
			str += "</tr>"

		end
		unless other_row.nil?
			value = ''
			if other_row[:r_answers].present?
				if category.nil?
					value = other_row[:r_answers].first
				else
					value = other_row[:r_answers][category.id].first if other_row[:r_answers][category.id].present?
				end
			end
			#other_row[:r_answers].present? ? (other_row[:r_answers].empty? ? '' : other_row[:r_answers].first) : ''
			str += add_other_matrix_box(other_row[:r_id],model, question[:q_id], columns.length, value, cat_ext)
		end

		# if they are using radio buttons, give the user the ability to clear previously saved answers
		if question[:q_type] == 'matrix_radio'
			group_names = "#{model}[#{question[:q_id]}_#{rows.first[:r_id]}#{cat_ext}]"
			for i in 1 .. rows.length - 1
				group_names += ",#{model}[#{question[:q_id]}_#{rows[i][:r_id]}#{cat_ext}]"
			end
			str += "<tr><td colspan=#{columns.length}><a href='#' class='clear_selection_link' "\
				   "question_name='#{group_names}'>Clear Selections</a></td></tr>"
		end
		str += "</table>"
		return str
	end

	# ---------------------------------------------------------------------------------- #
	# build_text

	# Given a simple text entry question, build an html string to represent the question
	# in the view
	# ---------------------------------------------------------------------------------- #
	def build_text question, model, num_cols, category=nil
		# get the extension to add for any category present
		cat_ext = category.nil? ? '' : "-#{category.id}"
		answer, subq = get_answer(question, category, 'text')
		str = "<textarea cols=#{num_cols} rows=1 class='editable_field' id='#{model}_#{question[:q_id]}#{cat_ext}' "\
				"name='#{model}[#{question[:q_id]}#{cat_ext}]'>#{answer}</textarea><br/>"
		return str
	end

	# ---------------------------------------------------------------------------------- #
	# build_multi_text

	# Given multiple text entry question, build an html string to represent the question
	# in the view
	# ---------------------------------------------------------------------------------- #
	def build_multi_text(question, model, category=nil)
	end

	# ---------------------------------------------------------------------------------- #
	# accessory
	#
	# a few accessory functions to assist in creating the questions
	# ---------------------------------------------------------------------------------- #
	private
	
	# def get_answer
	# given a field or a question object and the type of question, figure out the 
	# answer based on the category
	# @params element         either a question or field entry from the get_questions model
	# @params category        a category object, either outcome or arm or nil
	# @params type            'multi-choice', 'text', 'matrix', 'matrix-dropdown'
	# @params options         a hash containing parameters specific to matrix questions
	def get_answer(element, category, type, matrix_data={})
		col_text = matrix_data['col_text'] ||= nil      # the matrix column text
		row_id = matrix_data['row_id'] ||= nil			# the matrix row id
		answer = ''                                     # the question answer (can be CHECKED, SELECTED, or the value)
		subq_val = ''									# subquestion value (for radio, checkboxes or dropdowns only)

		# multi-choice, such as radio or checkboxes or dropdown
		if ['multi-choice','dropdown'].include?(type)
			if category.nil?
				if element[:f_checked].present?
					answer = type == 'multi-choice' ? 'checked' : 'SELECTED'
					subq_val = element[:f_subq_val] if element[:f_subq_val].present?
				end
			else
				if element[category.id].present?
					if element[category.id][:f_checked].present?
						answer = type == 'multi-choice' ? 'checked' : 'SELECTED'
						subq_val = element[category.id][:f_subq_val] if element[category.id][:f_subq_val].present?
					end
				end
			end
		# text boxes
		elsif type == 'text'
			if category.nil?
				answer = element[:q_answer]
			else
				if element[:q_answers][category.id].present?
					answer = element[:q_answers][category.id]
				end
			end
		# matrix (dropdown, radio, checkbox, text)
		elsif type == 'matrix'
			#puts "Checking for Matrix...\n"
			if element[:r_answers].present?
				#puts "Found r_answers...\n"
				if category.nil?
					answer = 'CHECKED' if element[:r_answers].include?(col_text)
					#puts "Category is nil and answer is #{answer}.\n"
				else
					# if it's a matrix, only the id of the category is passed in and not the entire object
					if element[:r_answers][category.id].present?
						answer = 'CHECKED' if element[:r_answers][category.id].include?(col_text)
					end
					#puts "Category is NOT nil and answer is #{answer}\n\n"
				end
			end
		elsif type == 'matrix-dropdown'
			if element[:c_answers].present?
				if category.nil?
					answer = element[:c_answers][row_id] if element[:c_answers][row_id].present?
				else
					if element[:c_answers][row_id].present?
						answer = element[:c_answers][row_id][category.id] if element[:c_answers][row_id][category.id].present?
					end
				end
			end
		end
		return answer, subq_val
	end

	# generate_matrix_input
	# create an input element (radio or checkbox) for use in the matrix question
	def generate_matrix_input(type, row, col_text, model, question_id, category)
		type = type.split("_")[1]
		checkbox_array = type == 'checkbox' ? '[]' : ''
		row_id = row[:r_id]
		row_text = row[:r_text]
		checked = ""
		cat_ext = category.nil? ? '' : "-#{category.id}"
		checked, subq_val = get_answer(row, category, 'matrix', {"col_text"=>col_text})
		
		encoded_col = CODER.encode(col_text.to_s.gsub('"','\"'))
		encoded_row = CODER.encode(row_text.to_s.gsub('"','\"'))
		retVal = "<center><label class='hidden-label'>Select #{encoded_col} for the #{encoded_row} row</label>"\
			"<input type='#{type}' title='select row: #{encoded_row}, column: #{encoded_col}' "\
			"name='#{model}[#{question_id}_#{row_id}#{cat_ext}]#{checkbox_array}' id='#{model}_#{question_id}_#{row_id}#{cat_ext}' "\
			"value='#{encoded_col}' #{checked} /></center>"

		return retVal
	end

	# generate_matrix_dropdown_input
	# create a dropdown input element within the matrix. If there are no dropdown options, just put in a blank 
	# text box (using generate_input_for_matrix)
	def generate_matrix_dropdown_input(type, row, col, model, question_id, uses_other_in_dropdown, category)
		row_id = row[:r_id]
		col_id = col[:c_id]
		row_text = row[:r_text]
		col_text = col[:c_text]
		cat_ext = category.nil? ? '' : "-#{category.id}"
		# get answer and dropdown for this colum/row combo
		answer, subq_val = get_answer(col, category, 'matrix-dropdown', {"row_id"=>row_id})	
		dropdown_opts = col[:c_dropdowns].present? ? (col[:c_dropdowns][row_id].present? ? col[:c_dropdowns][row_id] : []) : []
		dd_name = "#{model}[#{question_id}_#{row[:r_id]}_#{col[:c_id]}#{cat_ext}]"
		dd_id = "#{model}_#{question_id}_#{row[:r_id]}_#{col[:c_id]}#{cat_ext}"

		input = ""
		# if there are no dropdown options then it's just a text box
		if dropdown_opts.empty?
			input = "<input type='text' value='#{answer}' id=#{dd_id} name=#{dd_name} style='width:100px !important;'/>"
		# otherwise we need to create the select box
		else
			input = "<select name='" + dd_name + "' id='" + dd_id + "' >"\
					"<option value=''>-- Select --</option>"
			still_no_answer = true
			iter = 1
			dropdown_opts.each do |opt|
				selected = ''
				if opt == answer
					selected = "SELECTED"
					still_no_answer = false
				elsif uses_other_in_dropdown && iter = dropdown_opts.length && still_no_answer && answer != ''
					selected = "SELECTED"
				end
				input += "<option value='#{CODER.encode(opt.gsub('"','\"'))}' #{selected}>#{opt}</option>"
			end
			input += "</select>"
			
			unless dropdown_opts.include?(answer) || answer == ''
				input += show_other_with_answer(dd_id, answer, dd_name)
			end
			
			input += attach_listener_for_other(dd_id)
		end

		return "<center><label class='hidden-label'>Select a value for the #{row[:r_text]} row and #{col[:c_text]} column</label>#{input}</center>"

	end

	# add_other_matrix_box
	# create an input row for the text area where users can enter other information
	def add_other_matrix_box(row_id, model, question_id, num_columns, value='NO DATA', category)
		return "<tr><td>Other<br/>(please specify): <label class='hidden-label'>"\
			"Provide information not specified in the list above.</label></td>"\
			"<td colspan='#{num_columns}'><textarea rows=4 cols=40 name='#{model}[#{question_id}_#{row_id}_0#{category}]' "\
			"id='#{model}_#{question_id}_#{row_id}_0#{category}'>#{value}</textarea></td></tr>"
	end

	# create_subquestion
	# create the subquestion field after any checkbox or radio button or select
	def create_subquestion q_id, model, subquestion, value, disabled, category, checkbox_field=""
		value = value.blank? ? '' : "#{CODER.encode(value)}"
		return "#{subquestion} <input class='editable_field' name='#{model}_sub[#{q_id}#{category}]#{checkbox_field}' value='#{value}' #{disabled}/>"
	end

	# adds a javascript/jquery ajax listener for fields with 'other' item in a dropdown menu
    # @param [string] item_id
    # @return [string] javascript listener to return 
    def attach_listener_for_other item_id, field_size="small"
  		js = '<script>' + '$("#' + item_id + '").unbind(); $("#' + item_id + '").bind("change",function(event) { $.ajax({url: "/application/show_other",data: {"field_id":this.id, "field_name":this.name, "field_size":"'+field_size+'", "selected":this.value}});});</script>'
		return js
    end

    # show_other_with_answer
    # Use this function when a user has selected 'other' from a dropdown list and the input box with the actual result 
    # that they entered needs to be rendered.
    # This may be used for dropdown boxes within a matrix or normal select questions
    def show_other_with_answer field_id, value, field_name
  		retVal = "<span id='#{"other_"+field_id}' class='other_field' style='padding: 0px;'>
  			  <br><br>
			  Please Specify:
			  <input id='#{field_id + "_input"}' type='text' title='other' style='width: 75%;'' name='#{field_name}' value='#{value}'>
			  </span>"
		return retVal	
    end

    # include_instruction
    # if instructions exist for the question, return them
    def include_instruction question
    	return "<span style='color: red; font-style: italic;'>#{question[:q_instruct]}</span>"
    end

end
