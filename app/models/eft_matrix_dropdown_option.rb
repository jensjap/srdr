# == Schema Information
#
# Table name: eft_matrix_dropdown_options
#
#  id       		:integer     not null, primary key
#  row_id			:integer
#  column_id		:integer
#  option_txt       :string
#  option_number    :integer
#  model_name       :string

class EftMatrixDropdownOption < ActiveRecord::Base

end
