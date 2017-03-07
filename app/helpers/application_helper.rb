# This module contains global functions for the application.
module ApplicationHelper

    require 'htmlentities'

    # return html for the "processing" message
    # @return [string] html for message
    def ajax_wait_msg text_to_display='Processing...'
        return "<img src=\"/images/waiting.gif\" alt=\"waiting\"> #{text_to_display}"
    end

    # return html for the "processing" message - smaller image variant
    # @return [string] html for message
    def ajax_wait_msg_small
        return "<img src=\"/images/waiting.gif\" style=\"display:inline\" alt=\"waiting\">"
    end

    # return the page title based on the current url
    # @return [string] page title based on url
    def get_page_title
        uri = request.request_uri
        section = uri.split("/").last
        title = case section
                    # these should be consistent now
                when "questions" then "Key Questions"
                when "publications" then "Publication Information"
                when "arms" then "Study Arms"
                when "design" then "Study Design"
                when "baselines" then "Baseline Characteristics"
                when "outcomes" then "Outcome Setup"
                when "results" then "Results"
                when "adverse" then "Adverse Events"
                when "quality" then "Study Quality"
                else ""
                end
        return title
    end

    # When a user chooses to hide the ahrq header, set a session variable to be used
    # on subsequent pages
    def toggle_ahrq_header
        print "\n\nSESSION is #{session[:ahrq_header]}\n"
        if [nil,'show'].include?(session[:ahrq_header])
            session[:ahrq_header] = 'hide'
            #print "...SETTING IT TO 'hide'\n"
        else
            session[:ahrq_header] = 'show'
            #print "...SETTING IT TO 'show'\n"
        end
    end

    # used at the top of every page (in one of the header partials)
    # displays bread crumbs based on the user's current URL
    # @param [string] url the url to get breadcrumbs for
    # @param [string] sep
    # @return [string] breadcrumbs html
    def get_bread_crumbs(url,sep)
        begin
            retVal = ""
            url.gsub!(/\?.*$/,"")
            unless url.split(/\//).length <= 3
                elements = url.split('/')
                project_id = ""
                project_title = ""
                study_id = ""
                study_title = ""
                no_match = false
                is_end_of_trail = false

                # the string to return
                retVal = image_tag("Computer-silk.png", :style=> "border: 0px; vertical-align: top", :alt => "computer") + " "
                retVal = retVal + link_to("My Work", "/") + " "

                # remove the https://www.srdr.com bit from the array
                elements = elements[3..elements.length-1]

                i = 0
                elements.each do |element|
                    if i == elements.length - 1
                        is_end_of_trail = true
                    end

                    retVal = retVal + image_tag("Silk_arrow_right_gray.png", :style=>"border: 0px; vertical-align:top;", :alt => "arrow") + " "
                    case element
                    when "extraction_forms"
                        if project_id.to_s.empty?
                            efid = elements[i+1]
                            ef = ExtractionForm.find(efid,:select=>["project_id"])
                            unless ef.nil?
                                project_id = ef.project_id
                            end
                            session[:project_id] = project_id
                        end
                        extraction_form_uri="/projects/#{project_id.to_s}/extractionforms"
                        retVal = retVal + image_tag("Table-silk.png", :style=> "border: 0px; vertical-align: top;", :alt => "table") + " " + create_crumb_link(extraction_form_uri," Extraction Forms",is_end_of_trail)
                    when "projects"
                        project_uri	= "/projects/"
                        retVal = retVal + image_tag('Folder-silk.png', :style=> "border: 0px; vertical-align: top;", :alt => "folder") + " " + create_crumb_link(project_uri, "My Projects", is_end_of_trail)
                        #print "In the projects block and retVal is now #{retVal}...\n\n"

                    when "studies"
                        study_uri = "/projects/#{project_id.to_s}/studies"
                        retVal = retVal + image_tag("Book-silk.png", :style=> "border: 0px; vertical-align: top;", :alt=>"book")  + " " + create_crumb_link(study_uri,"Studies", is_end_of_trail)

                    when "home"
                        retVal.gsub!(/\>\s$/,"")

                    when "account"
                        retVal = retVal + image_tag("User.png", :style=> "border: 0px; vertical-align: top;", :alt => "user")  + " " + create_crumb_link('/account/','Account',true) + " "

                    when "search"
                        retVal = retVal + image_tag("Zoom.png", :style=> "border: 0px; vertical-align: top;", :alt => "search")  + " " + create_crumb_link('/search/','Search',true) + " "
                        retVal.gsub!(/\>$/,"")

                    when "demo1"
                        retVal = retVal + image_tag("film.png", :style=> "border: 0px; vertical-align: top;")  + " " + create_crumb_link('/home/demo1/','Demo 1: Viewing and Creating Projects',true) + " "
                        retVal.gsub!(/\>$/,"")

                    when "demo2"
                        retVal = retVal + image_tag("film.png", :style=> "border: 0px; vertical-align: top;")  + " " + create_crumb_link('/home/demo2/','Demo 2: Creating and Editing Extraction Form Templates',true) + " "
                        retVal.gsub!(/\>$/,"")

                    when "demo3"
                        retVal = retVal + image_tag("film.png", :style=> "border: 0px; vertical-align: top;")  + " " + create_crumb_link('/home/demo3/','Demo 3: Viewing, Editing and Creating Study Records ',true) + " "
                        retVal.gsub!(/\>$/,"")

                    when /^\d+/

                        previous = elements[i-1]
                        if previous == "projects"
                            project_id = element.to_i
                            project_title = Project.find(project_id,:select=>"title")
                            unless project_title.nil?
                                project_title = project_title.title
                            else
                                project_title = "New Project"
                            end
                            project_uri = "/projects/#{project_id.to_s}/edit"
                            retVal = retVal + image_tag("Folder_edit.png", :style=> "border: 0px; vertical-align: top;") + " " + create_crumb_link(project_uri, project_title, is_end_of_trail)

                        elsif previous == "studies"
                            study_id = element.to_i
                            study_title = PrimaryPublication.find(:first,:conditions=>["study_id=?",study_id],:select=>"title")
                            unless study_title.nil?
                                study_title = study_title.title
                            else
                                study_title="New Study"
                            end
                            study_uri = "/projects/#{project_id.to_s}/studies/#{study_id.to_s}"
                            retVal = retVal + image_tag("Book_edit.png", :style=> "border: 0px; vertical-align: top;") + " " + create_crumb_link(study_uri, study_title, is_end_of_trail)

                        elsif previous == "extraction_forms"
                            extraction_form_id = element.to_i
                            extraction_form_title = ExtractionForm.find(extraction_form_id)
                            unless extraction_form_title.nil?
                                extraction_form_title = extraction_form_title.title
                            else
                                extraction_form_title = "Untitled"
                            end
                            extraction_form_uri = "/projects/#{project_id.to_s}/extraction_forms/#{extraction_form_id.to_s}/edit"
                            retVal = retVal + image_tag("Table_edit.png", :style=> "border: 0px; vertical-align: top;") + " " + create_crumb_link(extraction_form_uri,extraction_form_title,is_end_of_trail)
                        else
                            # fill this in for other types of urls
                        end
                    when /^\w+/
                        text = case element
                                   # these should be consistent now
                               when "extractionforms" then "Manage Extraction Forms"
                               when "questions" then "Key Questions"
                               when "publications" then "Publications"
                               when "arms" then "Arms"
                               when "design" then "Design Details"
                               when "baselines" then "Baseline Characteristics"
                               when "outcomes" then "Outcomes"
                               when "results" then "Outcome Data"
                               when "adverse" then "Adverse Events"
                               when "quality" then "Study Quality"
                               else element.to_s.capitalize
                               end

                    edits_arr = ["Key Questions", "Publications", "Study Arms", "Study Design", "Baseline Characteristics", "Outcomes", "Results Entry", "Adverse Events", "Study Quality"]

                    #print "Found #{element.to_s}\n\n"
                    if text == "Edit"
                        retVal = retVal + image_tag("Pencil.png", :style=> "border: 0px; vertical-align: top") + " "
                    elsif edits_arr.include?(text)
                        retVal = retVal + image_tag("Pencil.png", :style=> "border: 0px; vertical-align: top") + " " + create_crumb_link("",text,is_end_of_trail)
                    else
                        retVal = retVal + create_crumb_link("",text,is_end_of_trail)
                    end
                    retVal.gsub!(/\>\s$/,"")
                    else
                        # get rid of the trailing characters
                        # is doing two chops more efficient?
                        retVal.gsub!(/\>\s$/,"")
                        no_match = true
                    end
                    retVal = retVal + " "
                    i = i+1
                end
            end #ending the unless statement at the top
            return  retVal

        rescue
            return "Error in breadcrumbs: " + elements[elements.length-1]
        end
    end

    # a method to create each individual piece of the breadcrumb based on the uri, text for the link,
    # and whether or not we've reached the end of the breadcrumbs.
    # @param [string] uri
    # @param [string] text
    # @param [boolean] end_of_trail
    # @return [string] link
    def create_crumb_link(uri,text,end_of_trail)
        link = ""
        if end_of_trail
            #link = link_to(text.to_s, uri.to_s, :style=>"font-weight: bold")
            link = render :inline=>"<strong>#{text}</strong>"
        else
            link = link_to(shrink_text(text.to_s), uri.to_s)
        end
        return link
    end


    # shrink the text based on the number of words
    # @param [string] text
    # @param [integer] num_words number of words
    # @return [string] shrunken text
    def shrink_text(text, num_words=5)
        text = text.split[0..(num_words-1)].join(" ") + (text.split.size > num_words ? "..." : "")
        return text
    end

    # find out if any footnotes exist for this field, and if so, attach them to the
    # value that is passed back to the form field
    # @param [string] val
    # @param [string] field_name
    # @param [integer] study_id
    # @return [string]
    def show_footnotes(val, field_name, study_id)
        retVal = val.to_s
        notes_for_field = FootnoteField.where(:study_id=>study_id, :field_name=>field_name).order("footnote_number ASC")
        unless notes_for_field.empty?
            retVal += " ["
            i = 0
            notes_for_field.each do |note|
                note_num = note.footnote_number
                retVal = retVal + note_num.to_s
                unless(i >= (notes_for_field.length - 1))
                    retVal = retVal + ","
                end
                i += 1
            end
            retVal = retVal + "]"
        end
        return retVal
    end

    # based on a object ID, get the type and options and create the user input.
    # type can be: radio, text, checkbox or select
    # options will be passed in as an array
    # @param [integer] object_id
    # @param [string] model_name
    # @return [string]
    def create_input object_id, model_name, text_area_cols=66

        coder = HTMLEntities.new # create a coder to code value fields for each question

        obj_id = object_id
        obj_string = get_camel_caps(model_name)
        obj = eval(obj_string).find(obj_id)
        obj_type = obj.field_type
        subq_field_name = model_name + "_sub[" + obj_id.to_s + "]"
        editing = @study.nil?
        retVal = ""
        if obj_type.match("matrix_")
            retVal = create_matrix_input(obj, obj_type, model_name, {:editing=>editing})
        else

            # if this is a text field there are no options. otherwise, get the options
            unless obj_type == "text"
                # gather options for this field
                question_choices = eval(obj_string + "Field").where(model_name + "_id" => obj_id).order("row_number ASC")
                options = question_choices.collect{|opt| opt.option_text}

            end
            chosen_values = []
            #unless session[:study_id].nil?
            unless @study.nil?
                chosen = get_selected(obj_id, model_name, obj_string)
                chosen_values = chosen.collect{|x| x[0]}
                chosen_subqs = chosen.collect{|x| x[1]}
            end
            case obj_type
                # RADIO BUTTON INPUTS
            when "radio", "yesno"
                i=0
                options.each do |option|
                    checked = ""
                    if chosen_values.include?(option.to_s)
                        checked = "CHECKED"
                    end

                    retVal += '<input class="cbox question_radio_input editable_field" title="option" type="radio" section_name="'+model_name+'" option_id="'+question_choices[i].id.to_s+'" obj_id="'+obj.id.to_s+'" name="'+model_name+'['+obj_id.to_s+']" value="' + coder.encode(option.to_s.gsub('"','\"')) + '" ' + 'id = "' + model_name + '_' + obj_id.to_s + '" ' + checked.to_s + '> <label>' + option.to_s + '</label>'

                    if question_choices[i].has_subquestion
                        #retVal += '... <span class="radio_group_'+obj_id.to_s+'" id="option_' + question_choices[i].id.to_s + '_sq_span">'
                        retVal += "...<span class='radio_group_#{obj_id.to_s}' id='option_#{question_choices[i].id.to_s}_sq_span'>"
                        disabled = ""

                        if checked == "CHECKED"
                            subq_val = chosen_subqs[chosen_values.index(option.to_s)]
                            retVal += fill_in_subquestion(question_choices[i].subquestion, subq_val, subq_field_name, 'radio',"false")
                        else
                            retVal += fill_in_subquestion(question_choices[i].subquestion, nil, subq_field_name, 'radio',"disabled")
                        end
                        retVal += '</span>'
                    end
                    retVal += "<br/>"
                    i+=1
                end
                unless editing || obj_string.match("^Eft")
                retVal += "<br/><a href='#' class='clear_selection_link' question_name='#{model_name}[#{obj_id.to_s}]'>Clear Selections</a><br/>"
                end
                # SELECT (DROPDOWN BOX) INPUTS
            when "select"
                retVal += '<select class="question_select_input editable_field" title="Make Your Selection" section_name="'+model_name+'"  obj_id="'+obj_id.to_s+'" name="'+model_name+'['+obj_id.to_s+']" id="'+model_name+'_'+obj_id.to_s+'">'
                # NO LONGER USING THE AUTO-OTHER FIELD
                #retVal += attach_listener_for_other(model_name+"_"+obj_id.to_s)

                #some variables for showing the other fields

                # WE ARE NO LONGER USING THE 'OTHER' FIELD SINCE USERS CAN ADD THEIR OWN
                #options << 'Other'
                text_input = ""
                found_it = false
                found_at_index = -1
                i=0
                retVal += "<option value='' >-- Make Your Selection --</option>"
                options.each do |option|
                    selected = ""
                    if chosen_values.include?(option.to_s)
                        selected = "SELECTED"
                        found_it = true
                        found_at_index = i
                        # NO LONGER USING THE AUTOMATIC 'OTHER' FIELD
                        #elsif chosen_values.length > 0 && !found_it && option.to_s == "Other"
                        #	selected = "SELECTED"
                        #	text_input = get_other_input_element(chosen_values[0], obj_id.to_s, model_name)
                    end
                    continued=""
                    if !question_choices[i].nil?
                        if question_choices[i].has_subquestion
                            continued = "..."
                        end
                    end

                    retVal += '<option value="' + coder.encode(option.to_s.gsub('"','\"')) + '" ' + selected + ">" + option.to_s + continued+"</option>"
                    i+=1
                end
                retVal +="</select> &nbsp;<span id='select_" + obj_id.to_s + "_sq_span'>"
                if found_it && found_at_index > -1
                    if question_choices[found_at_index].has_subquestion
                        subq_val = chosen_subqs[chosen_values.index(options[found_at_index])]
                        retVal += fill_in_subquestion(question_choices[found_at_index].subquestion, subq_val, subq_field_name, 'select',"false")
                    end
                    ## TOOK OUT THE FOLLOWING LINES WHEN ADDING IN 'MAKE YOUR SELECTION' OPTION
                    #elsif	question_choices[0].has_subquestion
                    #	retVal += fill_in_subquestion(question_choices[0].subquestion,nil,subq_field_name,"select",false)
                end

                retVal += "</span>"
                retVal += text_input.to_s
                # CHECKBOX INPUTS
            when "checkbox"
                i=0
                options.each do |option|
                    checked = ""
                    if chosen_values.include?(option.to_s)
                        checked = "checked"
                    end
                    retVal += '<input type="checkbox"  title="option"  section_name="'+model_name+'" class="cbox question_checkbox_input editable_field" ' + checked + ' option_id="'+question_choices[i].id.to_s+'" obj_id="'+obj_id.to_s+'" name="'+model_name+'['+obj_id.to_s+'][]" id="'+model_name+'_'+obj_id.to_s+'" value="' + coder.encode(option.to_s.gsub('"','\"')) + '"> <label>' + option.to_s + '</label>'

                    if question_choices[i].has_subquestion
                        retVal += '... <span class="checkbox_group_'+obj_id.to_s+'" id="option_' + question_choices[i].id.to_s + '_sq_span">'

                        field_name = model_name + "_sub[" + obj_id.to_s + "][" + question_choices[i].id.to_s + "]"

                        if checked == "checked"
                            subq_val = chosen_subqs[chosen_values.index(option.to_s)]
                            retVal += fill_in_subquestion(question_choices[i].subquestion, subq_val, field_name, 'checkbox',"")
                        else
                            retVal += fill_in_subquestion(question_choices[i].subquestion, nil, field_name, 'checkbox',"disabled")
                        end
                        retVal += '</span>'
                    end
                    retVal += "<br/>"
                    i+=1
                end
            else
                value=""
                unless chosen_values.empty?
                    value = "value='#{chosen_values[0]}'"
                end
                #retVal += '<input type="text"" class="editable_field" id="'+model_name+'_'+obj_id.to_s+'" name="'+model_name+'[' + obj_id.to_s+ ']"' + value +'>'
                retVal += "<textarea cols=#{text_area_cols} rows=1 class='editable_field' id='#{model_name + '_' + obj_id.to_s}' name='#{model_name+'['+obj_id.to_s+']'}'>#{chosen_values.first}</textarea>"
            end
        end
        return retVal
    end

    # create_matrix_input
    # create the inputs for a matrix_radio or matrix_checkbox question
    def create_matrix_input(question, question_type, model_name, options={})
        coder = HTMLEntities.new # create a coder to code value fields for each question
        editing = options[:editing].nil? ? false : options[:editing]
        by_arm = options[:by_arm].nil? ? false : options[:by_arm]
        arm_id = options[:arm_id].nil? ? nil : options[:arm_id]
        current_arm = arm_id.nil? ? "" : "-#{arm_id}"
        #dropdown_options = options[:dropdown_options].nil? ? nil : options[:dropdown_options]
        classname = question.class.to_s

        input_type = question_type.split("_")[1]
        array_indicator = input_type == "checkbox" ? "[]" : ""
        rows = eval("#{classname}Field").find(:all, :conditions=>["#{model_name}_id=? AND row_number > ?",question.id, 0], :order=>"row_number ASC")
        cols = eval("#{classname}Field").find(:all, :conditions=>["#{model_name}_id=? AND column_number > ?",question.id, 0], :order=>"column_number ASC")
        other_rows = eval("#{classname}Field").find(:all, :conditions=>["#{model_name}_id=? AND row_number < ?",question.id, 0], :order=>"row_number DESC")
        # other_col = eval("#{classname}Field").find(:all, :conditions=>["#{model_name}_id=? AND column_number < ?",question.id, 0], :order=>"column_number DESC")
        retVal = "<table class='matrix_question' id='question_#{question.id}_matrix'>"
        unless editing
            selected_options = input_type=='select' ? get_selected_for_dropdown_matrix(question,model_name,arm_id) : get_selected_for_matrix(question,model_name,arm_id)
        end

        # add the column headers
        retVal += "<tr><td></td>"
        cols.each do |col|
            retVal += "<td class='title'><center>#{col.option_text}</center></td>"
        end
        retVal += "</tr>"

        group_names = []
        # add the rows
        rows.each do |row|

            retVal += "<tr class=#{cycle('odd','even')}><td class='title' align='left'>#{row.option_text}</td>"
            # add an input for each column
            for i in 0..cols.length - 1
                # IF WE'RE DEALING WITH A MATRIX_SELECT QUESTION
                if input_type == 'select'
                    retVal += "<td><center><label class='hidden-label'>Select a value for the #{row.option_text} row and #{cols[i].option_text}' column</label>"
                    dropdown_id = "#{model_name}_#{question.id}_#{row.id}_#{cols[i].id}#{current_arm}"
                    dropdown_name = "#{model_name}[#{question.id}_#{row.id}_#{cols[i].id}#{current_arm}]#{array_indicator}"
                    dropdown_options = []
                    
                    if classname.match("^Eft")
                        dropdown_options = EftMatrixDropdownOption.where(:row_id=>row.id, :column_id=>cols[i].id, :model_name=>model_name.gsub("eft_","")).order("option_number ASC")
                    else
                        dropdown_options = MatrixDropdownOption.where(:row_id=>row.id, :column_id=>cols[i].id, :model_name=>model_name).order("option_number ASC")
                    end

                    unless dropdown_options.empty?
                        retVal += "<select name='#{dropdown_name}' id='#{dropdown_id}'>"
                        found_selected = false
                        retVal += '<option value="" title="Select a value for the #{row.option_text} row and #{cols[i].option_text} column">Select...</option>'
                        dropdown_options.each do |dopt|
                            selected = ""
                            # get the selected value for the dropdown
                            unless editing
                                unless selected_options["#{row.id}_#{cols[i].id}#{current_arm}"].nil?
                                    if selected_options["#{row.id}_#{cols[i].id}#{current_arm}"].include?(dopt.option_text)
                                        selected = "selected='selected'"
                                        found_selected = true
                                    end
                                    #puts "------------------\n\n option value is #{dopt.option_text}\n\n"
                                end
                            end
                            retVal += '<option value="'+ coder.encode(dopt.option_text.gsub('"','\"')) + '" ' + selected + '>' + dopt.option_text + '</option>'
                        end
                        if question.include_other_as_option
                            selected = ""
                            if !found_selected && !editing && !selected_options["#{row.id}_#{cols[i].id}#{current_arm}"].nil?
                                unless selected_options["#{row.id}_#{cols[i].id}#{current_arm}"].first.blank?
                                    retVal += "<option value='other' selected='selected'>Other...</option></select>"
                                    retVal += "<span id='other_#{model_name}_#{question.id}_#{row.id}_#{cols[i].id}#{current_arm}' class='other_field' style='padding:0px;'><br/><br/>"
                                    retVal += 'Please specify: <input type="text" name="' + model_name + '[' + question.id.to_s + '_' + row.id.to_s + '_' + cols[i].id.to_s + current_arm + ']" id = "' + model_name + '_' + question.id.to_s + '_' + row.id.to_s + '_' + cols[i].id.to_s + current_arm + '_' + 'input" style="width:75%;"" title="other" value="' + selected_options["#{row.id}_#{cols[i].id}#{current_arm}"].first.strip + '" />'
                                    retVal += "</span></td>"
                                else
                                    retVal += "<option value='other'>Other...</option></select></td>"
                                end
                            else
                                retVal += "<option value='other'>Other...</option></select></td>"
                            end
                            # attach a listener to detect when a user selects 'other'
                            retVal += attach_listener_for_other(dropdown_id)
                        else
                            retVal += "</select></td>"
                        end
                    else
                        begin
                            # get the selected value for the dropdown
                            unless editing
                                value=''
                                unless selected_options["#{row.id}_#{cols[i].id}#{current_arm}"].nil?
                                    val = selected_options["#{row.id}_#{cols[i].id}#{current_arm}"].empty? ? "" : selected_options["#{row.id}_#{cols[i].id}#{current_arm}"].first
                                    val = val.nil? ? "" : val
                                    value = 'value="' + val.to_s + '"'
                                end
                            end
                            retVal += "<input type='text' name='#{dropdown_name}' id='#{dropdown_id}' style='width:100px !important;' " + value.to_s + "/></td>"
                        rescue Exception=>e
                            puts "AN ERROR OCCURED: #{e.message}\n\n#{e.backtrace}\n\n"
                        end
                    end

                    # OTHERWISE, IF IT'S A MATRIX RADIO OR MATRIX CHECKBOX...
                else
                    selector = "checked"
                    is_selected = ""
                    unless editing
                        unless selected_options[row.id].nil?
                            #puts "THE ROW ID OF #{row.id} WAS NOT NIL"
                            if selected_options[row.id].include?(cols[i].option_text.strip)
                                is_selected = selector
                            end
                        end
                    end
                    retVal += "<td><center><label class='hidden-label'>Select #{cols[i].option_text} for the #{row.option_text} row</label><input type='#{input_type}' title='select row: #{row.option_text}, column: #{cols[i].option_text}' name='#{model_name}[#{question.id.to_s}_#{row.id}#{current_arm}]#{array_indicator}' id='#{model_name}_#{question.id}_#{row.id}#{current_arm}' " + 'value="'+coder.encode(cols[i].option_text.strip.gsub('"','\"')) +'" ' + is_selected.to_s + " /></center></td>"

                end
            end
            group_names << "#{model_name}[#{question.id.to_s}_#{row.id}#{current_arm}]#{array_indicator}"
            retVal += "</tr>"
        end
        unless editing || classname.match("^Eft")
            retVal += "<tr><td colspan=#{cols.length}><a href='#' class='clear_selection_link' question_name='#{group_names.join(",")}'>Clear Selections</a></td></tr>"
        end
        # add the 'other' row option if it exists
        other_rows.each do |row|
            other_val = ""
            unless editing
                key = input_type == 'select' ? "#{row.id}_0#{current_arm}" : row.id
                puts "----- attempting to fill the 'other' row. \n\nthe keys to the selected options are:\n" + selected_options.keys.join(', ') + "\n\n"
                puts "TRYING TO FIND DATA WITH THE KEY: #{key} and the value is " + selected_options[key].to_s + " \n\n"
                other_val = selected_options[key].nil? ? "" : selected_options[key].join(", ")
                #puts "OTHER val is #{other_val}\n\n"
            end

            retVal += "<tr><td>Other<br/>(please specify):<label class='hidden-label'>Provide rows not specified in the list:</label></td><td colspan='#{cols.length}'><textarea rows=4 cols=40 name='#{model_name}[#{question.id}_#{row.id}_0#{current_arm}]' id='#{model_name}_#{question.id}_#{row.id}_0#{current_arm}'>" + other_val + "</textarea></td></tr>"
        end
        retVal += "</table>"

        return retVal
    end

    # when data has already been saved to an input, we determine whether or not there was an
    # associated subquestion and whether or not it has associated data. This function creates
    # the completed subquestion title and input field.
    # @param [string] subq_text = the subquestion itself
    # @param [string] subq_val = any subquestion value that has been entered
    # @param [string] subq_field_name = the name of the subquestion field
    # @param [string] input_type = radio, checkbox, etc.
    # @param [string] status = is it enabled or disabled
    # @return [string]
    def fill_in_subquestion(subq_text, subq_val, subq_field_name, input_type, status)
        coder = HTMLEntities.new()
        retVal = ""
        subq_text = " " if subq_text.nil?
        subq_val = subq_val.nil? ? "" : 'value="' + coder.encode(subq_val) + '"'
        disabled = status == "disabled" ? "disabled = 'disabled' class='disabled_text'" : ""
        retVal += subq_text + " <input class='editable_field' name='#{subq_field_name}' #{subq_val} #{disabled} /></span>"
    end

    # get_selected
    # get the value of the item that should be selected for any
    # of the input methods above.
    def get_selected(id, model, obj_string)
        selection = eval(obj_string + "DataPoint").where(model+"_field_id"=>id, :study_id=>session[:study_id])
        retVal = []
        unless selection.empty? || selection.nil?
            selection.each do |detail|
                retVal << [detail.value,detail.subquestion_value]
            end
        end
        return retVal
    end

    # get_selected_for_matrix
    # given a question id and model type, return the options for a given row and arm
    def get_selected_for_matrix(qid, model, arm_id=nil)
        puts "----------\nGetting selected values for a matrix.\n---------------\n\n"
        retVal = Hash.new()
        obj_string = get_camel_caps(model)
        selections = ""
        if arm_id.nil?
            selections = eval(obj_string + "DataPoint").where(model+"_field_id"=>qid, :study_id=>session[:study_id])
        else
            selections = eval(obj_string + "DataPoint").where(model+"_field_id"=>qid, :study_id=>session[:study_id], :arm_id=>arm_id)
        end

        selections.each do |sel|
            row_id = sel.row_field_id
            unless retVal.keys.include?(row_id)
                retVal[row_id] = Array.new()
            end
            retVal[row_id] << sel.value
        end
        #puts "SELECTED FOR MATRIX KEYS ARE #{retVal.keys}\n\n"
        return retVal
    end

    # get_selected_for_dropdown_matrix
    # given a question id and model type, return the options for a given row and arm
    def get_selected_for_dropdown_matrix(qid, model, arm_id=nil)
        puts "----------\nGetting selected values for a dropdown matrix.\n---------------\n\n"
        retVal = Hash.new()
        obj_string = get_camel_caps(model)
        arm_string = arm_id.nil? ? "" : "-#{arm_id}"
        selections = ""
        if arm_id.nil?
            selections = eval(obj_string + "DataPoint").where(model+"_field_id"=>qid, :study_id=>session[:study_id])
        else
            selections = eval(obj_string + "DataPoint").where(model+"_field_id"=>qid, :study_id=>session[:study_id], :arm_id=>arm_id)
        end

        selections.each do |sel|
            row_id = sel.row_field_id
            col_id = sel.column_field_id
            key = "#{row_id}_#{col_id}#{arm_string}"
            unless retVal.keys.include?(key)
                retVal[key] = Array.new()
            end
            puts "_____ ADDING A VALUE FOR ROW #{row_id} AND COLUMN #{col_id} and ARM #{arm_id}_____\n\nTHE KEY IS #{key} and VALUE IS #{sel.value}\n\nSEL.ID is #{sel.id}"
            retVal[key] << sel.value
        end
        #puts "SELECTED FOR MATRIX DROPDOWN KEYS ARE #{retVal.keys}\n\n"
        return retVal
    end

    # based on an object id, get the type and options and create the user input.
    # type can be: radio, text, checkbox or select
    # options will be passed in as an array
    # then, create the inputs; one for each arm in the study being extracted.
    # @param [integer] object_id
    # @param [integer] arm_id
    # @param [string] model_name
    def create_input_by_arm object_id, arm_id, model_name
        coder = HTMLEntities.new # create a coder to code value fields for each question
        obj_id = object_id.to_s
        obj_string = get_camel_caps(model_name)
        obj = eval(obj_string).find(obj_id)
        obj_type = obj.field_type
        subq_field_name = "#{model_name}_sub[#{obj_id.to_s}-#{arm_id.to_s}]"

        retVal = ""
        if obj_type.match("matrix_")
            # the TRUE indicates that we're creating the matrix for an arm
            retVal = create_matrix_input(obj, obj_type, model_name, {:editing=>@study.nil?, :arm_id=>arm_id})
        else
            # if this is a text field there are no options. otherwise, get the options
            unless obj_type == "text"
                # gather options for this field
                question_choices = eval(obj_string + "Field").where(model_name + "_id" => obj_id).order("row_number ASC")
                options = question_choices.collect{|opt| opt.option_text}
            end
            chosen_values = []
            unless @study.nil?
                #unless params[:study_id].nil?
                chosen = get_selected_by_arm(obj_id, arm_id, model_name, obj_string)
                chosen_values = chosen.collect{|x| x[0]}
                chosen_subqs = chosen.collect{|x| x[1]}
            end
            case obj_type

                # RADIO INPUTS (includes YES/NO)
            when "radio", "yesno"
                i=0
                # keep a list of names of each radio group for the clear link
                options.each do |option|
                    checked = ""
                    if chosen_values.include?(option.to_s)
                        checked = "CHECKED"
                    end

                    retVal += '<input class="cbox question_radio_input editable_field" title="option" section_name="'+model_name+'" type="radio" option_id="'+question_choices[i].id.to_s+'" arm_id="' + arm_id.to_s + '" obj_id="' + obj_id + '" name="'+model_name+'['+obj_id+'-'+arm_id.to_s+']" value="' + coder.encode(option.to_s.gsub('"','\"')) + '" ' + checked.to_s + '> ' + option.to_s
                    if question_choices[i].has_subquestion
                        retVal += '... <span class="radio_group_'+obj_id.to_s+'_'+arm_id.to_s+'" id="option_' + question_choices[i].id.to_s + '_'+arm_id.to_s+'_sq_span">'
                        if checked == "CHECKED"
                            subq_val = chosen_subqs[chosen_values.index(option.to_s)]
                            retVal += fill_in_subquestion(question_choices[i].subquestion, subq_val, subq_field_name, 'radio','false')
                        else
                            retVal += fill_in_subquestion(question_choices[i].subquestion, nil, subq_field_name, 'radio',"disabled")
                        end
                        retVal += '</span>'
                    end
                    retVal += "<br/>"
                    i+=1

                end
                # SELECT INPUTS
            when "select"
                retVal += '<select class="question_select_input editable_field" title="option" section_name="'+model_name+'" arm_id="' + arm_id.to_s + '" obj_id="'+obj_id.to_s+'" name="'+model_name+'['+obj_id.to_s+'-'+arm_id.to_s+']" id="'+model_name+'_'+obj_id.to_s+'-'+arm_id.to_s+'">'
                # NO LONGER USING THE AUTO-OTHER FIELD GENERATOR
                #retVal += attach_listener_for_other(model_name+"_"+obj_id.to_s+'_'+arm_id.to_s)

                #some variables for showing the other fields
                # NO LONGER USING THE 'OTHER' FIELD SINCE USERS CAN ADD IT ON THEIR OWN
                #options << 'Other'
                text_input = ""
                found_it = false
                found_at_index = -1
                i=0
                retVal += "<option value='' >-- Make Your Selection --</option>"
                options.each do |option|
                    selected = ""
                    if chosen_values.include?(option.to_s)
                        selected = "SELECTED"
                        found_it = true
                        found_at_index = i
                        # NO LONGE USING THE AUTO-OTHER FIELD
                        #elsif chosen_values.length > 0 && !found_it && option.to_s == "Other"
                        #	selected = "SELECTED"
                        #	text_input = get_other_input_element_by_arm(chosen_values[0], obj_id.to_s, arm_id.to_s, model_name)
                    end
                    continued=""
                    if !question_choices[i].nil?
                        if question_choices[i].has_subquestion
                            continued = "..."
                        end
                    end
                    retVal += '<option value="' + coder.encode(option.to_s.gsub('"','\"')) + '" ' + selected + ">" + option.to_s + continued + "</option>"
                    i+=1
                end
                retVal +="</select>&nbsp;<span id='select_#{obj_id.to_s}_#{arm_id.to_s}_sq_span'>"
                if found_it && found_at_index > -1
                    if question_choices[found_at_index].has_subquestion
                        subq_val = chosen_subqs[chosen_values.index(options[found_at_index])]
                        retVal += fill_in_subquestion(question_choices[found_at_index].subquestion, subq_val, subq_field_name, 'select','false')
                    end
                    ## TOOK THIS OUT WHEN ADDING IN THE 'MAKE YOUR SELECTION' OPTION
                    #elsif	question_choices[0].has_subquestion
                    #	retVal += fill_in_subquestion(question_choices[0].subquestion,"",subq_field_name,"select","disabled")
                end

                retVal += "</span>"
                retVal += text_input.to_s

                # CHECK BOX INPUTS
            when "checkbox"
                i=0
                options.each do |option|
                    checked = ""
                    if chosen_values.include?(option.to_s)
                        checked = "checked"
                    end
                    puts "Trying to encode the string. Option is #{option} and encoded it's #{coder.encode(option.to_s.gsub('"','\"'))}\n\n"
                    retVal += '<input class="cbox question_checkbox_input editable_field" title="option" section_name="'+model_name+'" type="checkbox" ' + checked + ' obj_id="'+obj_id.to_s+'" option_id="' + question_choices[i].id.to_s + '" name="'+model_name+'['+obj_id.to_s+'-'+arm_id.to_s+'][]" arm_id="'+arm_id.to_s+'" id="'+model_name+'_'+obj_id.to_s+'" value="' + coder.encode(option.to_s.gsub('"','\"')) + '"> ' + option.to_s

                    if question_choices[i].has_subquestion
                        retVal += '... <span class="checkbox_group_'+obj_id.to_s+'_'+arm_id.to_s+'" id="option_' + question_choices[i].id.to_s + '_' + arm_id.to_s + '_sq_span">'
                        field_name = "#{model_name}_sub[#{obj_id.to_s}-#{arm_id.to_s}][#{question_choices[i].id.to_s}]"
                        if checked == "checked"
                            subq_val = chosen_subqs[chosen_values.index(option.to_s)]
                            retVal += fill_in_subquestion(question_choices[i].subquestion, subq_val, field_name, 'checkbox','false')
                        else
                            retVal += fill_in_subquestion(question_choices[i].subquestion, nil, field_name, 'checkbox',"disabled")
                        end
                        retVal += '</span>'
                    end
                    retVal += "<br/>"
                    i+=1
                end

            else
                value=""

                unless chosen_values.empty?
                    value = "#{chosen_values[0]}"
                end
                retVal += "<textarea cols='75' rows='1' class='editable_field' name='#{model_name}[#{obj_id.to_s}-#{arm_id.to_s}]' id='#{model_name}_#{obj_id.to_s}-#{arm_id.to_s}' value='#{value}'>#{value}</textarea><br/>"
            end
        end
        return retVal
    end


    # get_other_input_element_by_arm
    # if other is selected, create a text input. populate it with the value and name it
    # accordingly
    # @param [string] value
    # @param [integer] id
    # @param [Arm] arm
    # @param [string] model
    # @return [string]
    def get_other_input_element_by_arm(value, id, arm, model)
        element_name = model + '[' + id.to_s + '_' + arm.to_s + ']'
        element_id = model + "_" + id.to_s + '_' + arm.to_s + "_input"
        span_id = 'other_'+model+'_' + id.to_s + '_' + arm.to_s
        input_string = '<br/><span id="'+span_id+'">Please Specify:<input class="editable_field" title="option" type="text" name="'+element_name+'" id="'+element_id+'" value="'+value+'" /></span>'
        return input_string
    end


    # get the value of the item that should be selected for any
    # of the input methods above when they are entered for each arm.
    # @param [integer] id
    # @param [Arm] arm
    # @param [string] model
    # @param [string] obj_string
    # @return [string]
    def get_selected_by_arm(id, arm, model, obj_string)
        selection = eval(obj_string + "DataPoint").where(model+"_field_id"=>id, :arm_id=>arm,:study_id=>session[:study_id])

        retVal = []
        unless selection.empty?
            selection.each do |detail|
                retVal << [detail.value, detail.subquestion_value]
            end
        end
        return retVal
    end

    # if other is selected, create a text input. populate it with the value and name it
    # accordingly
    # @param [string] value
    # @param [integer] id
    # @param [string] model
    # @return [string]
    def get_other_input_element(value, id, model)
        element_name = model + '[' + id.to_s + ']'
        element_id = model + "_" + id.to_s + "_input"
        span_id = 'other_'+model+'_' + id.to_s
        input_string = '<br/><span id="'+span_id+'">Please Specify:<input class="editable_field" title="option" type="text" name="'+element_name+'" id="'+element_id+'" value="'+value+'" /></span>'
        return input_string
    end

    # a camelcaps function to accept the model as input and return a representation that can be called
    # with eval to hit the database table.
    # example: design_detail would give DesignDetail
    # @param [string] input
    # @return [string]
    def get_camel_caps input
        tmp = input.split("_")
        tmp.each do |x|
            x.downcase!
            x.capitalize!
        end
        return tmp.join("")
    end

    # adds a javascript/jquery ajax listener for fields with 'other' item in a dropdown menu
    # @param [string] item_id
    # @return [string] javascript listener to return
    def attach_listener_for_other item_id, field_size="small"

        js = '<script>' + '$("#' + item_id + '").unbind(); $("#' + item_id + '").bind("change",function(event) { $.ajax({url: "/application/show_other",data: {"field_id":this.id, "field_name":this.name, "field_size":"'+field_size+'", "selected":this.value}});});</script>'
        return js
    end

    # show_other_filled
    # Use this function when a user has selected 'other' from a dropdown list and the input box with the actual result
    # that they entered needs to be rendered.
    def show_other_filled field_id, value, field_name
        coder = HTMLEntities.new # create a coder to code value fields for each question
        retVal = '<span id="other_'+field_id+'" class="other_field" style="padding:0px;"><br/><br/>Please specify:'
        retVal += '<input id="' + field_id + '_input" type="text" title="other" style="width:75%;" name="' + field_name + '" value = "' + coder.encode(value) + '"></span>'
        return retVal
    end


    # create back and continue links for a study extraction form page
    # depending on the current page and the extraction form id
    # @param [integer] form_id
    # @param [string] current_page
    # @return [string] back and continue links based on inputs
    def create_back_and_continue_for_study form_id, current_page
        # determine which sections are included in the extraction form and assign them to an array
        # order the included pages
        included_sections = ExtractionFormSection.where(:extraction_form_id=>form_id, :included=>"t")
        page_names = included_sections.collect{|x| x.section_name}
        page_names = ["publications"] + page_names

        titles = {
            "arms"=>"Study Arms",
            "design"=>"Design Details",
            "baselines"=>"Baseline Characteristics",
            "outcomes"=>"Outcome Setup",
            "results"=>"Outcome Results",
            "adverse"=>"Adverse Events",
            "quality"=>"Study Quality"
        }
        # find the current page in the array
        position = page_names.index(current_page)

        # get the previous page info
        # if there are no more entries before this one, link back to the edit instructions
        previous_url = ""
        previous_title = ""
        if position == 0 || position.nil?
            previous_url = "edit"
        elsif position == 1
            previous_url = '../../publications'
            previous_title = 'Extraction Form List'
        else
            # otherwise get the previous entry and title
            previous_url = page_names[position-1]
            previous_title = titles[previous_url]
        end

        # get the next page info
        # if there are no entries after this one, link to the summary page
        next_url = ""
        next_title = ""
        if position == 0 || position.nil?
            next_url = "extraction_forms/#{form_id}/#{page_names[1]}"
            next_title = titles[page_names[1]]
        elsif position == page_names.length-1
            next_url = "summary"
        else
            next_url = page_names[position+1]
            next_title = titles[next_url]
        end

        if previous_url == "edit"
            render :partial=>"studies/first_section_back_buttons", :locals=>{:next_url=>next_url, :next_title=>next_title}
        elsif next_url == "summary"
            render :partial=>"studies/last_section_continue_buttons",:locals=>{:previous_url=>previous_url, :previous_title=>previous_title}
        else
            render :partial=>'studies/back_and_continue_buttons', :locals=>{:previous_url=>previous_url,:next_url=>next_url,:previous_title=>previous_title,:next_title=>next_title}
        end
    end

    # return an array indicating the section we're in as well as the ID of whatever
    # area we're looking at. The ID should be for a project, a study, or an extraction form.
    # @param [string] request
    # @return [array] returns an array containing: object type (extraction_form_id, study_id or project_id), object id and page name
    def get_page_info(request)
        request = request.split("/")
        obj_type = nil
        obj_id = nil
        page_name = nil

        if request.include?("extraction_forms")
            obj_type = "extraction_form_id"
            obj_id = request[request.index("extraction_forms")+1]
            page_name = request[request.length-1].to_s

        elsif request.include?("studies") && (request.index("studies") < request.length-1)
            obj_type = "study_id"
            obj_id = request[request.index("studies") + 1]
            page_name = request[request.length-1].to_s

        elsif request.include?("projects") && (request.index("projects") < request.length-1)
            obj_type = "project_id"
            obj_id = request[request.index("projects") + 1]
            page_name = request[request.length-1].to_s
        else

        end
        return [obj_type, obj_id, page_name]
    end

    # remove p tags from the beginning and end of key questions
    # @param [string] mytext
    # @return [string]
    def remove_paragraph_tags mytext
        mytext.sub!(/^<p>\s*<\/p>/,"")
        mytext.sub!(/(<br>)*<p>\s*<\/p>$/,"")
        mytext.sub!(/^<p>/,'')
        mytext.sub!(/<\/p>?/,'')
        return mytext
    end

    # given a project id, study id, extraction form id and page name, create a link
    # @param [integer] pid
    # @param [integer] sid
    # @param [integer] eid
    # @param [string] name
    # @return [string] url for study entry
    def get_study_entry_url(pid, sid, eid, name)
        return "/projects/#{pid.to_s}/studies/#{sid.to_s}/extraction_forms/#{eid.to_s}/#{name}"
    end

    # return image url based on source
    # @param [string] source
    # @return [string] url for image
    def image_url(source)
        abs_path = image_path(source)
        unless abs_path =~ /^http/
            abs_path = "#{request.protocol}#{request.host_with_port}#{abs_path}"
        end
        abs_path
    end

    # match the study url suffix to the name of the section
    # @param [string] input
    # @return [string]
    def match_extraction_form_section input
        section = case input
                      # these should be consistent now
                  when "questions" then "Assign Key Questions"
                  when "publications" then "Publications"
                  when "arms" then "Study Arms"
                  when "design" then "Design Details"
                  when "baselines" then "Baseline Characteristics"
                  when "outcomes" then "Outcome Setup"
                  when "results" then "Outcome Data"
                  when "adverse" then "Adverse Events"
                  when "quality" then "Study Quality"
                  when "import" then "Import from Previous Forms"
                  else input.to_s.capitalize
                  end
        return section
    end

    # build the default quality dimensions list
    def default_quality_dimensions_dropdown(options={:form_type=>"RCT", :include_custom=>false, :desired_id=>'desired_dimensions', :desired_name=>'desired_dimensions'})
        form_type = options[:form_type]
        include_custom = options[:include_custom]
        desired_id = options[:desired_id]
        desired_name = options[:desired_name]
        retVal = "<select id='#{desired_id}' name='#{desired_name}' style='width:300px;'><option value='' selected>Choose a quality dimension</option>"  
        if include_custom 
            retVal += "<option value='custom'>Create a Custom Quality Dimension</option>"
        end
        diagnostic_fields = ["Stard - quality for diagnostic tests","QUADAS2"]
        fn = File.dirname(File.expand_path(__FILE__)) + '/../../config/quality_dimensions.yml'
        dimensions_file = YAML::load(File.open(fn))

        if (defined?(dimensions_file) && !dimensions_file.nil?)
            # go through quality_dimensions.yml
            dimensions_file.each do |section|
                unless form_type == "diagnostic" && !diagnostic_fields.include?(section['section-title'])
                    retVal += "<option value='section_#{section['id']}'>-------- #{section['section-title']} --------</option>"
                    if defined?(section['dimensions']) && !section['dimensions'].nil?
                        section['dimensions'].each do |dimension|
                            retVal += "<option value='#{dimension['id']}'>#{dimension['question']} "
                            opts = []
                            if !dimension['options'].nil?
                                dimension['options'].each do |option|
                                    o = option['option']
                                    o += "..." unless option['follow-up'].nil?
                                    opts << o
                                end
                            end
                            unless opts.empty?
                                retVal += "[" + opts.join(", ") + "]</option>"
                            end
                        end
                        # add "add all section X dimensions" link
                        retVal += "<option value='section_#{section['id']}'>Add all #{section['section-title']} Dimensions</option>"
                    end
                end
            end
        end
        retVal += "</select>"
        return retVal 
    end

    def loadDescription(file)
        description = ''
        f = File.open(file, "r")
        f.each_line do |line|
            description += line if line.match(/DESC/)
        end
        return description.match(/DESC:(.*)/).captures[0]
    end

end
