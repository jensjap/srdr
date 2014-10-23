# == Schema Information
#
# Table name: eft_diagnostic_test_detail_fields
#
#  id                             :integer          not null, primary key
#  eft_diagnostic_test_detail_id :integer
#  option_text                    :string(255)
#  subquestion                    :string(255)
#  has_subquestion                :boolean
#  row_number                     :integer          default(0)
#  column_number                  :integer          default(0)
#

class EftDiagnosticTestDetailField < ActiveRecord::Base
	belongs_to :eft_diagnostic_test_detail
end
