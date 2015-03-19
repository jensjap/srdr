# == Schema Information
#
# Table name: baseline_characteristic_fields
#
#  id                         :integer          not null, primary key
#  baseline_characteristic_id :integer
#  option_text                :string(255)
#  created_at                 :datetime
#  updated_at                 :datetime
#  subquestion                :string(255)
#  has_subquestion            :boolean
#  column_number              :integer          default(0)
#  row_number                 :integer          default(0)
#

class BaselineCharacteristicField < ActiveRecord::Base
    include GlobalModelMethod

    before_save :clean_string

	belongs_to :baseline_characteristic, :touch=>true
	has_many :baseline_characteristic_data_points, :dependent=>:destroy
	scope :all_fields_for_questions, lambda{|q_list, model_name| where("#{model_name}_id IN (?)",q_list).order("row_number ASC")}

	# get_arm_ids_string
	# get a string of arm_ids based on a list of arms
	# are we using this?? 4/1/2011
	def self.get_arm_ids_string(arm_list)
		str = ""
		for i in arm_list
			str += i.id.to_s + " "
		end
		return str
	end

	# remove_old_choices
	# remove all previously saved question choices before
	# scan the choices for a given question id and remove any
	# that are not in the id list
	# HOW WILL THIS WORK IF PEOPLE HAVE ALREADY SAVED DATA??
	def self.remove_old_choices obj_id, id_list
		choices = BaselineCharacteristicField.where(:baseline_characteristic_id=>obj_id)
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
	def self.save_question_choices(choices_hash, obj_id, editing, subquestion, options_with_subs, has_subquestion) 

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
			tmp = nil
			if editing
				field_id = key.split('_')
				field_id = field_id[field_id.length-1] #the id of the field itself was on the end of the id
							
				begin
					tmp = BaselineCharacteristicField.find(field_id.to_i)
				rescue
					tmp = nil
				end
			end
				
			# if there is no previous design detail to modify
			if tmp.nil?
				# get a subquestion 
				subquestion_text = nil
				has_subquestion=false
				if has_sub
					if subquestioned_options.include?(i.to_s)
						subquestion_text = subquestion
						has_subquestion=true	
					end
				end
				tmp = BaselineCharacteristicField.new(:baseline_characteristic_id=>obj_id, :option_text=>choices_hash[key], :subquestion=>subquestion_text, :has_subquestion=>has_subquestion)
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
					if subquestioned_options.include?(i.to_s)
						subquestion_text = subquestion
						has_subquestion=true	
					end
				end
				if !tmp.update_attributes(:option_text => choices_hash[key], :subquestion=>subquestion_text, :has_subquestion=>has_subquestion)
					success = false
				else
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
