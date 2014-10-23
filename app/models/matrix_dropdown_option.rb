# == Schema Information
#
# Table name: matrix_dropdown_options
#
#  id            :integer          not null, primary key
#  row_id        :integer
#  column_id     :integer
#  option_text   :string(255)
#  option_number :integer
#  model_name    :string(255)
#

class MatrixDropdownOption < ActiveRecord::Base
	scope :matrix_dropdowns_for_fields, lambda{|field_ids, model_name| where("column_id IN (?) AND model_name = ?", field_ids, model_name).
				select(["row_id","column_id","option_text","option_number"]) }
end
