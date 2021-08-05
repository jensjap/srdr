class DiagnosticTestsController < ApplicationController
    before_filter :require_editor_role, :only => [:create, :update, :destroy]

	# initialize a new diagnostic test
	def new
		@test_obj = DiagnosticTest.new
		@test_obj.test_type = @test_type = params[:test_type].to_i
		@ef_id = params[:extraction_form_id].to_i
		@study = Study.find(params[:study_id])
        @test_title = get_table_title(@test_obj)[0]
        @editing=false
        # get information regarding the extraction forms, pre-defined diagnostic tests and descriptions,
      	# sections in each form, sections borrowed from other forms, key questions associated with 
      	# each section, etc.
      	@study_extforms = StudyExtractionForm.where(:study_id=>@study.id)	
        @thresholds = Array.new	
      	unless @study_extforms.empty?
          @prev_index_tests,@prev_index_descriptions, @prev_reference_tests, @prev_reference_descriptions = DiagnosticTest.get_previously_entered_tests(@study_extforms,@study)
      	end
	end

	# create the diagnostic test object
	def create
		new_dt = DiagnosticTest.create(params[:diagnostic_test])  # create the test object
        new_dt.assign_thresholds(params[:thresholds])     # assign test thresholds
		@efid = new_dt.extraction_form_id
        @title, @table_container = get_table_title(new_dt)
        @thresholds = new_dt.diagnostic_test_thresholds
        @tests = DiagnosticTest.where(:extraction_form_id=>@efid, :study_id=>new_dt.study_id, :test_type=>new_dt.test_type)
        # render create.js.erb
	end

	# edit the diagnostic test object
    def edit
        @test_obj = DiagnosticTest.find(params[:id])
        @thresholds = @test_obj.diagnostic_test_thresholds
        @test_type = @test_obj.test_type
        @ef_id = @test_obj.extraction_form_id
        @study = Study.find(@test_obj.study_id)
        @test_title = get_table_title(@test_obj)[0]
        @editing=true
        # get information regarding the extraction forms, pre-defined diagnostic tests and descriptions,
      	# sections in each form, sections borrowed from other forms, key questions associated with 
      	# each section, etc.
      	@study_extforms = StudyExtractionForm.where(:study_id=>@study.id)		
      	unless @study_extforms.empty?
          @prev_index_tests,@prev_index_descriptions, @prev_reference_tests, @prev_reference_descriptions = DiagnosticTest.get_previously_entered_tests(@study_extforms,@study)
      	end
        render 'new'
    end

    # update the diagnostic test object
    def update
        dt = DiagnosticTest.find(params[:id])
        ef = ExtractionForm.find(dt.extraction_form_id)
        if current_user.id.eql?(ef.creator_id) || current_user.is_admin?
            if dt.update_attributes(params[:diagnostic_test])
                dt.assign_thresholds(params[:thresholds])     # assign test thresholds
                @efid = dt.extraction_form_id
                @extraction_form = ExtractionForm.find(@efid)
                @title,@table_container = get_table_title(dt)
                @thresholds = dt.diagnostic_test_thresholds
                @tests = DiagnosticTest.where(:extraction_form_id=>@efid,:study_id=>dt.study_id, :test_type=>dt.test_type)
                # render create.js.erb
                render 'create'
            end
        end
    end

    # remove the diagnostic test
    def destroy
        @obj = DiagnosticTest.find(params[:id])
        @efid = @obj.extraction_form_id
        @extraction_form = ExtractionForm.find(@efid)
        @title,@table_container = get_table_title(@obj)
        @tests = DiagnosticTest.where(:extraction_form_id=>@efid,:study_id=>@obj.study_id, :test_type=>@obj.test_type)
        if current_user.id.eql?(@extraction_form.creator_id) || current_user.is_admin?
          @obj.destroy
        end
    end

	#-----------------------------------------
    # utility functions below this point.

    # get_table_title
    # Return the appropriate table title given the type of test that it is
    def get_table_title dt_obj
        title = ""
        div = ""
        if dt_obj.test_type == 1
            title="Index Test"
            div = "index_test_div"
        else
            title="Reference Test"
            div = "reference_test_div"
        end
        return title,div
    end
end