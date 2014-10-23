# == Schema Information
#
# Table name: extraction_form_section_copies
#
#  id           :integer          not null, primary key
#  section_name :string(255)
#  copied_from  :integer
#  copied_to    :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class  ExtractionFormSectionCopy < ActiveRecord::Base
	def self.get_previous_data(to_id, from_id)
		existing = ExtractionFormSectionCopy.where(:copied_to=>to_id, :copied_from=>from_id)
		return existing
	end
	
	# Given a list of sections that the user wants to import, set up the database accordingly.
	# The format should be import_sections["arms"=>formID, "design"=>"formID", etc. etc. ]
	# where formID tells us which form they are importing that particular section from
	def self.setup_import(efid, new_data)
		current_from_id = 0
		previously_added = []
		new_data.keys.each do |key|
			fromid = new_data[key]
			section = key
			
			unless current_from_id.to_s == fromid.to_s
				previously_added = get_previous_data(efid, fromid)
				previously_added = previously_added.collect{|x| x.section_name}	
				current_from_id = fromid
			end
			
			unless previously_added.include?(section)
				# create the section copy record
				ExtractionFormSectionCopy.create(:section_name=>section,:copied_from=>fromid,:copied_to=>efid)
				
				# update the form_section junction to update included and borrowed_from
				tmp = ExtractionFormSection.where(:extraction_form_id=>efid,:section_name=>section.to_s).first
				tmp.included = true
				tmp.borrowed_from_efid = fromid
				tmp.save
				
				# if it's for the arms section, add a copy to the form
				if section == 'arms'
					arms = ExtractionFormArm.where(:extraction_form_id=>fromid)
					unless arms.empty?
						arms.each do |arm|
							tmpArm = ExtractionFormArm.new
							tmpArm.name = arm.name
							tmpArm.description = arm.description
							tmpArm.note = arm.note
							tmpArm.extraction_form_id = efid
							tmpArm.save
						end
					end
				end
			else
				previously_added.delete_at(previously_added.index(section))
			end
		end
	end
	
	
	# THIS WAS THE ORIGINAL IMPORT SETUP USED BEFORE THE IMPORT STRUCTURE WAS CHANGED
	# TO INCLUDE A TABLE WITH RADIO BUTTONS. THIS LIMITED USERS TO BEING ABLE TO SELECT A 
	# SECTION TO IMPORT FROM ONLY ONE EXTRACTION FORM.
	def self.setup_import_original(efid, new_data)
		current_from_id = 0
		previously_added = []
		new_data.keys.each do |key|
			x = key.split("_")
			fromid = x[1]
			section = x[2]
			
			unless current_from_id.to_s == fromid.to_s
				previously_added = get_previous_data(efid, fromid)
				previously_added = previously_added.collect{|x| x.section_name}	
				current_from_id = fromid
			end
			
			unless previously_added.include?(section)
				# create the section copy record
				ExtractionFormSectionCopy.create(:section_name=>section,:copied_from=>fromid,:copied_to=>efid)
				
				# update the form_section junction to update included and borrowed_from
				tmp = ExtractionFormSection.where(:extraction_form_id=>efid,:section_name=>section.to_s).first
				tmp.included = true
				tmp.borrowed_from_efid = fromid
				tmp.save
			else
				previously_added.delete_at(previously_added.index(section))
			end
		end
	end
	
	def self.get_donor_forms(efid, section)
		retVal = Array.new
		donors = ExtractionFormSectionCopy.where(:copied_to=>efid, :section_name=>section)
		unless donors.nil? || donors.empty?
			donors.each do |donor|
				ef = ExtractionForm.find(donor.copied_from,:select=>["id","title"])
				unless ef.nil?
					retVal << ef
				end
			end
		end
		return retVal
	end
	
	# given an array of "donors", or extraction forms, get the information for the specified page
	# this is not used for the data tables instead see the next function
	def self.get_donor_info(donors, model)
		retVal = Array.new
		unless donors.empty?
			donors.each do |donor|
				tmp = eval(model).where(:extraction_form_id=>donor.id)
				retVal = retVal + tmp
			end
		end
		return retVal
	end
	
	# given an array of "donors", or extraction forms, get the categorical and continuous result columns
	def self.get_donor_info_for_results(donors, model)
		categorical = Array.new
		continuous = Array.new
		donors.each do |donor|
			tmpCont = eval(model).where(:extraction_form_id => donor.id, :study_id => nil, :outcome_type => "Continuous")	
			tmpCat = eval(model).where(:extraction_form_id => donor.id, :study_id => nil, :outcome_type => "Categorical")
			categorical = categorical + tmpCat
			continuous = continuous + tmpCont
		end
		return [categorical,continuous]
	end
	
	# determine which forms are borrowing from a given form.
	# this is used when displaying extraction forms to borrow from. If a form
	# is borrowing from the current form, then it could get confusing to try and borrow
	# sections already being borrowed from the current form.
	# @param  [Integer] ef_id  :the ID of the current extraction form
	# @return [Array] retVal  :an array of arrays (efid, title, section_name) for extraction forms borrowing the current
	def self.get_borrowers ef_id
		retVal = Array.new
		borrowed = ExtractionFormSectionCopy.where(:copied_from=>ef_id)
		current_borrower_id, current_borrower_title = ["",""]
		unless borrowed.empty?
			current_borrower_id = borrowed[0].copied_to
			tmp = ExtractionForm.find(current_borrower_id, :select=>["title"])
			unless tmp.nil?
				current_borrower_title = tmp.title	
			end
		end
			
		borrowed.each do |borrower|
			unless current_borrower_id == borrower.copied_to
				current_borrower_id = borrower.copied_to
				tmp = ExtractionForm.find(current_borrower_id, :select=>["title"])
				unless tmp.nil?
					current_borrower_title = tmp.title	
				end
			end
			retVal << [current_borrower_id, current_borrower_title]		
		end
		return retVal.uniq
	end
	
	
	# determine if it's OK for us to uncheck a section from the importing screen
	# it's only OK if no studies have been created that utilize that form section
	def self.can_stop_borrowing
		
	end
	
end
