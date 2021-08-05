# this controller handles creation and destruction of key questions. This is done on the projects/new page and projects/edit page.  
#
# When a new project is being created, the project does not have an ID before the user presses save, so the key question is saved
# with a project ID of (-1)*(current_user.id). When the project is saved and gets a project id, the key_question.project_id is updated.
class KeyQuestionsController < ApplicationController
before_filter :require_user

	  # create a new key question. 
	  # renders shared/render_partial.js.erb
	  def new
	  	#puts "------------\nIn the Key Questions Controller, creating a new key question.\n\n"
	    @editing = false
	    @key_question = KeyQuestion.new
		project_id = params[:project_id].to_i
		@project_id = project_id
		if (project_id > 0)
			@project = Project.find(project_id)
			@project_id = @project.id
		else
			@recent_kq = KeyQuestion.where(:project_id => current_user.id * -1).first
			if !@recent_kq.nil?
				@project_id = @recent_kq.project_id
			else
				@project_id = current_user.id * -1		
			end
		end	
		@key_question.project_id = project_id
  	end
  
	  # edit an existing key question. 
	  # renders key_questions/edit.js.erb
	  def edit
	    @editing = true
	    @key_question = KeyQuestion.find(params[:id])
		if (@key_question.project_id > 0)
			@project = Project.find(@key_question.project_id)
			@project_id = @project.id
			@key_questions = KeyQuestion.where(:project_id => @project.id).all.sort_by{|obj|obj.question_number}				
		else
			num = @key_question.project_id
			@project_id = num
			@key_questions = KeyQuestion.where(:project_id => num).all.sort_by{|obj|obj.question_number}			
		end
		@key_question.question = clean_kq_input(@key_question.question)
		@has_extraction_form = KeyQuestion.has_extraction_form(@key_question.id)
 	 end
	
	# save a new key question. 
	# renders shared/saved.js.erb
  	def create
		@key_question = KeyQuestion.new(params[:key_question])
		@key_question.question = clean_kq_input(@key_question.question)
		proj_id = params[:key_question][:project_id].to_i
		if ((proj_id.nil?) || (proj_id == "") || (proj_id < 0))
			num = current_user.id * -1
			@key_question.project_id = num
			question_number = @key_question.get_question_number(num)
			@key_question.question_number = question_number				
		else
			@key_question.project_id = proj_id
			@project = Project.find(proj_id)
			question_number = @key_question.get_question_number(@project.id)
			@key_question.question_number = question_number
		end	
		if (@saved = @key_question.save)
			if ((proj_id.nil?) || (proj_id == "") || (proj_id < 0))
				num = current_user.id * -1
				@key_questions = KeyQuestion.where("project_id = ?", num).all.sort_by{|obj|obj.question_number}			
			else
				@project = Project.find(proj_id)			
				@key_questions = KeyQuestion.where("project_id = ?", @project.id).all.sort_by{|obj|obj.question_number}
			end
		else
			error_msg = create_error_message_html(@key_question.errors)
			flash[:modal_error] = error_msg
		end
		@editing = false  	
  	end
  
	# update an existing key question. 
	# renders shared/saved.js.erb
	  def update
	    @key_question = KeyQuestion.find(params[:id])
			proj_id = @key_question.project_id

			if (@saved = @key_question.update_attributes(params[:key_question]))
				@key_question.question = clean_kq_input(params[:key_question][:question])
				@key_question.save
				if @key_question.project_id > 0
					num = Project.find(proj_id)
					@project = Project.find(proj_id)
				else
					num = current_user.id * -1		
				end			
		
				@key_questions = KeyQuestion.where("project_id = ?", num).all.sort_by{|obj|obj.question_number}
				@key_question = KeyQuestion.new
				@message_div = 'saved_indicator_1'
			else
				@modal_error_div = "#validation_message"
				error_msg = create_error_message_html(@key_question.errors)
				flash[:modal_error] = error_msg
			end
		  @editing = false	
	  end

	# delete an existing key question. 
	# renders shared/render_partial.js.erb
	  def destroy
	    @editing = false
	    @key_question = KeyQuestion.find(params[:id])
	    proj_id = @key_question.project_id
	    if proj_id < 0
	    	@key_question.shift_question_numbers(@key_question.project_id)
	    	@key_question.remove_from_junction
	    	@key_question.destroy
	    	@key_questions = KeyQuestion.where(:project_id=>proj_id).all.sort_by{|obj|obj.question_number}
	    	@key_question = KeyQuestion.new
	    else
	    	@project = Project.find(proj_id)
	    	questions = @project.key_questions
	    	if !questions.nil? && questions.length > 1
	    		@key_question.shift_question_numbers(@key_question.project_id)
	    		@key_question.remove_from_junction
	    		@key_question.destroy
	    		@key_questions = KeyQuestion.where(:project_id=>proj_id).all.sort_by{|obj|obj.question_number}
	    		@key_question = KeyQuestion.new
	    	else
	    		flash[:error_message] = "A project is required to have at least one associated key question."
	    	end
	    end
	end

	# move a key question up in the list. 
	# increase its display_number to X, then decrease the former Xth question's display number. 
	# renders shared/render_partial.js.erb
	def moveup
		@editing = false
	    	@key_question = KeyQuestion.find(params[:id])
		prj_id = @key_question.project_id
		KeyQuestion.move_up_this(@key_question.id, prj_id)
		if prj_id > 0
			@project = Project.find(prj_id)
		end
		@key_questions = KeyQuestion.where(:project_id=>prj_id).all.sort_by{|obj|obj.question_number}
		@key_question = KeyQuestion.new
  	end
 
	  # remove excessive html formatting from the beginning and end of key questions
	  def clean_kq_input kq_string
	  	retVal = kq_string.sub(/^<p>\s*<\/p>/,"")
	  	retVal = retVal.sub(/(<br>)*<p>\s*<\/p>$/,"")
	  	retVal = retVal.sub(/^<p>/,"")
	  	retVal = retVal.sub(/<\/p>$/,"")
	  	retVal = retVal.gsub(/</,"&lt;")
	  	retVal = retVal.gsub(/>/,"&gt;")
	  	return retVal
	  end
	end
