class CompareStudiesController < ApplicationController
  
  # -----------------------------------------------------------------------------------------------------
  # Method for setting up study comparason 
  # -----------------------------------------------------------------------------------------------------
    def comparestudies
        prj_id = params["prj_id"]
        nstudies = Integer(params["nstudies"])
        @project = Project.find(prj_id)
        if @project.nil?
            puts ">>>>>>>>>>> ERROR - could not find @project "+prj_id
        end
        
        @compareset = Compareset.new
        for studyidx in 0..nstudies - 1
            # TODO - add support to multiple extraction forms per study inside studydata.rb instead of taking first EF below.
            selected_study = params["merge_"+studyidx.to_s]
            if selected_study.nil?
                selected_study = "x"
            end
            if !selected_study.nil? &&
                (selected_study == "1")
                #study_efs = StudyExtractionForm.find(:all,:conditions=>["study_id = ?", study.id])
                sid = params["merge_"+studyidx.to_s+"_study_id"].to_i
                study_efs = StudyExtractionForm.find(:all,:conditions=>["study_id = ?", sid])
                study_ef = study_efs[0]
                ef_id = study_ef.extraction_form_id
                @compareset.add(@project.id,sid,ef_id)
            end
            
            studyidx = studyidx + 1
        end
        @alphabet = ['A','B','C','D','E','F','G','H','I','J','K','L','M']
    end
    
    # Method for building a concensus study
    def createconsensus
    end
  
end
