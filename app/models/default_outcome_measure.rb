# == Schema Information
#
# Table name: default_outcome_measures
#
#  id           :integer          not null, primary key
#  outcome_type :string(255)
#  title        :string(255)
#  description  :string(255)
#  unit         :string(255)
#  is_default   :boolean          default(FALSE)
#  measure_type :integer          default(0)
#

class DefaultOutcomeMeasure < ActiveRecord::Base
end
