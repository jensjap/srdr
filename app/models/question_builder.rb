class QuestionBuilder
	STRING_TO_MODEL = {
		"design_detail"=>"DesignDetail",
		"baseline_characteristic"=>"BaselineCharacteristic",
		"arm_detail"=>"ArmDetail",
		"outcome_detail"=>"OutcomeDetail",
        "diagnostic_test_detail"=>"DiagnosticTestDetail",
        "quality_detail"=>"QualityDetail"
		}

	#----------------------------------------------------------------------#
	# CODE BELOW DEALS WITH CREATING THE QUESTIONS IN THE EXTRACTION FORM  #
	#----------------------------------------------------------------------#

	# create_options_for_
	# remove_old_choices
	# remove all previously saved question choices before
	# scan the choices for a given question id and remove any
	# that are not in the id list
	# HOW WILL THIS WORK IF PEOPLE HAVE ALREADY SAVED DATA??
	def self.remove_old_choices obj_id, id_list, obj_type, obj_class
		choices = eval("#{obj_class}Field").where("#{obj_type}_id"=>obj_id)
		unless choices.empty?
			choices.each do |choice|
				#print "CHOICE: #{choice.id.to_s}, IDS: #{id_list}\n\n"
				unless id_list.include?(choice.id.to_s)
					#print "AND we're deleting choice.id.to_s...\n\n"
					choice.destroy
				end
			end
		end
	end
	
	# save_question_choices
	# save the choices for any question being entered
	def self.save_question_choices(choices_hash, obj_id, editing, subquestion, options_with_subs, has_subquestion, obj_type, obj_class) 
		success = true
		objid = obj_id
		good_ids = []
		subquestioned_options = []
		has_sub = false
		if has_subquestion == 'yes' || has_subquestion == true
		  has_sub = true
		end

		unless options_with_subs.nil?
			subquestioned_options = options_with_subs.values
		end
		
		# sort the keys to attempt at keeping the order correct
		sorted_keys = choices_hash.sort.collect{|x| x[0]}

		sorted_keys.each_with_index do |key,index|
			tmp = nil
			option_number = nil
			key_parts = key.split('_')
			# if we're editing, we'll look for a previously existing field and try to update it
			if editing
				field_id = key_parts[key_parts.length-1] #the id of the field itself was on the end of the id
				option_number = key_parts[1]
				begin
					tmp = eval("#{obj_class}Field").find(field_id.to_i)
				rescue
					tmp = nil
				end
			else
				option_number = key_parts[key_parts.length-1]
			end
				
			# if there is no previous question to modify
			if tmp.nil?
				# get a subquestion 
				subquestion_text = nil
				has_subquestion=false
				if has_sub
					if subquestioned_options.include?(option_number.to_s)
						subquestion_text = subquestion
						has_subquestion=true	
					end
				end
				tmp = eval("#{obj_class}Field").new("#{obj_type}_id"=>obj_id, :option_text=>choices_hash[key], :subquestion=>subquestion_text, :has_subquestion=>has_subquestion, :row_number=>option_number)
				if !tmp.save
					print " Saving failed.\n\n"
					success = false
				else
				end	
			else
				# get a subquestion 
				subquestion_text = nil
				has_subquestion=false
				if has_sub
					
					if subquestioned_options.include?(option_number.to_s)
						subquestion_text = subquestion
						has_subquestion=true
					
					end
				end
				previous_text = tmp.option_text
				previous_row_num = tmp.row_number

				# Use transactions to ensure atomicity of this update
				eval("#{obj_class}Field").transaction do					
					if tmp.update_attributes(:option_text => choices_hash[key], :subquestion=>subquestion_text, :has_subquestion=>has_subquestion, :row_number=>option_number)
						# update any data points that should remain associated with the new change
						dps = eval("#{obj_class}DataPoint").find(:all, 
							:conditions=>["#{obj_type}_field_id=? and value=?", tmp["#{obj_type}_id"], previous_text],
							:select=>["id","value"])
						unless dps.empty?
							dp_ids = dps.collect{|dp| dp.id}
							puts "Datapoint IDs: #{dp_ids}\n\n"
							begin
								eval("#{obj_class}DataPoint").update(dp_ids, [{:value=>tmp.option_text}] * dp_ids.length)
							rescue Exception => e
								raise ActiveRecord::Rollback
							end
						end
					else
						success = false
					end
				end
			end
			good_ids << tmp.id.to_s
		end
		if editing
			remove_old_choices(objid, good_ids, obj_type, obj_class)
		end
		return success
	end

	# save_matrix_setup
	# When the user defines a matrix-style question, save the options based on matrix parameters. 
	# This includes creating rows and column fields. Columns are indicated using the column_number field in the 
	# ModelObjField database. Any rows will not utilize this field.
	def self.save_matrix_setup(matrix_options, obj_id, obj_type, obj_class, editing = false)
		begin
		# get row and column options
		rows = matrix_options["rows"]
		columns = matrix_options["columns"]
		is_other = matrix_options[:allow_other_row]
		dropdown_options = matrix_options[:dropdown_options]
		is_dropdown = !dropdown_options.nil?

		row_ids = Hash.new()		# keep track of new row ids for use later
		column_ids = Hash.new()		# keep tack of new column ids for use later
		if is_dropdown
			rows_array = self.get_sorted_matrix_hash_values(matrix_options["rows"])
			columns_array = self.get_sorted_matrix_hash_values(matrix_options["columns"]) 
		else
			rows_array = rows.split("\r\n")
			columns_array = columns.split("\r\n")
		end

		# IF THE USER IS EDITING, WE NEED TO UPDATE THEIR INFORMATION
		if editing
			puts "----------------\nSubmitted Rows:\n#{rows_array.join(', ')}\n\n" +
                "Submitted Cols:\n#{columns_array.join(', ')}\n\n-------------\n"
			# get the pre-existing rows and columns
			existing_columns = eval("#{obj_class}Field").find(:all, :conditions=>["#{obj_type}_id = ? AND column_number > ?",obj_id, 0], :order=>"column_number ASC")
			existing_rows = eval("#{obj_class}Field").find(:all, :conditions=>["#{obj_type}_id = ? AND (column_number = ? OR column_number IS NULL)",obj_id, 0],:order=>"row_number ASC")
            puts "EXISTING: \ncolumns: #{existing_columns.join(",")}\nrows:#{existing_rows.join(",")}\n\n"

			# START WITH THE EXISTING ROWS
			found_other = false
            row_total=0
            row_index = 0
			existing_rows.each do |er|
                puts "ROW LOOP[#{row_index}]: #{er.option_text} (rowNum = #{er.row_number})\n"
                # if the row_number is less than 0, it deals with the other field. see if we need to keep it
                if er.row_number < 0
                    if is_other.nil?
                        er.destroy 
                    else
                        found_other = true
                    end
                else
                # if it's not an Other... row, then figure out if it needs to be
                # either deleted, updated, or left alone.
    				if rows_array[row_index].nil?
                        puts "Found an old row that no longer exists. Deleting ID = #{er.id}...\n\n"
                        # if there are a greater number of previously entered
                        # rows than what is currently submitted, remove the old
                        # ones along with data points
                        eval("#{obj_class}DataPoint").transaction do
                            datapoints = eval("#{obj_class}DataPoint").find(:all, 
                                :conditions=>["row_field_id = ?", er.id], :select=>["id"])
                            unless datapoints.empty?
                                dp_ids = datapoints.collect{|dps| dps.id}
                                eval("#{obj_class}DataPoint").destroy(dp_ids)
                            end

                            er.destroy
                        end
                    else 
                        # if it's not an 'OTHER' field, then simply update the row title
                        rows_array[row_index].strip!
                        puts "UPDATING ROW FROM #{er.option_text} to #{rows_array[row_index]}\n\n"
                        unless er.option_text == rows_array[row_index]
                            er.option_text = rows_array[row_index]
                            er.save
                        end
                        row_total += 1
                        row_ids[row_total] = er.id
                    end
                    row_index += 1
                end
            end
            # CREATE ANY NEW ROWS THAT WERE ADDED TO THE LIST
            if rows_array.length > row_total
                for i in (row_index..(rows_array.length-1))
                    r = rows_array[i].strip
                    unless r.blank?
                        row_total += 1
                        newRow = eval("#{obj_class}Field").create("#{obj_type}_id"=>obj_id, :option_text=>r, :column_number=>0, :row_number=>row_total)
                        row_ids[newRow.row_number] = newRow.id
                    end
                end
            end

            # DETERMINE IF WE ALREADY FOUND THE OTHER ROW AND IF NOT, CREATE IT IF NECESSARY
            if is_other && !found_other
                eval("#{obj_class}Field").create("#{obj_type}_id"=>obj_id, :option_text=>"Other (please specify):", :column_number=>0, :row_number=>-1)
            end

            # NOW THE EXISTING COLUMNS
            # scan through the existing columns
            column_total = 0
            existing_columns.each_with_index do |ec, index|
                
                # if the existing columns list has grown longer than that submitted, 
                # then we will be deleting the older ones as well as associated data points
                if columns_array[index].nil?
                    eval("#{obj_class}DataPoint").transaction do
                        # DROPDOWN COLUMNS
                        if is_dropdown
                            # for dropdown matrices
                            datapoints = eval("#{obj_class}DataPoint").find(:all, 
                                :conditions=>["column_field_id = ?", ec.id], :select=>["id"])
                            unless datapoints.empty?
                                eval("#{obj_class}DataPoint").destroy(datapoints.collect{|x| x.id})
                            end
                        # NON-DROPDOWN columns
                        else
                            # for non-dropdown matrices (radio button or checkbox)
                            datapoints = eval("#{obj_class}DataPoint").find(:all,
                                :conditions=>["#{obj_type}_field_id=? AND value=?",obj_id,ec.option_text],:select=>["id"])
                            unless datapoints.empty?
                                eval("#{obj_class}DataPoint").destroy(datapoints.collect{|x| x.id})
                            end
                        end
                        # and once the datapoints are gone, destroy the option itself
                        ec.destroy
                    end
                else
                # if there are still matching submitted column names, we will 
                # simply update the associated values
                    columns_array[index].strip!
                    unless ec.option_text == columns_array[index]
                        eval("#{obj_class}Field").transaction do
                            # update values for any data points saved with this column
                            # (this does not apply to dropdowns since they have their own
                            #  sets of values that users choose from)
                            unless is_dropdown
                                datapoints = eval("#{obj_class}DataPoint").find(:all, 
                                    :conditions=>["#{obj_type}_field_id=? AND value = ?",obj_id,ec.option_text],:select=>['id'])
                                # update the existing datapoints to reflect the change in value
                                unless datapoints.empty?
                                    eval("#{obj_class}DataPoint").update(datapoints.collect{|x| x.id}, 
                                        [{:value=>columns_array[index]}] * datapoints.length)
                                end
                            end
                            ec.option_text = columns_array[index]
                            ec.save
                        end
                    end
                end
                column_total += 1
                column_ids[column_total] = ec.id
            end
            # IF THERE WERE ADDITIONAL COLUMNS SUBMITTED, CREATE THEM
            if columns_array.length > column_total
                for i in (column_total..(columns_array.length-1))
                    c = columns_array[i].strip
                    unless c.blank?
                        column_total += 1
                        newColumn= eval("#{obj_class}Field").create("#{obj_type}_id"=>obj_id, :option_text=>c, :column_number=>column_total, :row_number=>0)
                        column_ids[newColumn.column_number] = newColumn.id
                    end
                end
            end
            # NOW WORK ON ANY MATRIX DROPDOWN VALUES THAT ARE PRESENT
			# Now, if there are dropdown values then go through and update each row/column combination
			if is_dropdown
                puts "FOUND THAT IT's A DROPDOWN\n\n"
				# for each row in the table
				for i in 1..rows_array.length 
					r_id = row_ids[i]
					# for each column in the table
					for j in 1..columns_array.length
						cell_options = matrix_options[:dropdown_options]["#{i}_#{j}"].split("\r\n")
						c_id = column_ids[j]
                        puts "ROW_#{i}_#{r_id}_COL_#{j}_#{c_id}: #{cell_options}\n\n"
                        # get the options associated with the row/column combination
                        existing_options = MatrixDropdownOption.where(:model_name=>obj_type, :row_id=>r_id, :column_id=>c_id).order("option_number ASC")
                        option_total = 0
                        # if there are pre-existing options
                        
                        unless existing_options.empty?
                            puts "ITERATING THROUGH EXISTING DROPDOWN OPTIONS ------\n"
                            existing_options.each_with_index do |eo,index|
                                puts "#{index + 1}.  #{eo.option_text}\n"
                                # if the original list is longer than the new one,
                                # we must start removing options
                                puts "Existing Option: #{eo.option_text}\n\n"
                                if cell_options[index].nil?
                                    puts "The new cell options don't have an index of #{index}. Should delete this one...\n"
                                    MatrixDropdownOption.transaction do
                                        datapoints = eval("#{obj_class}DataPoint").find(:all, 
                                            :conditions=>["row_field_id=? AND column_field_id=? AND value=?",r_id,c_id,eo.option_text],
                                            :select=>["id"])
                                        eval("#{obj_class}DataPoint").destroy_all(:id => datapoints.collect{|x| x.id}) unless datapoints.empty?
                                        puts "DESTROYING #{eo.option_text} - #{eo.id}\n\n"    
                                        eo.destroy   

                                    end
                                else
                                    # update the dropdown value unless it matches that 
                                    # previously entered
                                    cell_options[index].strip!
                                    unless eo.option_text == cell_options[index]
                                        MatrixDropdownOption.transaction do 
                                            datapoints = eval("#{obj_class}DataPoint").find(:all, 
                                            :conditions=>["row_field_id=? AND column_field_id=? AND value=?",r_id,c_id,eo.option_text.to_s],
                                            :select=>["id"])
                                            # update datapoints if there are any
                                            unless datapoints.empty?
                                                eval("#{obj_class}DataPoint").update(datapoints.collect{|x| x.id},
                                                    [{:value=>cell_options[index]}] * datapoints.length)
                                            end
                                            eo.option_text = cell_options[index]
                                            eo.save
                                        end
                                    end
                                    option_total += 1
                                end
                            end
                        end
                        # CREATE ANY NEWLY ENTERED CELL OPTIONS
                        if cell_options.length > option_total
                            puts "FOUND NEW ENTRIES. LOOPING FROM INDX #{option_total} to #{cell_options.length - 1}\n\n"
                            for iter in (option_total..(cell_options.length-1))
                                cellText = cell_options[iter].strip
                                unless cellText.blank?
                                    option_total += 1
                                    newOption= MatrixDropdownOption.create(
                                        :row_id=>r_id,
                                        :column_id=>c_id,
                                        :option_text=>cellText.to_s,
                                        :option_number=>option_total,
                                        :model_name=>obj_type)
                                end
                            end
                        end
					end # end for each column
				end # end for each row
				# for the dropdown, determine whether or not the user will be allowed to specify "other" in each menu
			end # end if is_dropdown

		# IF THE USER IS NOT EDITING THE MATRIX, THEN DO A STRAIGHT-FORWARD SAVING OF ROWS AND COLUMNS
		else	
			# if there are no dropdown options then it's a typical matrix setup
			if !is_dropdown
				# create the row fields
				row_num = 1
				rows_array.each do |r|
					unless r.blank?
						eval("#{obj_class}Field").create("#{obj_type}_id"=>obj_id, :option_text=>r.strip, :column_number=>0, :row_number=>row_num)
						row_num += 1
					end
				end

				# create the column fields
				col_num = 1
				columns_array.each do |c|
					unless c.blank?
						eval("#{obj_class}Field").create("#{obj_type}_id"=>obj_id, :option_text=>c.strip, :column_number=>col_num, :row_number=>0)
						col_num += 1
					end
				end
				# determine if the creator wanted their users the ability to enter 'other' information for the matrix
				provide_other_row = matrix_options["allow_other_row"].nil? ? false : matrix_options["allow_other_row"] == "on" ? true : false
				if provide_other_row
					eval("#{obj_class}Field").create("#{obj_type}_id"=>obj_id, :option_text=>"Other (please specify):", :row_number=>-1, :column_number=>0)
				end	
			else
			# if there are dropdown options then we need to save the dropdown matrix
				
				# for each row, create a new field option with the proper row number
				new_columns = Hash.new()
				rows.keys.each do |rowkey|
					rowtext = rows[rowkey].blank? ? "Row #{rowkey}" : rows[rowkey]
					row_field = eval("#{obj_class}Field").create("#{obj_type}_id"=>obj_id, :option_text=>rowtext, :column_number=>0, :row_number=>rowkey.to_i)
					
					# for each column create a new field option with the proper column number
					columns.keys.each do |columnkey|
						unless new_columns.keys.include?(columnkey)
							optText = columns[columnkey].blank? ? "Column #{columnkey}" : columns[columnkey]
							column_field = eval("#{obj_class}Field").create("#{obj_type}_id"=>obj_id, :option_text=>optText, :column_number=>columnkey, :row_number=>0)
							new_columns[columnkey] = column_field
						end
						
						options = dropdown_options["#{rowkey}_#{columnkey}"]
						option_lines = options.split("\r\n")
						option_num = 1
						option_lines.each do |opt|
							unless opt.blank?
								MatrixDropdownOption.create(:model_name=>obj_type, :row_id=>row_field.id, :column_id=>new_columns[columnkey].id, :option_text=>opt, :option_number=>option_num)
								option_num += 1
							end
						end
					end
				end
				# determine if the creator wanted their users the ability to enter 'other' information for the matrix
				provide_other_row = matrix_options["allow_other_row"].nil? ? false : matrix_options["allow_other_row"] == "on" ? true : false
				if provide_other_row
					eval("#{obj_class}Field").create("#{obj_type}_id"=>obj_id, :option_text=>"Other (please specify):", :row_number=>-1, :column_number=>0)
				end	
			
			end
		end
		rescue Exception => e
			puts "-------------------\n------------------\nAN ERROR OCCURED: #{e.message}\n\n"
			puts "#{e.backtrace}"
		end
	end

	# copy
	# duplicate a question, saving time by allowing to edit complicated, yet similar questions
	# @params question   - the object to be copied
	# @params model      - the name of the model (design_detail, baseline_characteristic, etc.)
	# @return question   - the newly created question object
	# @return fields     - the fields associated with the new question
	def self.create_duplicate_question question_id, model, class_name
		question = eval(class_name).find(question_id)
		
		# get attributes associated with the object
		attrs = question.attributes

		# create a new, duplicate copy of this object
		new_question = eval(class_name).new()
		new_question.question = "#{attrs['question']} (DUPLICATED)"
		new_question.extraction_form_id = attrs["extraction_form_id"]
		new_question.field_type = attrs["field_type"]
		new_question.instruction = attrs["instruction"]
		new_question.is_matrix = attrs["is_matrix"]
		new_question.include_other_as_option = attrs["include_other_as_option"]
		new_question.question_number = ExtractionForm.get_next_question_number(class_name, attrs["extraction_form_id"])
		new_question.save()

		# get the fields associated with this object
		new_fields = []
		new_options = []
		field_map = Hash.new()

		fields = eval("#{class_name}Field").where("#{model}_id" => question.id)
		fields.each do |field|
			f_attrs = field.attributes
			new_field = eval("#{class_name}Field").new()
			new_field["#{model}_id"] = new_question.id
			new_field.option_text = field.option_text
			new_field.subquestion = field.subquestion
			new_field.has_subquestion = field.has_subquestion
			new_field.column_number = field.column_number
			new_field.row_number = field.row_number
			new_field.save()
			new_fields << new_field
			field_map[field.id] = new_field.id
		end
		if question.field_type == "matrix_select"
			rows = fields.select{|x| x.row_number > 0}
			rows.each do |r|
				dropdownOptions = MatrixDropdownOption.where(:model_name=>model, :row_id=>r.id)
				dropdownOptions.each do |ddo|
					new_option = MatrixDropdownOption.create(:model_name=>model, :row_id=>field_map[ddo.row_id], :column_id=>field_map[ddo.column_id],
															 :option_text=>ddo.option_text, :option_number=>ddo.option_number)
				end
			end		
		end

		return new_question, new_fields
	end

	# remove_all_matrix_dropdowns
	# Destroy any dropdown options specified for matrix-select type questions. To do so, find all
	# row fields associated with the matrix, and destroy any matching MatricDropdownOption values.
	def self.remove_all_matrix_dropdowns model_name, class_name, obj_id

		rows = eval("#{class_name}Field").find(:all, :conditions=>["#{model_name}_id=? AND row_number > ?",obj_id, 0], :select=>"id")
		options = MatrixDropdownOption.where(:model_name=>model_name, :row_id=>rows.collect{|x| x.id})
		options.each do |opt|
			opt.destroy
		end
	end

	# hash_keys_to_int
	# given a hash of values, make the keys into intgers so that they can be sorted
	def self.get_sorted_matrix_hash_values hash
		retVal = Hash.new();
		hash.keys.each do |k|
			retVal[k.to_i] = hash[k]
		end
		return retVal.sort.collect{|x| x[1]}
	end

	# unescape_quotes
	# USED BY SAVE METHODS PRIOR TO SAVING DATA FROM ALL QUESTION BUILDER SECTIONS
	# given a hash object, unescape any quotes found in the values for the hash.
	# Coming from the question builder, any field options that contain quotes will have quotes represented as \\\". 
	# If the value is an array, loop through it and check each element
	# @param  input  - the hash with values in need of checking
	# @return input - the corrected hash
	def self.unescape_quotes input
		input.keys.each do |key|
			value = input[key]
			if value.class == Array
				tmpArray = []
				value.each do |val|
					tmpArray << val.gsub(/\\\"/,'"')
				end
				input[key] = tmpArray
			else
				input[key] = value.gsub(/\\\"/,'"')
			end
		end
		return input
	end
	
	#----------------------------------------------------------------#
	#----------------------------------------------------------------#
	#----------------------------------------------------------------#
	# FROM HERE DOWN DEALS WITH DISPLAYING THE QUESTIONS IN THE VIEW #
	#----------------------------------------------------------------#
	#----------------------------------------------------------------#
	#----------------------------------------------------------------#
	# return questions for a given section for use in the view
	# @params model_name (string)        the name of the model, ie design_detail, baseline_characteristic, etc.
	# @params study_id (int)             the id of the study object
	# @params extraction_form_id (int)   the id of the extraction form object
	# @params options  (hash)            a hash containing various options:
	#         - user_is_assigned (boolean)   determine whether the user should see all comments or just the private ones BOOLEAN
	#         - is_by_arm  (boolean)         should the data be collected by arm? BOOLEAN
	#         - is_by_outcome  (boolean)     should the data be collected by outcome? BOOLEAN
	#   	  - include_total (boolean)      should the total of arms or outcomes be shown?
	def self.get_questions model_name, study_id, extraction_form_id, options = {}
		begin
		# initialize our option parameters
		user_is_assigned = options[:user_is_assigned] ||= false
		by_arm = options[:is_by_arm] ||= false
		by_dx_test = options[:is_by_diagnostic_test] ||= false
		by_outcome = options[:is_by_outcome] ||= false
		include_total = options[:include_total].nil? ? true : options[:include_total] == false ? false : true
		
		get_results_by = nil
		categories = []
		if by_arm 
			get_results_by = "arm"
			categories = Arm.sorted_by_display_number(extraction_form_id, study_id)
		elsif by_outcome
			get_results_by = "outcome"
			categories = Outcome.sorted_by_created_date(extraction_form_id, study_id)
		elsif by_dx_test
			get_results_by = "diagnostic_test"
			categories = DiagnosticTest.sorted_by_created_date(extraction_form_id, study_id)
		end			

		# initiate the hash that we'll return later
		hashed_questions = {:model=>model_name}
		hashed_questions[:page_title] = "Study " + model_name.gsub("_"," ").titleize + "s"
		
		model = STRING_TO_MODEL[model_name].to_s
		questions = eval(model).questions_for_ef(extraction_form_id)

		hashed_questions[:num_questions] = questions.length
		hashed_questions[:questions] = Array.new()
		hashed_questions[:by_arm] = by_arm
		hashed_questions[:by_outcome] = by_outcome
		hashed_questions[:by_dx_test] = by_dx_test
		hashed_questions[:include_total] = include_total
		hashed_questions[:categories] = categories
		
		question_ids = questions.collect{|q| q.id}
		# get fields assocated with all of the questions
		fields = eval("#{model}Field").all_fields_for_questions(question_ids, model_name)

		# get datapoints associated with all of the questions
		datapoints = eval("#{model}DataPoint").all_datapoints_for_study(question_ids, study_id, model_name)

		section_name = model_name.gsub("_","").pluralize
		comments = Comment.find(:all, :conditions=>["section_name=? AND section_id IN (?) AND study_id=? "\
		 						"AND is_public IN (?)", section_name, question_ids, study_id, 
		 						[false,user_is_assigned].uniq], :select=>["section_id", "is_flag"])		

		# get matrix dropdown options for any questions that require them
		matrix_dropdowns = MatrixDropdownOption.matrix_dropdowns_for_fields(fields.collect{|f| f.id}, model_name)
		# now for each question...
		questions.each do |q|
			# start creating a hash for the question to hold the basic characteristics
			q_hash = {
				:q_id => q.id,
				:q_num => q.question_number,
				:q_type => q.field_type,
				:q_quest => q.question,
				:q_instruct => q.instruction,
				:q_is_matrix => q.is_matrix,
				:q_has_matrix_other => q.include_other_as_option,
				:q_include_other => q.include_other_as_option,
				:q_num_comments => comments.count{|c| c.section_id == q.id && c.is_flag == false},
				:q_num_flags => comments.count{|c| c.section_id == q.id && c.is_flag == true}
			}
			
			# now add the fields and answers to the hash
			q_fields = fields.select{|f| eval("f.#{model_name}_id == q.id")}
			q_datapoints = datapoints.select{|dp| eval("dp.#{model_name}_field_id == q.id")}

            # Attach DaaMarkers to datapoints.
            q_datapoints.each do |dp|
                lsof_daa_markers = []
                lsof_daa_marker_ids = DaaMarker.where(datapoint_id: dp.id).collect { |dm| dm.marker_id }
                lsof_daa_marker_ids.each do |marker_id|
                    response = HTTParty.get("http://api.daa-dev.com:3030/v1/document_markers/#{marker_id}")
                    lsof_daa_markers.push response
                end
                q_hash[:q_daa_markers] = lsof_daa_markers
            end

			# --- Radio, Checkboxes and Dropdowns
			if ["radio","checkbox","yesno","select"].include?(q.field_type)  
				q_hash[:fields] = self.create_multi_choice_field_hash(model_name,q_fields,q_datapoints, get_results_by)
			
			# --- Text Entry ---
			elsif q.field_type == 'text'
				q_hash[:q_answers] = Hash.new() unless get_results_by.nil?
				unless q_datapoints.empty?
					q_datapoints.each do |dp|
						if get_results_by.nil?
							q_hash[:q_answer] = dp.value
							break
						else
							# if it's a question by arm or outcome then we need to form a hash to hold the results
							q_hash[:q_answers][dp["#{get_results_by}_id"]] = dp.value
						end
					end
				end

			# --- Matrix Questions
			else
				# handle matrix questions
				q_hash[:fields] = create_matrix_field_hash(model_name,q_fields,matrix_dropdowns,q_datapoints,q.field_type.split("_")[1], q.include_other_as_option, get_results_by)
			end

			# now add the question hash to the questions array
			hashed_questions[:questions] << q_hash
		end
		
		return hashed_questions
		rescue Exception => e 
			puts "CAUGHT EXCEPTION: #{e.message}\n\n#{e.backtrace}\n\n\n"
		end
	end

	private
	
	# create_multi_choice_field_hash
	# create and return a hash to represent fields and datapoints for a particular question
	# @params model_name    design_detail, baseline_characteristic, etc. etc. (question model)
	# @params fields        the field options for the question (what they may select from)
	# @params datapoints    the datapoints saved to the question
	# @params results_by    allow us to specify by arm or outcome (or default which is nil)
	# 
	# This function used for select boxes, checkboxes and radio buttons
	def self.create_multi_choice_field_hash(model_name, fields, datapoints, results_by=nil)
		retVal = Array.new()
		# loop through the fields and if a datapoint matches, mark it as selected
		fields.each do |field|
			field_map = {
				:f_id=>field.id, 
				:f_text => field.option_text,
				:f_has_subq => field.has_subquestion,
				:f_subq => field.subquestion,
				:f_row => field.row_number 
				}
			dps = datapoints.select{|x| x.value == field.option_text}
			unless dps.empty?
				dps.each do |dp|
					if results_by.nil?
						field_map[:f_checked] = true
						field_map[:f_subq_val] = dp.subquestion_value if field.has_subquestion == true
					else
						field_map[dp["#{results_by}_id"]] ||= Hash.new()
						field_map[dp["#{results_by}_id"]][:f_checked] = true
						field_map[dp["#{results_by}_id"]][:f_subq_val] = dp.subquestion_value if field.has_subquestion == true
					end
				end
			end
			retVal << field_map
		end
		return retVal
	end

	# create_matrix_field_hash
	# create and return a hash to represent fields and datapoints for a matrix question
	# @params model_name    design_detail, baseline_characteristic, etc. etc. (question model)
	# @params fields        the field options for the question (what they may select from)
	# @params dropdowns     a list of dropdown options for the cells
	# @params datapoints    the datapoints saved to the question
	# matrix_type           what type of matrix is this...
	# @params has_other_option should we include the option of 'other' in the dropdowns'
	# @params results_by    are the results by arm, outcome or everything (nil)
	#
	# This function used for all matrix questions
	def self.create_matrix_field_hash(model_name, fields, dropdowns, datapoints, matrix_type, has_other_option = false, results_by)
		begin
			retVal = {:rows=>Array.new(), :columns=>Array.new()}
			# split the fields into rows and columns
			rows = fields.select{|r| r.row_number != 0}
			cols = fields.select{|c| c.column_number != 0}
			rows.sort!{|a,b| a.row_number <=> b.row_number}
			cols.sort!{|a,b| a.column_number <=> b.column_number}

			# get row information
			rows.each do |row|

				field_map = {
					:r_id=>row.id,
					:r_text=>row.option_text,
					:r_rnum=>row.row_number
				}

				# figure out answers for each row (unless it's a select question )
				# Added the row.rownumber > 0 to capture any 'other' fields marked as -1
				unless matrix_type == 'select' && row.row_number > 0
					dps = datapoints.select{|x| x.row_field_id == row.id}
					unless dps.empty?
						field_map[:r_answers] = get_matrix_datapoints('multichoice',dps,results_by)
					end
				end
				retVal[:rows] << field_map
			end
			
			# get column information
			cols.each do |col|
				field_map = {
					:c_id=>col.id,
					:c_text=>col.option_text,
					:c_cnum =>col.column_number
				}	
				
				# figure out answers for each column and row if it's a dropdown matrix
				if matrix_type == 'select'
					dps = datapoints.select{|x| x.column_field_id == col.id}
					unless dps.empty?
						field_map[:c_answers] = get_matrix_datapoints('select',dps,results_by)
					end
					
					these_dropdowns = dropdowns.select{|dd| dd.column_id == col.id }
					unless these_dropdowns.empty? 
						field_map[:c_dropdowns] = get_matrix_dropdowns(these_dropdowns, has_other_option)

					end
				end
				retVal[:columns] << field_map
			end
			return retVal	
		rescue Exception=>e 
			puts "ERROR: #{e.message}\n\n#{e.backtrace}"
		end
	end

	def self.get_matrix_datapoints(type, datapoints, divide_results_by)
		answers = nil # establish the answers variable (we'll return this)
		
		# if it's a select box we need to record the row and column that the data is saved at
		# NOTE: There will only be one value per row/col combination
		if type == 'select'
			answers = Hash.new()
			datapoints.each do |dp|
				if divide_results_by.nil?
					answers[dp.row_field_id] = dp.value
				else
					answers[dp.row_field_id] ||= Hash.new()
					answers[dp.row_field_id][dp["#{divide_results_by}_id"]] = dp.value 
				end
			end

		# if it's a simple checkbox or radio button all we need is to return an array of values 
		# unless the questions are by arm or outcome
		else
			if divide_results_by.nil?
				answers = Array.new()
				datapoints.each do |dp|
					answers << dp.value
				end
			# if it's a question by arm or outcome, then we'll return a hash that's indexed
			# by the id of either the arm or outcome
			else
				answers = Hash.new()
				datapoints.each do |dp|
					answers[dp["#{divide_results_by}_id"]] ||= Array.new()
					answers[dp["#{divide_results_by}_id"]] << dp.value
				end
			end
		end
		return answers
	end

	# get_matrix_dropdowns
	# given a set of dropdown options corresponding to a particular column in the matrix, generate
	# a hash of arrays indexed by the row id.
	def self.get_matrix_dropdowns(dropdowns, has_other_option)
		dd_list = Hash.new()
		dropdowns.each do |dd|
			if dd_list[dd.row_id].present?
				dd_list[dd.row_id] << dd.option_text
			else
				dd_list[dd.row_id] = [dd.option_text]
			end
		end
		if has_other_option
			dd_list.keys.each do |key|
				dd_list[key] << 'Other...'
			end
		end
		return dd_list
	end

	### check_inputs
	### verify that the question parameters submitted are legitimate and will result in a successfully created question.
	### Items that will cause a return value of false:
	###    - blank title
	###    - non-unique choices, rows or columns
	###    - blank choices, rows or columns
	###    return the array of error messages
	def self.check_inputs(question_params, choices_params={})
		puts "-----------\nQUESTION: #{question_params}\n\n\nCHOICES PARAMS: #{choices_params}\n\n\n"
		field_type = question_params[:field_type]
		errors = []
		
		## FIRST, MAKE SURE THERE'S TEXT IN THE QUESTION
		if question_params[:question].blank?
		  errors << "The question cannot be blank"
		end
		
		## HANDLE MATRIX QUESTIONS FIRST
		if field_type.match("matrix")
		    ## Dropdown matrices have their own set of parameters
		    if field_type.match("select")
		    	errors << "You must include at least one row" unless choices_params[:rows]
		    	errors << "You must include at least one column" unless choices_params[:columns]
		   		# as long as the user didn't manually remove the rows and columns entries
		    	if choices_params[:rows] && choices_params[:columns]
		    		rows = choices_params[:rows].values
		    		errors << "You must include at least one row" if rows.length < 1
				    errors << "Row values must be unique" if rows.uniq.length < rows.length 
				    rows.each do |v|
				      errors << "Row values cannot be blank" if v.blank?
				      break if v.blank?
				    end

				    cols = choices_params[:columns].values
				    # make sure rows are unique and columns are unique
				    errors << "You must include at least one column" if cols.length < 1
				    errors << "Column values must be unique" if cols.uniq.length < cols.length
				    cols.each do |v|
				    	errors << "Column values cannot be blank" if v.blank?
				    	break if v.blank?
				    end
		    	end
		    ## Matrix types other than dropdown matrices can be mostly treated the same
		    else
			   	# make sure there are rows
			    if choices_params.keys.include?("rows")
				    rows = choices_params[:rows].split("\r\n")
				    # make sure rows are unique and columns are unique
				    errors << "You must include at least one row" if rows.length < 1
				    errors << "Row values must be unique" if rows.uniq.length < rows.length 
				    rows.each do |v|
				      errors << "Row values cannot be blank" if v.blank?
				      break if v.blank?
				    end
				else
				    errors << "You must include at least one row"
				end

			    # make sure there are columns
			    if choices_params.keys.include?("columns")
				    cols = choices_params[:columns].split("\r\n")
				    # make sure rows are unique and columns are unique
				    errors << "You must include at least one column" if cols.length < 1
				    errors << "Column values must be unique" if cols.uniq.length < cols.length
				    cols.each do |v|
				    	errors << "Column values cannot be blank" if v.blank?
				    	break if v.blank?
				    end
			  	else
			    	errors << "You must include at least one column"
			    end
		    end
		  
		## OTHERWISE IF IT IS NOT A MATRIX
		else
		  	unless field_type == "text"
		  		unless choices_params.empty?
				    if choices_params.values.length > choices_params.values.uniq.length
				      errors << "Answer choices must be unique"
				    end
				    choices_params.values.each do |v|
				      errors << "Answer choices cannot be blank" if v.blank?
				      break if v.blank?
				    end
		  		end   
			end
		end
		return errors
	end
end
