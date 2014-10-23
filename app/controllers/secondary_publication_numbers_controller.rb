# This controller handles creation, deletion and updating of secondary publication numbers. 
# A secondary publication can have unlimited secondary publication numbers. 
class SecondaryPublicationNumbersController < ApplicationController
	before_filter :require_user

	# create a new secondary_publication_number
  def create
    @secondary_publication_number = SecondaryPublicationNumber.new(params[:secondary_publication_number])
	@secondary_publication_number.save
  end

	# update an existing secondary_publication_number
  def update
    @secondary_publication_number = SecondaryPublicationNumber.find(params[:id])
	@secondary_publication_number.update_attributes(params[:secondary_publication_number])
  end

	# destroy the secondary_publication_number with id = params[:id]
  def destroy
    thisNumber = SecondaryPublicationNumber.find(params[:id])
    thisNumber.destroy
    @secondary_publications = @study.get_secondary_publications(params[:extraction_form_id])
  end
  
  # create a new secondary publication number
  def new
    @secondary_publication_number = SecondaryPublicationNumber.new
	@secondary_publication_number.save
	@study = Study.find(params[:study_id])	
  end
  
  
end
