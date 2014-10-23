# This controller handles creation, deletion, pubmed data, and updating of secondary publications for a study. 
# A study can have many secondary publications, and a secondary publication can have many secondary publication numbers.
class SecondaryPublicationsController < ApplicationController
before_filter :require_user

	# create new secondary publication
  def new
	@editing = false
    @secondary_publication = SecondaryPublication.new
    @extraction_form_id = params[:efid]
	@project = Project.find(params[:project_id])
	@study = Study.find(params[:study_id])
  end

  # pull publication information from NCBI. This is 
  # called from the Retrieve button on the primary 
  # publication form
  def get_pubmed_data
	pmid = params[:pmid]
	@pmid = params["pmid"]
	@pub_information = SecondaryPublication.get_summary_info_by_pmid(@pmid);
	@pub_type = 'secondary'
	render 'shared/form_completion.js.erb'
	end
	
	# edit existing secondary publication
  def edit
    @secondary_publication = SecondaryPublication.find(params[:id])
	@secondary_publication_numbers = SecondaryPublicationNumber.where(:secondary_publication_id => @secondary_publication.id).all
    @extraction_form_id = @secondary_publication.extraction_form_id
	@study_id = @secondary_publication.study_id
	@editing = true
end
  
	# save a new secondary publication
  def create
	@secondary_publication = SecondaryPublication.new(params[:secondary_publication])
 	@secondary_publication.display_number = @secondary_publication.get_display_number(params[:study_id])
	@secondary_publication.study_id = params[:study_id]
	@study_id = @secondary_publication.study_id
	@secondary_publication.save
	@secondary_publications = SecondaryPublication.find(:all, :order => 'display_number ASC', :conditions => {:study_id =>params[:study_id]})	
	@study = Study.find(@study_id)
	@project = Project.find(@study.project_id)
    if @saved = @secondary_publication.save
		
	# create newly specified outcomes
	if !params[:secondary_publication_numbers_attributes].nil?
	params[:secondary_publication_numbers_attributes].each do |item|
		@spn = SecondaryPublicationNumber.new
		@spn.number = item[1][:number]
		@spn.number_type = item[1][:number_type]
		@spn.secondary_publication_id = @secondary_publication.id
		@spn.save	
	end	
	end		
		@secondary_publication = SecondaryPublication.new
		@message_div = "saved_item_indicator_2"
    else
       	problem_html = create_error_message_html(@secondary_publication.errors)
		flash[:modal_error] = problem_html
    end
	@error_div = "validation_message"
  end


	# update an existing secondary publication
  def update
    @secondary_publication = SecondaryPublication.find(params[:id])
    @secondary_publication.study_id = params[:study_id]
    @study_id = @secondary_publication.study_id
	@study = Study.find(@study_id)
	@project = Project.find(@study.project_id)	
     if @saved = @secondary_publication.update_attributes(params[:secondary_publication])
		
	# update any changes to previously specified publication numbers
	@spi_ids = []
	if !params[:secondary_publication_numbers_attributes].nil?
		params[:secondary_publication_numbers_attributes].each do |item|
			@existing_id = item[1][:id]
			@spi_ids << @existing_id
			@spi = SecondaryPublicationNumber.find(@existing_id)
			@spi.number = item[1][:number]
			@spi.number_type = item[1][:number_type]
			@spi.secondary_publication_id = @secondary_publication.id
			@spi.save
		end
	end
	
	@spis_to_delete = SecondaryPublicationNumber.where(["secondary_publication_id=(?) AND id NOT IN (?)", @secondary_publication.id, @spi_ids]).all
	@spis_to_delete.each do |tp|
		tp.destroy
	end

	@secondary_publications = SecondaryPublication.find(:all, :order => 'display_number ASC', :conditions => {:study_id => @secondary_publication.study_id, :extraction_form_id => @secondary_publication.extraction_form_id})	
	@extraction_form_id = @secondary_publication.extraction_form_id
	@secondary_publication = SecondaryPublication.new
	@message_div = "saved_indicator_2"
	@modal = true
	else
		problem_html = create_error_message_html(@secondary_publication.errors)
		flash[:modal_error] = problem_html
	end
	@error_div = "validation_message"
  end

	# delete the selected secondary publication
  def destroy
  	puts ("CALL TO DESTROY -------------")
    @secondary_publication = SecondaryPublication.find(params[:id])
	@study_id = @secondary_publication.study_id
	@study = Study.find(@study_id)
	@project = Project.find(@study.project_id)	
	@secondary_publication.shift_display_numbers(@study_id)
	@extraction_form_id = @secondary_publication.extraction_form_id
    @secondary_publication.destroy
    secondary_publications = []
    @secondary_publications = SecondaryPublication.find(:all, :order => 'display_number ASC', :conditions => {:study_id => @study_id, :extraction_form_id=>@extraction_form_id})
    @secondary_publication = SecondaryPublication.new
    puts "Secondary Publications is of length #{@secondary_publications.length}\n\n"
  end

	#  moveup a secondary publication in the list
def moveup
	@secondary_publication = SecondaryPublication.find(params[:secondary_publication_id].to_i)
	SecondaryPublication.move_up_this(params[:secondary_publication_id].to_i, @secondary_publication.study_id)
	@study_id = @secondary_publication.study_id
	@secondary_publications = SecondaryPublication.find(:all, :order => 'display_number ASC', :conditions => {:study_id => @secondary_publication.study_id})
    @secondary_publication = SecondaryPublication.new
end


end