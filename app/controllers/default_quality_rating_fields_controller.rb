# @deprecated
# can be deleted?
class DefaultQualityRatingFieldsController < ApplicationController

  # create default quality rating field (in database only)
  def create
    @default_quality_rating_field = DefaultQualityRatingField.new(params[:default_quality_rating_field])
	@default_quality_rating_field.save
  end
end
