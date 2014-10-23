# @deprecated
# can be deleted?
class DefaultDesignDetailsController < ApplicationController

  # create default design detail (in database only)
  def create
    @default_design_detail = DefaultDesignDetail.new(params[:default_design_detail])
	@default_design_detail.save
  end

end
