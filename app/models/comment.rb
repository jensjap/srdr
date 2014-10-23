# == Schema Information
#
# Table name: comments
#
#  id                    :integer          not null, primary key
#  comment_text          :text
#  commenter_id          :integer
#  fact_or_opinion       :string(255)
#  post_type             :string(255)
#  is_public             :boolean
#  is_reply              :boolean
#  reply_to              :integer
#  value_at_comment_time :text
#  is_flag               :boolean
#  flag_type             :string(255)
#  is_high_priority      :boolean
#  created_at            :datetime
#  updated_at            :datetime
#  section_name          :string(255)
#  section_id            :integer
#  field_name            :string(255)
#  study_id              :integer
#  project_id            :integer
#

# The comment model handles showing, adding, and deleting comments and flags, and summaries of comments and flags. 
class Comment < ActiveRecord::Base
	validates :comment_text, :presence => true

	# return a string of the first and last name of the user used to call this function.
	# e.g. @user.get_user_name returns @user.fname + @user.lname
	# @return [string] retVal - a string containing the users first and last name in a readable format
	def get_user_name
		retVal = "User Not Found"
		user_id = self.user_id
		user = User.find(user_id, :select=>["fname","lname"])
		unless user.nil?
			retVal = user.fname + " " + user.lname
		end
		return retVal
	end
	
	# get number of comments based on variables given (from the page or section),
	# and whether to show both (show_both) - both public and private.
	# @param [String] section_name the name of the general section where the field is (example: projects, arms, studies, adverseevents, designdetails, baselinecharacteristics, keyquestions, primarypublications, secondarypublications, qualitydimensions, qualityratings)
	# @param [Integer] section_id the item_id of the section. (example: project id, keyquestion id, arm id)
	# @param [String] field_name the name of the field where the comment will be (example: [project] title, [keyquestion] question)
	# @param [Integer] study_id the id of the study where the field is (-1 if the field is in a project)
	# @param [Integer] project_id the id of the project where the field is.	
	# @param [Boolean] show_both true if you want to show public and private comments, false if you want to show only private comments
	# @return [Integer] num_comments number of comments
	def self.get_number_of_comments(section_name, section_id, field_name, study_id, project_id, show_both)
		is_public = [true]
		if show_both
			is_public << false
		end
		num_comments = Comment.count(:conditions=>["section_name=? AND section_id=? AND field_name=? AND "\
			    " study_id=? AND project_id=? AND is_reply=? AND is_flag=? AND is_public IN (?) AND post_type=?",
				section_name, section_id, field_name, study_id, project_id, false, false, is_public, "REVIEWED"])
		return num_comments
	end
	
	# get number of public comments based on variables given (from the page or section)
	# @param [String] section_name the name of the general section where the field is (example: projects, arms, studies, adverseevents, designdetails, baselinecharacteristics, keyquestions, primarypublications, secondarypublications, qualitydimensions, qualityratings)
	# @param [Integer] section_id the item_id of the section. (example: project id, keyquestion id, arm id)
	# @param [String] field_name the name of the field where the comment will be (example: [project] title, [keyquestion] question)
	# @param [Integer] study_id the id of the study where the field is (-1 if the field is in a project)
	# @param [Integer] project_id the id of the project where the field is.	
	# @return [Integer] num_comments number of comments	
	def self.get_number_of_public_comments(section_name, section_id, field_name, study_id, project_id)
			num_comments = Comment.count(:conditions=>["section_name=? AND section_id=? AND field_name=? AND study_id=? AND project_id=? AND "\
					"is_reply=? AND is_public=? AND post_type=?",section_name,section_id,field_name,study_id,project_id,false,true,"REVIEWED"])
			
			return num_comments
	end	
	
	# get number of private comments based on variables given (from the page or section) 
	# @param [String] section_name the name of the general section where the field is (example: projects, arms, studies, adverseevents, designdetails, baselinecharacteristics, keyquestions, primarypublications, secondarypublications, qualitydimensions, qualityratings)
	# @param [Integer] section_id the item_id of the section. (example: project id, keyquestion id, arm id)
	# @param [String] field_name the name of the field where the comment will be (example: [project] title, [keyquestion] question)
	# @param [Integer] study_id the id of the study where the field is (-1 if the field is in a project)
	# @param [Integer] project_id the id of the project where the field is.	
	# @return [Integer] num_comments number of comments		
	def self.get_number_of_private_comments(section_name, section_id, field_name, study_id, project_id)
			num_comments = Comment.count(:conditions=>["section_name=? AND section_id=? AND field_name=? AND study_id=? AND project_id=? AND "\
					"is_reply=? AND is_public=? AND post_type=?",section_name,section_id,field_name,study_id,project_id,false,false,"REVIEWED"])
			return num_comments
	end		
	
	# get number of flags based on variables given (from the page or section) 
	# and whether to show both (show_both) - both public and private
	# @param [String] section_name the name of the general section where the field is (example: projects, arms, studies, adverseevents, designdetails, baselinecharacteristics, keyquestions, primarypublications, secondarypublications, qualitydimensions, qualityratings)
	# @param [Integer] section_id the item_id of the section. (example: project id, keyquestion id, arm id)
	# @param [String] field_name the name of the field where the comment will be (example: [project] title, [keyquestion] question)
	# @param [Integer] study_id the id of the study where the field is (-1 if the field is in a project)
	# @param [Integer] project_id the id of the project where the field is.	
	# @param [Boolean] show_both true if you want to show public and private comments, false if you want to show only private comments	
	# @return [Integer] num_flags number of flags		
	def self.get_number_of_flags(section_name, section_id, field_name, study_id, project_id, show_both)
		is_public_search = show_both ? [true, false] : [false]
		return Comment.count(:conditions=>["section_name=? AND section_id=? AND field_name=? AND study_id=? "\
										   "AND project_id=? AND is_reply=? AND is_flag=? AND is_public IN (?) "\
										   " AND post_type=?", section_name, section_id, field_name, study_id,
										   project_id, false, true, is_public_search, "REVIEWED"])
=begin
		if (!show_both)	
			@comments = Comment.where(:section_name => section_name, :section_id => section_id, :field_name => field_name, :study_id => study_id, :project_id => project_id, :is_reply => false, :is_flag => true, :is_public => true, :post_type => "REVIEWED")	
			
		else
			@comments = Comment.where(:section_name => section_name, :section_id => section_id, :field_name => field_name, :study_id => study_id, :project_id => project_id, :is_reply => false, :is_flag => true, :post_type => "REVIEWED").all	
			return @comments.length		
		end
=end
	end	
	
	
	# for project summary
	# shows all information about where the comment is located in one string
	# @param [Integer] comment_id the id of the comment to get info for
	# @return [String] comment_info detailed info about comment location in a readable format for the summary section
	def self.get_location_string(comment_id)
		string = "<strong>Posted to:</strong> "
		@sub = Comment.get_project_string(comment_id)
		prev = false
		if (@sub != "")
			string = string + @sub
			prev = true
		end
		@sub = Comment.get_study_string(comment_id)		
		if (@sub != "")
			if prev
				string = string + "<br/><strong>Study:</strong> " + @sub
			else
				string = string + @sub			
			end
			prev = true			
		end
		@sub = Comment.get_section_string(comment_id)		
		if (@sub != "")
			if prev
				string = string + "<br/><strong>Section:</strong> " + @sub
			else
				string = string + @sub			
			end
			prev = true			
		end		
		@sub = Comment.get_field_string(comment_id)		
		if (@sub != "")
			if prev
				string = string + "<br/><strong>Field:</strong> " + @sub
			else
				string = string + @sub			
			end
			prev = true			
		end				
		return string
	end
	
	# returns a string of the project name based on the comment_id
	# @param [Integer] comment_id the id of the comment to get info for
	# @return [String] project_name name of the comment's project
	def self.get_project_string(comment_id)
		@comment = Comment.find(comment_id)
		@string = ""
		@project = Project.find(@comment.project_id)
		if !@project.nil?
			@string = @string + @project.title
		end
		return @string
	end
	
	# returns a string of the section name based on the comment_id
	# @param [Integer] comment_id the id of the comment to get info for
	# @return [String] section_name name of the comment's section	
	def self.get_section_string(comment_id)
		@comment = Comment.find(comment_id)
		@string = ""
		case @comment.section_name
			when "keyquestions"
				@string = @string + "Key Question"
				@kq = KeyQuestion.find(@comment.section_id)
				@string = @string + " " + @kq.question_number.to_s
				return @string				
			when "arms"
				@arm = Arm.find(@comment.section_id)
				@string = @string + "Arm: " + @arm.title
				return @string				
			when "secondarypublications"
				@sp = SecondaryPublication.find(@comment.section_id)
				@string = @string + "Secondary Publication"
				return @string				
			when "primarypublications"
				@pp = PrimaryPublication.find(@comment.section_id)
				@string = @string + "Primary Publication"
				return @string				
			when "adverseevents"
				@ae = AdverseEvent.find(@comment.section_id)
				@string = @string + "Adverse Event: " + @ae.title
				return @string				
			when "designdetails"
				@dd = DesignDetail.find(@comment.section_id)
				@string = @string + "Design Detail: " + @dd.question
				return @string				
			when "baselinecharacteristics"
				@bc = BaselineCharacteristic.find(@comment.section_id)
				@string = @string + "Baseline Characteristics: " + @bc.question	
				return @string				
			when "qualitydimensions"
				@qd = QualityDimensionDataPoint.find(@comment.section_id)
				@qd_field = QualityDimensionField.where(:quality_dimension_field => @qd.quality_dimension_field_id).first
				@string = @string + "Quality Dimension: " + @qd.title			
				return @string								
			when "qualityratings"
				@string = @string + "Quality Rating"
				return @string				
			else
				@string = @string + ""
				return @string				
			end
	end
	
	
	# returns a string of the study name based on the comment_id
	# @param [Integer] comment_id the id of the comment to get info for
	# @return [String] study_name name of the comment's study		
	def self.get_study_string(comment_id)
		@comment = Comment.find(comment_id)
		@string = ""
		if (@comment.study_id != -1)
			@study = Study.find(@comment.study_id)
			@string = @string + Study.get_title(@study.id)
		end
		return @string
	end
	
	# returns a string of the field name based on the comment_id
	# @param [Integer] comment_id the id of the comment to get info for
	# @return [String] field_name name of the comment's field		
	def self.get_field_string(comment_id)
		@comment = Comment.find(comment_id)
		@string = ""
		@string = @string + @comment.field_name
		return @string		
	end
	
	# returns the number of public comments on a particular project
	# for the project comment/flag summary
	# @param [Integer] project_id the id of the project to get a number of comments for
	# @return [Integer] num number of comments in the project	
	def self.get_number_of_public_project_comments(project_id)
			@comments = Comment.where(:project_id => project_id, :is_reply => false, :is_public => true, :post_type => "REVIEWED").all
			return @comments.length
	end		
	
	# returns the number of private comments on a particular project
	# for the project comment/flag summary
	# @param [Integer] project_id the id of the project to get a number of comments for
	# @return [Integer] num number of comments in the project	
	def self.get_number_of_private_project_comments(project_id)
			@comments = Comment.where(:project_id => project_id, :is_reply => false, :is_public => false, :post_type => "REVIEWED").all
			return @comments.length
	end			
	
	# returns the number of all comments on a particular project, 
	# dependent on whether to show both public and private (show_both)
	# for the project comment/flag summary
	# @param [Integer] project_id the id of the project to get a number of comments for
	# @param [boolean] show_both true if you want to show public and private comments, false if you want to show only private comments
	# @return [Integer] num number of comments in the project	
	def self.get_number_of_project_comments(project_id, show_both)
		if (!show_both)
			@comments = Comment.where(:project_id => project_id, :is_reply => false, :is_flag => false, :is_public => true, :post_type => "REVIEWED").all
			return @comments.length		
		else
			@comments = Comment.where(:project_id => project_id, :is_reply => false, :is_flag => false, :post_type => "REVIEWED").all
			return @comments.length			
		end
	end
	
	# returns the number of all flags on a particular project, 
	# dependent on whether to show both public and private (show_both)
	# for the project comment/flag summary
	# @param [Integer] project_id the id of the project to get a number of flags for
	# @param [boolean] show_both true if you want to show public and private flags, false if you want to show only private flags
	# @return [Integer] num number of flags in the project		
	def self.get_number_of_project_flags(project_id, show_both)
		if (!show_both)	
			@comments = Comment.where(:project_id => project_id, :is_reply => false, :is_flag => true, :is_public => true, :post_type => "REVIEWED").all	
			return @comments.length
		else
			@comments = Comment.where(:project_id => project_id, :is_reply => false, :is_flag => true, :post_type => "REVIEWED").all	
			return @comments.length		
		end
	end		
	
	# returns an array of all comments on a particular project,
	# dependent on whether to show both public and private (show_both)
	# and how to sort them (sort_by). 
	# for the project comment/flag summary
	# @param [Integer] project_id the id of the project to get a number of comments for
	# @param [boolean] show_both true if you want to show public and private comments, false if you want to show only private comments
	# @param [string] sort_by a string that determines the sorting order of the comment list returned
	# @return [Array] comments the sorted list of comments		
	def self.get_project_comments_and_flags(project_id, show_both, sort_by)
		if !show_both
			case sort_by
				when "type"
					@comments = Comment.where(:is_reply => false, :project_id => project_id, :is_public => true, :post_type => "REVIEWED").order("is_flag DESC, created_at DESC").all		
					return @comments										
				when "priority"	
					@comments = Comment.where(:is_reply => false, :project_id => project_id, :is_public => true, :post_type => "REVIEWED").order("is_flag DESC, is_high_priority DESC").all		
					return @comments														
				when "oldest"
					@comments = Comment.where(:is_reply => false, :project_id => project_id, :is_public => true, :post_type => "REVIEWED").order("created_at ASC").all
					return @comments					
				when "facts"
					@comments = Comment.where(:is_reply => false, :project_id => project_id, :is_public => true, :post_type => "REVIEWED").order("fact_or_opinion DESC").all		
					return @comments										
				when "flagtype"
					@comments = Comment.where(:is_reply => false, :project_id => project_id, :is_public => true, :post_type => "REVIEWED").order("is_flag DESC, flag_type ASC").all
					return @comments					
				when "public"
					@comments = Comment.where(:is_reply => false, :project_id => project_id, :is_public => true, :post_type => "REVIEWED").order("is_public DESC").all		
					return @comments										
				when "study"
					@comments = Comment.where(:is_reply => false, :project_id => project_id, :is_public => true, :post_type => "REVIEWED").order("study_id ASC").all		
					return @comments
				when "section"
					@comments = Comment.where(:is_reply => false, :project_id => project_id, :is_public => true, :post_type => "REVIEWED").order("section_name ASC").all		
					return @comments					
				else
					#recent
					@comments = Comment.where(:is_reply => false, :project_id => project_id, :is_public => true, :post_type => "REVIEWED").order("created_at DESC").all		
					return @comments					
			end
		else
			case sort_by
				when "type"	
					@comments = Comment.where(:project_id => project_id, :is_reply => false, :post_type => "REVIEWED").order("is_flag DESC, created_at DESC").all		
					return @comments										
				when "priority"		
					@comments = Comment.where(:project_id => project_id,:is_reply => false, :post_type => "REVIEWED").order("is_high_priority DESC").all			
					return @comments																			
				when "oldest"
					@comments = Comment.where(:is_reply => false, :project_id => project_id, :post_type => "REVIEWED").order("created_at ASC").all
					return @comments					
				when "facts"
					@comments = Comment.where(:is_reply => false, :project_id => project_id, :post_type => "REVIEWED").order("fact_or_opinion DESC").all			
					return @comments					
				when "flagtype"
					@comments = Comment.where(:is_reply => false, :project_id => project_id, :post_type => "REVIEWED").order("flag_type ASC").all
					return @comments										
				when "public"
					@comments = Comment.where(:is_reply => false, :project_id => project_id, :post_type => "REVIEWED").order("is_public DESC").all				
					return @comments					
				when "study"
					@comments = Comment.where(:is_reply => false, :project_id => project_id, :post_type => "REVIEWED").order("study_id DESC").all				
					return @comments	
				when "section"
					@comments = Comment.where(:is_reply => false, :project_id => project_id, :post_type => "REVIEWED").order("section_name ASC").all		
					return @comments						
				else
					#recent
					@comments = Comment.where(:is_reply => false, :project_id => project_id, :post_type => "REVIEWED").order("created_at DESC").all
					return @comments					
			end
		end
	end		
	
	# returns an array of all comments and flags on a particular section.
	# dependent on whether to show both public and private (show_both).
	# and how to sort them (sort_by).
	# for regular comment pages (variables are passed in from the section where the comment is located).
	# @param [String] section_name the name of the general section where the field is (example: projects, arms, studies, adverseevents, designdetails, baselinecharacteristics, keyquestions, primarypublications, secondarypublications, qualitydimensions, qualityratings)
	# @param [Integer] section_id the item_id of the section. (example: project id, keyquestion id, arm id)
	# @param [String] field_name the name of the field where the comment will be (example: [project] title, [keyquestion] question)
	# @param [Integer] study_id the id of the study where the field is (-1 if the field is in a project)
	# @param [Integer] project_id the id of the project to get a number of comments for
	# @param [boolean] show_both true if you want to show public and private comments, false if you want to show only private comments
	# @param [string] sort_by a string that determines the sorting order of the comment list returned
	# @return [Array] comments the sorted list of comments			
	def self.get_comments_and_flags(section_name, section_id, field_name, study_id, project_id, show_both, sort_by)
		if !show_both
			case sort_by
				when "type"
					@comments = Comment.where(:section_name => section_name, :section_id => section_id, :field_name => field_name, :study_id => study_id, :is_reply => false, :project_id => project_id, :is_public => true, :post_type => "REVIEWED").order("is_flag DESC, created_at DESC").all		
					return @comments										
				when "priority"	
					@comments = Comment.where(:section_name => section_name, :section_id => section_id, :field_name => field_name, :study_id => study_id, :is_reply => false, :project_id => project_id, :is_public => true, :post_type => "REVIEWED").order("is_flag DESC, is_high_priority DESC").all		
					return @comments														
				when "oldest"
					@comments = Comment.where(:section_name => section_name, :section_id => section_id, :field_name => field_name, :study_id => study_id, :is_reply => false, :project_id => project_id, :is_public => true, :post_type => "REVIEWED").order("created_at ASC").all
					return @comments					
				when "facts"
					@comments = Comment.where(:section_name => section_name, :section_id => section_id, :field_name => field_name, :study_id => study_id, :is_reply => false, :project_id => project_id, :is_public => true, :post_type => "REVIEWED").order("fact_or_opinion DESC").all		
					return @comments										
				when "flagtype"
					@comments = Comment.where(:section_name => section_name, :section_id => section_id, :field_name => field_name, :study_id => study_id, :is_reply => false, :project_id => project_id, :is_public => true, :post_type => "REVIEWED").order("is_flag DESC, flag_type ASC").all
					return @comments					
				when "public"
					@comments = Comment.where(:section_name => section_name, :section_id => section_id, :field_name => field_name, :study_id => study_id, :is_reply => false, :project_id => project_id, :is_public => true, :post_type => "REVIEWED").order("is_public DESC").all		
					return @comments										
				else
					#recent
					@comments = Comment.where(:section_name => section_name, :section_id => section_id, :field_name => field_name, :study_id => study_id, :is_reply => false, :project_id => project_id, :is_public => true, :post_type => "REVIEWED").order("created_at DESC").all		
					return @comments					
			end
		else
			case sort_by
				when "type"	
					@comments = Comment.where(:section_name => section_name, :section_id => section_id, :field_name => field_name, :study_id => study_id, :project_id => project_id, :is_reply => false, :post_type => "REVIEWED").order("is_flag DESC, created_at DESC").all		
					return @comments										
				when "priority"		
					@comments = Comment.where(:section_name => section_name, :section_id => section_id, :field_name => field_name, :study_id => study_id, :project_id => project_id,:is_reply => false, :post_type => "REVIEWED").order("is_high_priority DESC").all			
					return @comments																		
				when "oldest"
					@comments = Comment.where(:section_name => section_name, :section_id => section_id, :field_name => field_name, :study_id => study_id, :is_reply => false, :project_id => project_id, :post_type => "REVIEWED").order("created_at ASC").all
					return @comments					
				when "facts"
					@comments = Comment.where(:section_name => section_name, :section_id => section_id, :field_name => field_name, :study_id => study_id, :is_reply => false, :project_id => project_id, :post_type => "REVIEWED").order("fact_or_opinion DESC").all			
					return @comments					
				when "flagtype"
					@comments = Comment.where(:section_name => section_name, :section_id => section_id, :field_name => field_name, :study_id => study_id, :is_reply => false, :project_id => project_id, :post_type => "REVIEWED").order("flag_type ASC").all
					return @comments										
				when "public"
					@comments = Comment.where(:section_name => section_name, :section_id => section_id, :field_name => field_name, :study_id => study_id, :is_reply => false, :project_id => project_id, :post_type => "REVIEWED").order("is_public DESC").all				
					return @comments					
				else
					#recent
					@comments = Comment.where(:section_name => section_name, :section_id => section_id, :field_name => field_name, :study_id => study_id, :is_reply => false, :project_id => project_id, :post_type => "REVIEWED").order("created_at DESC").all
					return @comments					
			end
		end
	end	
	
	# returns a url to edit the comment based on the comment.
	# for the project summary.
	# this url (for editing) is only shown to collaborators viewing the project summary.
	# @param [String] comment the comment to get a url for
	# @return [String] url the url from the comment
	def self.get_edit_url(comment)
		@string = ""
		case comment.section_name
			when "projects"
				@string = @string + "/projects/" + comment.project_id.to_s + "/edit"
			when "keyquestions"
				@string = @string + "/projects/" + comment.project_id.to_s + "/edit"	
			when "arms"
				@string = @string + "/projects/" + comment.project_id.to_s + "/studies/" + comment.study_id.to_s + "/arms"				
			when "secondarypublications"
				@string = @string + "/projects/" + comment.project_id.to_s + "/studies/" + comment.study_id.to_s + "/publications"			
			when "primarypublications"
				@string = @string + "/projects/" + comment.project_id.to_s + "/studies/" + comment.study_id.to_s + "/publications"				
			when "adverseevents"
				@string = @string + "/projects/" + comment.project_id.to_s + "/studies/" + comment.study_id.to_s + "/adverse"				
			when "designdetails"
				@string = @string + "/projects/" + comment.project_id.to_s + "/studies/" + comment.study_id.to_s + "/design"			
			when "baselinecharacteristics"
				@string = @string + "/projects/" + comment.project_id.to_s + "/studies/" + comment.study_id.to_s + "/baselines"				
			when "qualitydimensions"
				@string = @string + "/projects/" + comment.project_id.to_s + "/studies/" + comment.study_id.to_s + "/quality"									
			when "qualityratings"
				@string = @string + "/projects/" + comment.project_id.to_s + "/studies/" + comment.study_id.to_s + "/quality"						
			else
				@string = @string + "/projects/" + comment.project_id.to_s + "/edit"	
			end	
		return @string
	end
	
	# returns a url to view the location of the comment based on the comment itself,
	# for the project summary. 
	# this url (for viewing) is shown to all users.
	# @param [Comment] comment the comment to get the location information for
	# @return [String] url the url to return based on the comment
	def self.get_view_url(comment)
		@string = "/projects/" + comment.project_id.to_s
		return @string
	end	
	
	# determines whether the study summary pop-up will need to be opened when the page is redirected.
	# for viewing public comments,
	# in the project summary
	# @param [Comment] comment the comment to get the location information for
	# @return [boolean] view_open_study boolean dependent on whether the comment is within a study or part of the project; determines whether the study preview will pop open automatically when viewing the comment location.	
	def self.get_view_open_study(comment)
		if (comment.study_id != -1)
			return comment.study_id
		else
			return false
		end
	end		
	
end
