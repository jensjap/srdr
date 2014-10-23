# @deprecated
# can be deleted?
class DefaultOutcomeColumnsController < ApplicationController

  # create default outcome column (in database only)
  def create
    @default_outcome_column = DefaultOutcomeColumn.new(params[:default_outcome_column])
	@default_outcome_column.save
  end

end
