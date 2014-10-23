# @deprecated
# can be deleted?
class DefaultAdverseEventColumnsController < ApplicationController

  # create new default adverse event (in database only)
  def create
    @default_adverse_event_column = DefaultAdverseEventColumn.new(params[:default_adverse_event_column])
	@default_adverse_event_column.save
  end

end
