# @deprecated
# can be deleted?
class DefaultOutcomeComparisonColumnsController < ApplicationController

  # create default outcome comparison column (in database only)
  def create
    @default_outcome_comparison_column = DefaultOutcomeComparisonColumn.new(params[:default_outcome_comparison_column])
	@default_outcome_comparison_column.save
  end

end
