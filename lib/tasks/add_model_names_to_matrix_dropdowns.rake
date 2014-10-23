# update the post_type in the comments table from NULL to reviewed.
namespace :add_model_names_to_matrix_dropdowns do

	task :design_details => :environment do
		design_details = DesignDetail.where(:field_type => "matrix_select")
		design_details.each do |ad|
			row_ids = DesignDetailField.find(:all, :conditions=>["design_detail_id=? AND row_number>?",ad.id,0])
			row_ids = row_ids.collect{|x| x.id}

			column_ids = DesignDetailField.find(:all, :conditions=>["design_detail_id=? AND column_number>?",ad.id,0])
			column_ids = column_ids.collect{|y| y.id}
			
			matrix_options = MatrixDropdownOption.find(:all, :conditions=>["row_id IN (?) AND column_id IN (?) AND model_name IS NULL", row_ids, column_ids])
			matrix_options.each do |mo|
				mo.model_name = "design_detail"
				mo.save
			end
		end
	end

	task :baseline_characteristics => :environment do
		baseline_characteristics = BaselineCharacteristic.where(:field_type => "matrix_select")
		baseline_characteristics.each do |ad|
			row_ids = BaselineCharacteristicField.find(:all, :conditions=>["baseline_characteristic_id=? AND row_number>?",ad.id,0])
			row_ids = row_ids.collect{|x| x.id}

			column_ids = BaselineCharacteristicField.find(:all, :conditions=>["baseline_characteristic_id=? AND column_number>?",ad.id,0])
			column_ids = column_ids.collect{|y| y.id}
			
			matrix_options = MatrixDropdownOption.find(:all, :conditions=>["row_id IN (?) AND column_id IN (?) AND model_name IS NULL", row_ids, column_ids])
			matrix_options.each do |mo|
				mo.model_name = "baseline_characteristic"
				mo.save
			end
		end
	end
		
	task :arm_details => :environment do
		arm_details = ArmDetail.where(:field_type => "matrix_select")
		arm_details.each do |ad|
			row_ids = ArmDetailField.find(:all, :conditions=>["arm_detail_id=? AND row_number>?",ad.id,0])
			row_ids = row_ids.collect{|x| x.id}

			column_ids = ArmDetailField.find(:all, :conditions=>["arm_detail_id=? AND column_number>?",ad.id,0])
			column_ids = column_ids.collect{|y| y.id}
			
			matrix_options = MatrixDropdownOption.find(:all, :conditions=>["row_id IN (?) AND column_id IN (?) AND model_name IS NULL", row_ids, column_ids])
			matrix_options.each do |mo|
				mo.model_name = "arm_detail"
				mo.save
			end
		end
	end
	task :all => [:design_details, :baseline_characteristics, :arm_details]
end
