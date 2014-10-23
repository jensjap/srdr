# This controller handles creation, deletion and updating of secondary publication numbers for a primary publication. 
# A primary publication can have unlimited primary publication numbers. 
class PrimaryPublicationNumbersController < ApplicationController

    # create a new primary publication number
    def new
        @primary_publication_number = PrimaryPublicationNumber.new
	    @primary_publication_number.save
	    @primary_publication = PrimaryPublication.find(params[:primary_publication])
	    @study = Study.find(params[:study_id])	
    end

    # save a new primary publication number for a primary publication
    def create
        @primary_publication_number = PrimaryPublicationNumber.new(params[:primary_publication_number])
        @primary_publication_number.save
    end
    

    # save data for an existing primary publication number for a publication
    def update
        @primary_publication_number = PrimaryPublicationNumber.find(params[:id])
	    @primary_publication_number.update_attributes(params[:primary_publication_number])
    end
    

    # delete an existing primary publication number for a publication
    def destroy
    end
end
