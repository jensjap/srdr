# == Schema Information
#
# Table name: default_comparison_measures
#
#  id                :integer          not null, primary key
#  outcome_type      :string(255)
#  title             :string(255)
#  description       :string(255)
#  unit              :string(255)
#  is_default        :boolean          default(FALSE)
#  measure_type      :integer          default(0)
#  within_or_between :integer          default(0)
#

class DefaultComparisonMeasure < ActiveRecord::Base
end
