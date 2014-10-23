# This controller handles creation, deletion, pubmed data, and updating of primary publications for a study. 
# A study has one primary publication, and a primary publication can have 
# many primary publication numbers. The study title is derived from the title saved in the primary publication.
class PrimaryPublicationsController < ApplicationController
respond_to :js, :html

  # pull publication information from NCBI. This is 
  # called from the Retrieve button on the primary 
  # publication form
 def get_pubmed_data
	@pmid = params["pmid"]
	@pub_information = SecondaryPublication.get_summary_info_by_pmid(@pmid);
	@pub_type = 'primary'
	render 'shared/form_completion.js.erb'
end
	
  # save new primary publication data for a study
  def create
    @primary_publication = PrimaryPublication.new(params[:primary_publication])
	@study = Study.find(@primary_publication.study_id)
	
		if @saved = @primary_publication.save
			@message_div = "saved_indicator_1"
		else
	   	problem_html = create_error_message_html(@primary_publication.errors)
			flash[:modal_error] = problem_html
			@error_partial = "layouts/info_messages"	
			@error_div = "validation_message"
	  end
  end

  # update existing primary publication for a study
  def update
    @primary_publication = PrimaryPublication.find(params[:id])
	  @study = Study.find(@primary_publication.study_id)	
    
    # Handle Primary Publication Identifier list management -------------------------------------------
    id_numbers = params[:publication_ids]
    id_types = params[:publication_types]

    current_values = PrimaryPublicationNumber.where(:primary_publication_id=>@primary_publication.id)
    current_values_by_id = Hash.new
    current_values.each do |cv|
      current_values_by_id[cv.id] = cv
    end
    unless id_numbers.nil?
      # for each of the identifiers specified
      id_numbers.keys.each do |key|
        this_number = id_numbers[key]
        this_type = id_types[key]
        # if the key is negative, it means we need to create a new entry in the database
        if key.to_i < 0
          PrimaryPublicationNumber.create(:primary_publication_id=>@primary_publication.id, :number=>this_number, :number_type=>this_type)
        else
        # if the key is positive, collect the pre-existing identifier and update it with the new information
          ppid = PrimaryPublicationNumber.find(key)
          ppid.number = this_number
          ppid.number_type = this_type
          ppid.save

          # remove this from the current_values hash so we know we're still using it
          current_values_by_id.delete(ppid.id)
        end
      end
    end

    # get rid of any primary publication numbers that were not included this time
    current_values_by_id.keys.each do |k|
      PrimaryPublicationNumber.destroy(k)
    end
    
    # Now refresh list of publication identifiers
    @publication_ids = PrimaryPublicationNumber.find(:all, :conditions=>["primary_publication_id = ?", @primary_publication.id])
    
    if @saved = @primary_publication.update_attributes(params[:primary_publication])
      @message_div = "saved_indicator_1"
      @new_citation = @study.get_citation.gsub("\n","")
      @author = "#{@study.get_first_author} (#{@primary_publication.pmid})"
    else
      problem_html = create_error_message_html(@primary_publication.errors)
      flash[:modal_error] = problem_html
      @error_partial = "layouts/info_messages"  
      @error_div = "validation_message" 
    end
      # Return to previous page
      # redirect_to :back
  end
=begin
    n_ppis = params["n_ppi"].to_i
    for ppi_idx in 0..n_ppis - 1
        ppi_id = params["ppi_id_"+ppi_idx.to_s].to_i
        ppi_number = params["ppi_number_"+ppi_idx.to_s]
        ppi_type = params["ppi_type_"+ppi_idx.to_s]
        remove_flag = params["ppi_remove_"+ppi_idx.to_s]
        ppi_rec = PrimaryPublicationNumber.find(:first, :conditions=>["id = ?", ppi_id])
        if !remove_flag.nil? &&
            (remove_flag == "1")
            # Remove this identifier
            ppi_rec.destroy
        else
            if !(ppi_rec.number == ppi_number) ||
               !(ppi_rec.number_type == ppi_type)
                ppi_rec.number = ppi_number
                ppi_rec.number_type = ppi_type
                ppi_rec.updated_at = Time.now
                ppi_rec.save
            end
        end
    end

    new_ppi_number = params["ppi_number_new"]
    new_ppi_type = params["ppi_type_new"]
    if new_ppi_number.nil?
        new_ppi_number = ""
    end
    if new_ppi_type.nil?
        new_ppi_type = ""
    end
    if (new_ppi_number.size() > 0) &&
       (new_ppi_type.size() > 0) &&
       !(new_ppi_type == "Choose Identifier Type")
        # Avoid duplications - check if the new ID is already registered
        ppi_rec = PrimaryPublicationNumber.find(:first, :conditions=>["primary_publication_id = ? and number = ? and number_type = ?", @primary_publication.id, new_ppi_number, new_ppi_type])
        if ppi_rec.nil?
            ppi_rec = PrimaryPublicationNumber.new
            ppi_rec.primary_publication_id = @primary_publication.id
            ppi_rec.number = new_ppi_number
            ppi_rec.number_type = new_ppi_type
            ppi_rec.created_at = Time.now
            ppi_rec.updated_at = Time.now
            ppi_rec.save
        end
    end
=end
    

  # update primary publication identifiers for a study
  def update_ppi
    puts ">>>>>>>>>>>>> PrimaryPublicationController::update_ppi - done"
  end

end
