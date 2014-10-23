# == Schema Information
#
# Table name: diagnostic_test_thresholds
#
#  id                 :integer          not null, primary key
#  diagnostic_test_id :integer
#  threshold          :string(255)
#

class DiagnosticTestThreshold < ActiveRecord::Base
	belongs_to :diagnostic_test, :touch=>true
end
