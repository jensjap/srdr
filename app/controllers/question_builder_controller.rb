class QuestionBuilderController < ApplicationController
    
    def add_instr
        @editing = false
        @model_title = params[:model_title]
        @model_name = params[:model_name]
        @extraction_form = ExtractionForm.find(params[:extraction_form_id])
        #@project = Project.find(params[:project_id])
        @section = params[:section]
        #@data_element = params[:data_element]
        @extraction_form_instr = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", @extraction_form.id, @section.upcase, "GENERAL"])
        if @extraction_form_instr.nil?
            @extraction_form_instr = EfInstruction.new
        end
    end

    # create a new question of a specified type, which
    # can be baseline characteristic, design detail, arm, etc.
    def new
        @model_name = params[:model_name]
        @model_title = params[:model_title]
        @model_obj = eval(@model_title.gsub(" ","")).new
        @question = @model_obj.dup
        @editing=false
        @extraction_form = ExtractionForm.find(params[:extraction_form_id])
        if !params[:study_id].nil? && params[:study_id] != ""
            @study = Study.find(params[:study_id])
        end
    end

    #edit_question
    # given a question id and model name, create the form for editing the current question.
    def edit_question
        puts "------------------\nentered edit question\n----------------"
        qid = params[:qid]
        @qnum = params[:qnum]
        @model = params[:page_name]
        @model_name = @model.dup
        @model_title = @model_name.split("_").collect{|x| x.capitalize}.join(" ")
        @class_name = get_camel_caps(@model)
        @question = eval(@class_name).find(qid)
        @fields = @question.get_fields
        @has_study_data = eval(@class_name).has_study_data(qid)
        @editing = true
        puts "------------------\nleaving edit question\n----------------"
    end
 
    # remove_question
    # remove a given question from an extraction form
    # called by question_builder/destroy
    # shared/render_partial.js.erb
    def remove_question
        question_id = params["qid"]
        page_name = params["page_name"]
        obj_name = get_camel_caps(page_name)
        @obj = eval(obj_name).find(question_id)
        # if this object is a matrix dropdown, we need to remove all associated options
        if @obj.field_type == 'matrix_select'
            all_row_fields = QuestionBuilder.remove_all_matrix_dropdowns(page_name, obj_name, @obj.id)
        end

        @extraction_form = ExtractionForm.find(@obj.extraction_form_id)
        unless @obj.nil?
            ExtractionForm.update_question_numbers_after_delete(obj_name,@obj.id, @extraction_form.id)
            # remove any fields and data points that are associated with this question
            field_ids = eval("#{obj_name}Field").where("#{page_name}_id"=>@obj.id).select("id").collect{|f| f.id}
            dp_ids = eval("#{obj_name}DataPoint").where("#{page_name}_field_id"=>@obj.id).select("id").collect{|dps| dps.id}
            eval("#{obj_name}Field").destroy(field_ids)
            eval("#{obj_name}DataPoint").destroy(dp_ids)
            @obj.destroy
        end
        @questions = eval(obj_name).where(:extraction_form_id=>@obj.extraction_form_id).order("question_number ASC")
        @model = page_name
        @model_name = @model.dup
        @model_title = @model_name.split("_").collect{|x| x.capitalize}.join(" ")
        @div_name = "#{@model_name}_extraction_form_preview_table"
        @message_div = "#{@model_name}_removed_item_indicator"
        @partial_name = "question_builder/extraction_form_preview"
        render "shared/render_partial.js.erb"
    end

    # copy_question
    # Create an exact copy of a given question
    # @params id  - the id of the question to be copied
    # @params model_name  - the model being copied (design_detail, baseline_characteristic, etc.)
    def copy_question
        @model_name = params[:page_name]
        @model = @model_name.dup
        class_name = get_camel_caps(@model_name)
        @question, @fields = QuestionBuilder.create_duplicate_question(params[:qid], @model_name, class_name)
        @questions = eval(class_name).where(:extraction_form_id=>params[:efid]).order("question_number ASC")
        @model_title = @model_name.split("_").collect{|x| x.capitalize}.join(" ")
        @extraction_form = ExtractionForm.find(params[:efid])
        @editing = true

        # for the editing pop-up window
        @has_study_data = false
        @is_duplicate = true

        # refresh the question list div and pop-up a window for editing the newly created, duplicate question
        render 'copy_question.js.erb'
    end

    # get_camel_caps
    # a camelcaps function to accept the model as input and return a representation that can be called
    # with eval to hit the database table.
    # example: design_detail would give DesignDetail
    def get_camel_caps input
        tmp = input.split("_")
        tmp.each do |x|
            x.downcase!
            x.capitalize!
        end
        return tmp.join("")
    end

    # def create
    # create a new question object of the type specified by the model parameters
    def create
        @model_name = params[:page_name]
        @model_title = params[:page_title]
        @class_name = @model_title.gsub(" ","")
        @model_obj = eval(@class_name).new(params[@model_name.to_s])
        is_matrix = params["#{@model_name}_matrix"].nil? ? false : true
        @model_obj.is_matrix = is_matrix

        puts "-------------\nCreated a new #{@model_name} object.. The Question is: #{@model_obj.question}\n\n"
        @model_obj.question_number = ExtractionForm.get_next_question_number(@class_name,@model_obj.extraction_form_id)
        @extraction_form = ExtractionForm.find(@model_obj.extraction_form_id)

        choices = []
        if params[@model_name.to_s][:field_type] == 'text'
            choices = []
        elsif is_matrix
            choices = params["#{@model_name}_matrix"] 
        else
            choices = params["#{@model_name}_choices"] ||= []    
        end
        errors = QuestionBuilder.check_inputs(params[@model_name.to_s], choices)

        if errors.length == 0 
            if @saved = @model_obj.save
            
                # If it's a normally-formatted question, save the question choices and subquestions
                unless params["#{@model_name}_choices"].nil? || @extraction_form.id.nil?
                    QuestionBuilder.save_question_choices(params["#{@model_name}_choices"], @model_obj.id, false,params[:subquestion_text],params[:gets_sub],params[:has_subquestion], @model_name, @class_name)  
                end

                # If it's a matrix question, set up the matrix options
                unless params["#{@model_name}_matrix"].nil? || @extraction_form.id.nil?
                    allow_other_dropdown = params["#{@model_name}_matrix"]["include_other_as_option"].nil? ? false : true
                    @model_obj.include_other_as_option = allow_other_dropdown
                    @model_obj.save
                    QuestionBuilder.save_matrix_setup(params["#{@model_name}_matrix"], @model_obj.id, @model_name, @class_name)
                end
                @questions = eval(@class_name).where(:extraction_form_id => @extraction_form.id).all.sort_by{|q| q.question_number}
                @model = @model_name.dup
                @model_obj = eval(@class_name).new   
            else
                # This will utilize built in error checking from rails (defined in the model) if they exist
                errors << "#{@model_obj[0].to_s} #{@model_obj[0][0]}"
                @error_html = get_error_HTML(errors)  
            end
        else
            @error_html = get_error_HTML(errors) 
        end
    end

    def update
        @model_name = params[:page_name]
        @model_title = @model_name.split("_").collect{|x| x.capitalize}.join(" ")
        @class_name = @model_title.gsub(" ","")
        @model_obj = eval(@class_name).find(params[:qid])
        @extraction_form = ExtractionForm.find(@model_obj.extraction_form_id) 
        is_matrix = params["#{@model_name}_matrix"].nil? ? false : true
        @model_obj.is_matrix = is_matrix

        choices = []
        if params[@model_name.to_s][:field_type] == 'text'
            choices = []
        elsif is_matrix
            choices = params["#{@model_name}_matrix"] 
        else
            choices = params["#{@model_name}_choices"] ||= []    
        end

        errors = QuestionBuilder.check_inputs(params[@model_name.to_s], choices)
        if errors.length == 0
            if @saved = @model_obj.update_attributes(params[@model_name])  

                unless @model_obj.field_type == "text"
                    # If it's a normally-formatted question, save the question choices and subquestions
                    unless params["#{@model_name}_choices"].nil? || @extraction_form.id.nil?
                        QuestionBuilder.save_question_choices(params["#{@model_name}_choices"], @model_obj.id, true, params[:subquestion_text],params[:gets_sub],params["has_subquestion_#{@model_name}"], @model_name, @class_name)  
                    end

                    # If it's a matrix question, set up the matrix options
                    unless params["#{@model_name}_matrix"].nil? || @extraction_form.id.nil?
                        allow_other_dropdown = params["#{@model_name}_matrix"]["include_other_as_option"].nil? ? false : true
                        @model_obj.include_other_as_option = allow_other_dropdown
                        @model_obj.save
                        QuestionBuilder.save_matrix_setup(params["#{@model_name}_matrix"], @model_obj.id, @model_name, @class_name, true)
                    end
                else
                    # remove any fields associated with this question object in case there were any previously saved.
                    fields = eval("#{@class_name}Field").where("#{@model_name}_id"=>@model_obj.id)
                    fields.each do |field|
                    field.destroy
                end
            end   
            @model= @model_name
            @question = eval(@class_name).find(@model_obj.id)
            @questions = eval(@class_name).where(:extraction_form_id=>@extraction_form.id).order("question_number ASC")
              
        else
            # This will utilize built in error checking from rails (defined in the model) if they exist
            errors << "#{@model_obj[0].to_s} #{@model_obj[0][0]}"
            @error_html = get_error_HTML(errors)
        end
    else
          @error_html = get_error_HTML(errors) 
        end
    end

    # show_input_options
    # Show options associated with the input method they chose.
    # input method can be small_text, big_text, select, radio, checkbox
    def show_input_options
        value = params["selected"]
        @is_select = false
        @row_id = 1
        @page_name = params["page_name"] + "_choices"
        @model = params["page_name"]
        if value == "select"
        	@is_select = true
        end

        if value == "yesno"
            @div_name = "type_selector_" + @page_name
            @partial_name = "question_builder/show_yes_no_inputs"
        	@selection_field_id = "#" + @page_name + "_field_type"
            render 'question_builder/yesno_entry.js.erb'
        elsif value == "text"
    		render 'question_builder/remove_choices_entry.js.erb'
        elsif value.match("matrix") != nil
            @matrix_type = value.split("_")[1]
            render 'question_builder/matrix_questions/show_matrix_form.js.erb'
        else
            render 'question_builder/show_choices_entry.js.erb'
        end
    end

    # show_matrix_options
    # Show options for when a user decides they want to build a matrix-style question. 
    def show_matrix_options
        @checked = params[:checked]=='true' ? true : false
        @column_id = 1 
    end
 
    # Show options associated with the input method they choose.
    # for this method they are updating an already existing question/answer set
    def show_input_options_during_edit
    	@input_type = params[:selected]
    	@q_num = params[:q_num]
    	@q_id = params[:q_id]
    	@choices_div = params[:choices_div]
    	@button_id = "#q_#{@q_num.to_s}_choice_button"
    	@field_type_div = "#q_#{@q_id.to_s}_field_type_div"
    	@page_name = params['page_name'] + "_choices"
    	@model = params['page_name']
    	if @input_type == 'text'
    	   render "question_builder/disable_div.js.erb"
        elsif @input_type.match("matrix") != nil
            render 'question_builder/matrix_questions/show_matrix_form_during_edit.js.erb'
        else
    		render 'question_builder/show_choices_entry_during_edit.js.erb'
    	end
    end
 
    # add_choice
    # add a choice for the given question
    def add_choice
        @previous_id = params["previous_row"]
        @has_sub = params[:has_sub]
        @page_name = params["page_name"] + "_choices"
        @question_number = params[:question_number]
        previous_array = @previous_id.split("_")
        previous = previous_array[previous_array.length-2]
        @row_id = previous.to_i + 1
    	if params[:editing] == "true"
            @q_num = previous_array[1]
	       @partial = "question_builder/editing_option_text_input"
        else
            @partial = "question_builder/option_text_input"
        end
        render 'question_builder/add_choice.js.erb'
    end
 
    # remove_choice
    # remove a choice from the question
    def remove_choice
        unless params[:editing] == "true"
            @div_name = "row_"+params["row_num"].to_s+"_div"
        else
            @div_name = "q_"+params[:qnum].to_s+"_row_"+params["row_num"].to_s+"_div"
            print "div_name is #{@div_name.to_s}\n\n"
            @model = params[:page_name]
            obj = get_camel_caps(@model)
            field_obj = obj+"Field"
            print "\n\n\nPARAMS[:FIELD ID] is #{params[:field_id].to_s}\n\n\n"
            unless params[:field_id].nil? || params[:field_id] == "0"
            	tmp = eval(field_obj).find(params[:field_id])
            	
            	tmp.destroy()
            end
        end
        render 'question_builder/remove_choice.js.erb'
    end
 
 
  
    #shift_numbers
    # when a user selects to move a question up or down the list, update the ordering 
    def shift_numbers
        # get the number (X) off of 'question_number_X'
        @extraction_form = ExtractionForm.find(params[:extraction_form_id])
        current_number = params["selector_id"].split("_")[2]
        desired_number = params["new_row_num"]
        @model = params["page_name"]
        @model_name = @model
        @obj_name = get_camel_caps(@model)
        extraction_form = params[:extraction_form_id]
        ExtractionForm.shift_questions(current_number, desired_number, @obj_name, extraction_form)
        @questions = eval(@obj_name).where(:extraction_form_id=>params[:extraction_form_id]).order("question_number ASC")
        @div_name = "#{@model}_extraction_form_preview_table"
        @partial_name = "question_builder/extraction_form_preview"
        render "shared/render_partial.js.erb"
    end
  
  
    # cancel_editing
    # cancel the editing of question
    def cancel_editing
        @model=params[:page_name]	
        @question = eval(get_camel_caps(@model)).find(params[:qid])

        # this partial will make use of the @question and @model defined above	
        @table_container = 'question_' + @question.question_number.to_s + "_div"
        @table_partial = "question_builder/show_question"
        render "shared/saved.js.erb"
    end

    # get_subquestion_assignment
    # determine which options should have the subquestion assigned to them
    def show_subquestion_assignment
        @num_options = params[:num_options].to_i
        @div_id = params[:div_id].nil? ? "#subquestion_text_div" : params[:div_id]
        render 'question_builder/subquestions/show_subquestion_assignment'
    end
  
    # show_subquestion
    # when a user selects an radio-button-formatted answer to the question, check to see 
    # if that field has an associated subquestion. If it does, hide any previously shown 
    # fields and show the correct one.
    # The javascript rendered will change depending on the type of input being used. For 
    # example, a select element will require different actions than a radio button or checkbox.
    def show_subquestion
        @model = params[:model]
        @option_id = params[:option_id].gsub(/\\\"/,'"')
        @obj_id = params[:obj_id]

        # only the baseline characteristic will use the arm_id. leave it blank otherwise
        @group_id = params[:group_id].empty? ? params[:group_id] : "_"+params[:group_id].to_s 

        db_table = get_camel_caps(@model)
        @input_type = params[:input_type]
        puts "\n-------------------\n\nPARAMS ARE: #{params[:model]}, #{params[:option_id]}, #{params[:obj_id]}, #{params[:input_type]}\n\n\n"
        @has_sq = false
        data_field = nil
        unless @input_type == "select-one"
            data_field = eval(db_table+"Field").find(@option_id)
        else
            ref_id = @model+"_id"
            data_field = eval(db_table+"Field").where(ref_id=>@obj_id, :option_text=>@option_id)
            unless data_field.empty?
                data_field = data_field.first
            else
                data_field = nil
            end
        end
        if @input_type == "select-one"
            @element_to_fill = "#select_#{@obj_id.to_s + @group_id}_sq_span"
        else
            @element_to_fill = "#option_"+@option_id + @group_id+"_sq_span"	
        end
        unless data_field.nil?
            puts "DATA FIELD WAS FOUND\n\n"
            @has_sq = data_field.has_subquestion
            puts "HAS SUBQ is #{@has_sq}\n\n"
            @group_class = ".radio_group_#{@obj_id + @group_id}"
            puts "GROUP CLASS IS #{@group_class}\n\n"
            @option_id = data_field.id.to_s
            puts "OPTION ID IS #{@option_id}\n\n"
            if @has_sq
                @subquestion = data_field.subquestion
                if @input_type == "checkbox"
                    @checked = params[:checked]
                end
            end
        else
            puts "DATA FIELD WAS NOT FOUND"
        end

        js_partial = case @input_type
        when "radio" || "yesno"
            "question_builder/subquestions/show_subquestion_for_radio"
        when "checkbox"
            "question_builder/subquestions/show_subquestion_for_checkbox"
        when "select-one"
            "question_builder/subquestions/show_subquestion_for_select"
        else
            ""
        end
        render js_partial.to_s
    end 

    # FAQ
    def faq
        render :layout=>false
    end
end