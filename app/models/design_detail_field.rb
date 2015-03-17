# == Schema Information
#
# Table name: design_detail_fields
#
#  id               :integer          not null, primary key
#  design_detail_id :integer
#  option_text      :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  subquestion      :string(255)
#  has_subquestion  :boolean
#  column_number    :integer          default(0)
#  row_number       :integer          default(0)
#

class DesignDetailField < ActiveRecord::Base
  include GlobalModelMethod

	before_save :clean_string

	belongs_to :design_detail
	has_many :design_detail_data_points, :dependent=>:destroy
	scope :all_fields_for_questions, lambda{|q_list, model_name| where("#{model_name}_id IN (?)",q_list).order("row_number ASC")}

	# remove all previously saved question choices before
	# scan the choices for a given question id and remove any
	# that are not in the id list
	# HOW WILL THIS WORK IF PEOPLE HAVE ALREADY SAVED DATA??
	def self.remove_old_choices obj_id, id_list
		choices = DesignDetailField.where(:design_detail_id=>obj_id)
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
	def self.save_question_choices(choices_hash, obj_id, editing, subquestion, options_with_subs,has_subquestion) 
		#print "\n\n **** Making call to save_question_choices\n\n "
		#print "subquestion: #{subquestion}\n"
		#print "options with subs: #{options_with_subs}\n"
		success = true
		objid = obj_id
		good_ids = []
		subquestioned_options = []
		has_sub = false
		if has_subquestion == 'yes'
		  has_sub = true
		end
		
		unless options_with_subs.nil?
			subquestioned_options = options_with_subs.values
		end
		
		
		i = 1
		choices_hash.keys.each do |key|
			#print " **** iterating through the choices hash. Now on key: #{key}\n\n"
			tmp = nil
			if editing
				field_id = key.split('_')
				field_id = field_id[field_id.length-1] #the id of the field itself was on the end of the id
							
				begin
					tmp = DesignDetailField.find(field_id.to_i)
				rescue
					tmp = nil
				end
			end
				
			# if there is no previous design detail to modify
			if tmp.nil?
				#print " ****Creating a new field for the choice: #{choices_hash[key]}....."
				# get a subquestion 
				subquestion_text = nil
				has_subquestion=false
				if has_sub
					if subquestioned_options.include?(i.to_s)
						subquestion_text = subquestion
						has_subquestion=true	
					end
				end
				tmp = DesignDetailField.new(:design_detail_id=>obj_id, :option_text=>choices_hash[key], :subquestion=>subquestion_text, :has_subquestion=>has_subquestion)
				if !tmp.save
					#print " Saving failed.\n\n"
					success = false
				else
					#print " Saved successfully\n\n"
					#tmp.save
				end
			
			# 	
			else
				# get a subquestion 
				subquestion_text = nil
				has_subquestion=false
				if has_sub
					if subquestioned_options.include?(i.to_s)
						subquestion_text = subquestion
						has_subquestion=true	
					end
				end
				if !tmp.update_attributes(:option_text => choices_hash[key], :subquestion=>subquestion_text, :has_subquestion=>has_subquestion)
					#print " **** Update failed.\n\n"
					success = false
				else
					#print " **** Update Successful\n\n"
				end
			end
			good_ids << tmp.id.to_s
			i+=1
		end
		if editing
			remove_old_choices(objid, good_ids)
		end
		return success
	end

end
