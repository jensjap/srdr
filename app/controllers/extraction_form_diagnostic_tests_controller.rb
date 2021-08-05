# this controller handles creation and editing of arm suggestions - when a contributor adds arm names to the extraction form.
class ExtractionFormDiagnosticTestsController < ApplicationController
    before_filter :require_editor_role, :only => [:create, :update, :destroy]
    # new
    # create a new extraction form diagnostic test suggestion. First determine which type of
    # test needs to be created (index or reference) and create an object for the form to work on.
    def new
        @test_obj = ExtractionFormDiagnosticTest.new
        @test_obj.test_type = params[:test_type].to_i
        @extraction_form_id = params[:extraction_form_id]
        @test_type = get_table_title(@test_obj)[0]
        @editing=false
    end
    # create
    # create a new extraction form diagnostic test object
    def create
        new_dt = ExtractionFormDiagnosticTest.create(params[:extraction_form_diagnostic_test])
        @efid = new_dt.extraction_form_id
        @extraction_form = ExtractionForm.find(@efid)
        @title,@table_container = get_table_title(new_dt)
        @tests = ExtractionFormDiagnosticTest.where(:extraction_form_id=>@efid,:test_type=>new_dt.test_type)
        # render create.js.erb
    end
     
    # edit the diagnostic test object
    def edit
        @test_obj = ExtractionFormDiagnosticTest.find(params[:id])
        @extraction_form_id = @test_obj.extraction_form_id
        @test_type = get_table_title(@test_obj)[0]
        @editing=true
        render 'new'
    end

    # update the diagnostic test object
    def update
        dt = ExtractionFormDiagnosticTest.find(params[:id])
        if dt.update_attributes(params[:extraction_form_diagnostic_test])
            @efid = dt.extraction_form_id
            @extraction_form = ExtractionForm.find(@efid)
            @title,@table_container = get_table_title(dt)
            @tests = ExtractionFormDiagnosticTest.where(:extraction_form_id=>@efid,:test_type=>dt.test_type)
            # render create.js.erb
            render 'create'
        end
    end

    # remove the extraction form diagnostic test
    def destroy
        @obj = ExtractionFormDiagnosticTest.find(params[:id])
        @efid = @obj.extraction_form_id
        @extraction_form = ExtractionForm.find(@efid)
        @title,@table_container = get_table_title(@obj)
        @tests = ExtractionFormDiagnosticTest.where(:extraction_form_id=>@efid,:test_type=>@obj.test_type)
        @obj.destroy
    end

    def new_instr
        @editing = false
        @extraction_form = ExtractionForm.find(params[:extraction_form_id])
        @section = params[:section]
        @data_element = params[:data_element]
        @extraction_form_diagnostic_test_instr = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", params[:extraction_form_id].to_s, @section, @data_element])
        if @extraction_form_diagnostic_test_instr.nil?
            @extraction_form_diagnostic_test_instr = EfInstruction.new
        end
    end

    #-----------------------------------------
    # utility functions below this point.

    # get_table_title
    # Return the appropriate table title given the type of test that it is
    def get_table_title efdt_obj
        title = ""
        div = ""
        if efdt_obj.test_type == 1
            title="Index Test"
            div = "index_test_div"
        else
            title="Reference Test"
            div = "reference_test_div"
        end
        return title,div
    end

end