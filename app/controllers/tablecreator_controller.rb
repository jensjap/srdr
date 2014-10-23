class TablecreatorController < ApplicationController
    # Table Creator Controller
    # index
    def index
        tcaction = params["tcaction"]
        if tcaction.nil?
            tcaction = "VIEW"
        end
        # puts"......................... tablecreator - tcaction = "+tcaction
        if !tcaction.nil? &&
            (tcaction == "NEW")
            # Clear old session data
            session[:tc_project] = nil
            # Flag set to 1 the first time "Preview Report" is selected
            session[:tc_preview] = nil
            
            # may not be needed...
            session[:tc_formconfig] = nil
        end
        
        prj_id = params[:prjid]
        
        # Check to see if we need to load a new project report set and configuration set
        # If first time (nil) or current project selected doesn't match what is stored, re-load
        @tc_project = session[:tc_project]
        if @tc_project.nil? ||
           !(@tc_project["prjid"] == prj_id)
            @tc_project = Hash.new
            @tc_project["prjid"] = prj_id.to_s
            
            table_formconfig = session[:tc_formconfig]
            if !table_formconfig.nil?
                viewprj_id = table_formconfig["prj_id"]
                if viewprj_id == prj_id
                    # Same project - do nothing
                else
                    # Load default form selections - check project folder first, then default
                    if File.exist?("reports/tables/"+prj_id+"/default.conf")
                        table_formconfig = YAML.load_file("reports/tables/"+prj_id+"/default.conf")
                        # Indicate default - suppress preview
                        table_formconfig[:isdefault] = true
                        table_formconfig[:cfgname] = "reports/tables/"+prj_id+"/default.conf"
                        session[:tc_formconfig] = table_formconfig
                    elsif File.exist?("reports/tables/default/project.conf")
                        table_formconfig = YAML.load_file("reports/tables/default/project.conf")
                        # Indicate default - suppress preview
                        table_formconfig[:isdefault] = true
                        table_formconfig[:cfgname] = "reports/tables/default/project.conf"
                        session[:tc_formconfig] = table_formconfig
                    end
                end
            else
                # Load default form selections - check project folder first, then default
                if File.exist?("reports/tables/"+prj_id+"/default.conf")
                    table_formconfig = YAML.load_file("reports/tables/"+prj_id+"/default.conf")
                    # Indicate default - suppress preview
                    table_formconfig[:isdefault] = true
                    table_formconfig[:cfgname] = "reports/tables/"+prj_id+"/default.conf"
                    session[:tc_formconfig] = table_formconfig
                elsif File.exist?("reports/tables/default/project.conf")
                    table_formconfig = YAML.load_file("reports/tables/default/project.conf")
                    # Indicate default - suppress preview
                    table_formconfig[:isdefault] = true
                    table_formconfig[:cfgname] = "reports/tables/default/project.conf"
                    session[:tc_formconfig] = table_formconfig
                end
            end
            
            # puts ">>>>>>>>>>>> in tablecreator_controller::index - prj_id "+prj_id
            # Load project information and build the table creator configuration file
            prj = Project.find(:first, :conditions=>["id = ?", prj_id])
            if !prj.nil?
                # puts "------------ loaded prj "+prj.id.to_s
                @tc_project["project"] = prj
                
                # ------------------------------ Replacement Model -----------------------------------------
                # Reportset contains (model) the values for a collection of studies that belong to the selected project
                # while Reportconfig tracks which of these values are to be shown in the report (control) 
                reportset = Reportset.new
                #studies = Study.find(:all, :conditions=>["project_id = ? and id >= 1451", prj.id], :limit=>20, :order=>"id")
                studies = Study.find(:all, :conditions=>["project_id = ?", prj.id], :order=>"id")
                for study in studies
                    study_ef = StudyExtractionForm.find(:first,:conditions=>["study_id = ?", study.id])
                    puts ".............["+prj.id.to_s+"] loading study "+study.id.to_s
                    reportset.add(prj.id,study.id,study_ef.extraction_form_id)
                end  
                @tc_project["reportset"] = reportset
                puts "----------------tablecreator_controller:: loading project "+prj_id.to_s
                
                # ------------ Setup Options for Report Generation -----------------------------------------
                reportconfig = Reportconfig.new
                reportconfig.setConfig(reportset)
                @tc_project["reportconfig"] = reportconfig
                # ------------------------------ Replacement Model -----------------------------------------
            end
            session[:tc_project] = @tc_project
        end
    end
  
    # Method adds selected items to the table template
    def buildtable
        @tc_project = session[:tc_project]
        prj_id = @tc_project["prjid"]
        reportset = @tc_project["reportset"] 
        reportconfig = @tc_project["reportconfig"] 
        
        cfgval = params["format_by_arms"]
        if !cfgval.nil?
            reportconfig.setFormatByArm(cfgval.to_i)
        else
            reportconfig.setFormatByArm(0)
        end
        
        # Get Project selections -----------------------------------------------------------------------
        for ridx in 0..reportconfig.getNumProjectItems() - 1
            param_name = "prj_"+ridx.to_s
            cfgval = params[param_name]
            if !cfgval.nil?
                reportconfig.showProjectItem(ridx,cfgval.to_i)
            else
                reportconfig.showProjectItem(ridx,0)
            end
        end
        
        # Get Study selections -----------------------------------------------------------------------
        for ridx in 0..reportconfig.getNumStudyItems() - 1
            param_name = "s_"+ridx.to_s
            cfgval = params[param_name]
            if !cfgval.nil?
                reportconfig.showStudyItem(ridx,cfgval.to_i)
            else
                reportconfig.showStudyItem(ridx,0)
            end
        end
        # Check for Study Filter settings
        filter_studies = params["filter_studies"]
        if !filter_studies.nil? &&
            (filter_studies == "1")
            # Use array to collect study_ids that matched filter criteria
            filtered_study_ids = Array.new
            study_ids = reportset.getStudyIDs()
            
            # study list filter parameters
            pmid_filter = params["sf_pmid"]
            title_filter = params["sf_title"]
            author_filter = params["sf_authors"] 
            reportconfig.setStudyFilterPMIDs("")
            reportconfig.setStudyFilterTitles("")
            reportconfig.setStudyFilterAuthors("")
            # Filter by PubMed IDs  
            if pmid_filter.size > 0
                reportconfig.setStudyFilterPMIDs(pmid_filter)
                fcomp = pmid_filter.split(",");
                fstudy_ids = reportset.filterByPMIDs(fcomp);
                if fstudy_ids.size() > 0
                    fstudy_ids.each do |fsid|
                        if !filtered_study_ids.include?(fsid)
                            filtered_study_ids << fsid
                        end
                    end
                end
            end
            # Filter by Study Title  
            if title_filter.size > 0
                reportconfig.setStudyFilterTitles(title_filter)
                fcomp = title_filter.split(",");
                fstudy_ids = reportset.filterByTitles(fcomp);
                if fstudy_ids.size() > 0
                    fstudy_ids.each do |fsid|
                        if !filtered_study_ids.include?(fsid)
                            filtered_study_ids << fsid
                        end
                    end
                end
            end
            # Filter by Study Authors  
            if author_filter.size > 0
                reportconfig.setStudyFilterAuthors(author_filter)
                fcomp = author_filter.split(",");
                fstudy_ids = reportset.filterByAuthors(fcomp);
                if fstudy_ids.size() > 0
                    fstudy_ids.each do |fsid|
                        if !filtered_study_ids.include?(fsid)
                            filtered_study_ids << fsid
                        end
                    end
                end
            end
            if filtered_study_ids.size() > 0
                # Clear all study selections except those in the filtered_study_ids
                for ridx in 0..reportconfig.getNumStudyItems() - 1
                    if filtered_study_ids.include?(reportset.getStudyID(ridx).to_s)
                        reportconfig.showStudyItem(ridx,1)
                    else
                        reportconfig.showStudyItem(ridx,0)
                    end
                end
            end
        end
        
        
        # Get Publication selections -----------------------------------------------------------------------
        for ridx in 0..reportconfig.getNumPublicationItems() - 1
            param_name = "pub_"+ridx.to_s
            cfgval = params[param_name]
            if !cfgval.nil?
                reportconfig.showPublicationItem(ridx,cfgval.to_i)
            else
                reportconfig.showPublicationItem(ridx,0)
            end
        end
        
        # Get Arms record selections -----------------------------------------------------------------------
        # New Arms config component approach ---------------------------------------------------------------
        arm_config = reportconfig.getArms()
        arm_config.setSelections(params)
        # New Arms config component approach ---------------------------------------------------------------
        
        # Get Arm Details record selections -----------------------------------------------------------------------
        # New Arm Details config component approach ---------------------------------------------------------------
        armdetails_config = reportconfig.getArmDetails()
        armdetails_config.setSelections(params)
        # New Arm Details config component approach ---------------------------------------------------------------
        
        # Get Design Details record selections -----------------------------------------------------------------------
        # New Design Details config component approach ---------------------------------------------------------------
        designdetails_config = reportconfig.getDesignDetails()
        designdetails_config.setSelections(params)
        # New Design Details config component approach ---------------------------------------------------------------
        
        # Get Baseline Characteristics selections -----------------------------------------------------------------------
        # New Baseline config component approach ---------------------------------------------------------------
        baseline_config = reportconfig.getBaseline()
        baseline_config.setSelections(params)
        # New Baseline config component approach ---------------------------------------------------------------
        
        # Get Outcome Subgroup selections -----------------------------------------------------------------------
        # New Outcome Subgroups config component approach ---------------------------------------------------------------
        outcomesgs_config = reportconfig.getOutcomeSubgroups()
        outcomesgs_config.setSelections(params)
        # New Outcome Subgroups config component approach ---------------------------------------------------------------
        
        # Get Outcome Timepoints selections -----------------------------------------------------------------------
        # New Outcome Time points config component approach ---------------------------------------------------------------
        outcometpts_config = reportconfig.getOutcomeTimepoints()
        outcometpts_config.setSelections(params)
        # New Outcome Time points config component approach ---------------------------------------------------------------
        
        # Get Outcome Measures record selections -----------------------------------------------------------------------
        # New Outcome Measures config component approach ---------------------------------------------------------------
        outcomemeas_config = reportconfig.getOutcomeMeasures()
        outcomemeas_config.setSelections(params)
        # New Outcome Measures config component approach ---------------------------------------------------------------
        
        # Get Outcomes selections -----------------------------------------------------------------------
        # New Outcomes config component approach ---------------------------------------------------------------
        outcomes_config = reportconfig.getOutcomes()
        outcomes_config.setSelections(params)
        # New Outcomes config component approach ---------------------------------------------------------------
        
        # Get Outcome Details record selections -----------------------------------------------------------------------
        # New Outcome Details config component approach ---------------------------------------------------------------
        outcomedetails_config = reportconfig.getOutcomeDetails()
        outcomedetails_config.setSelections(params)
        # New Outcome Details config component approach ---------------------------------------------------------------
        
        # Get Adverse Events record selections -----------------------------------------------------------------------
        # New Adverse Events config component approach ---------------------------------------------------------------
        advevents_config = reportconfig.getAdvEvents()
        advevents_config.setSelections(params)
        # New Adverse Events config component approach ---------------------------------------------------------------
        
        puts "tablecreator_controller::buildtable - set config with quality dims"
        # Get Quality Dimensions record selections -----------------------------------------------------------------------
        # New Quality Dimensions config component approach ---------------------------------------------------------------
        qualdims_config = reportconfig.getQuality()
        qualdims_config.setSelections(params)
        # New Quality Dimensions config component approach ---------------------------------------------------------------
        puts "tablecreator_controller::buildtable - set config with wac"
        
        # Get Between Arms Comparison selections -----------------------------------------------------------------------
        for ridx in 0..reportconfig.getNumBACItems() - 1
            param_name = "bac_"+ridx.to_s
            cfgval = params[param_name]
            if !cfgval.nil?
                reportconfig.showBACItem(ridx,cfgval.to_i)
            else
                reportconfig.showBACItem(ridx,0)
            end
        end
        for ridx in 0..reportconfig.getNumBACMeasureItems() - 1
            param_name = "bacmeas_"+ridx.to_s
            cfgval = params[param_name]
            if !cfgval.nil?
                reportconfig.showBACMeasureItem(ridx,cfgval.to_i)
            else
                reportconfig.showBACMeasureItem(ridx,0)
            end
        end
        
        # Get Within Arms Comparison selections -----------------------------------------------------------------------
        for ridx in 0..reportconfig.getNumWACItems() - 1
            param_name = "wac_"+ridx.to_s
            cfgval = params[param_name]
            if !cfgval.nil?
                reportconfig.showWACItem(ridx,cfgval.to_i)
            else
                reportconfig.showWACItem(ridx,0)
            end
        end
        for ridx in 0..reportconfig.getNumWACMeasureItems() - 1
            param_name = "wacmeas_"+ridx.to_s
            cfgval = params[param_name]
            if !cfgval.nil?
                reportconfig.showWACMeasureItem(ridx,cfgval.to_i)
            else
                reportconfig.showWACMeasureItem(ridx,0)
            end
        end
        
        @tc_project["reportconfig"] = reportconfig
        # Mark this project as ready to render preview
        session[:tc_preview] = 1
        
        confname = params["confname"]
        confdescription = params["description"]
        if !confname.nil? &&
           confname.length > 0
           reportconfig.saveConfig(prj_id,confname,confdescription)
        end
        
        # Now write view config file for this project
        redirect_to "/projects/tablecreator.html?prjid="+prj_id.to_s
    end
  
    # Method load or remove a template file
    def templatemanager
        @tc_project = session[:tc_project]
        prj_id = @tc_project["prjid"]
        # reportset = @tc_project["reportset"] 
        reportconfig = @tc_project["reportconfig"] 
        
        template_cmd = params["cmd"]
        template_cfgname = params["cfgname"]
        if template_cmd == "LOAD"
            # puts".................... tablecreator_controller:: templatemanager - LOAD on "+prj_id.to_s
            reportconfig.loadConfig(prj_id.to_i,template_cfgname)
        elsif template_cmd == "REMOVE"
            # puts".................... tablecreator_controller:: templatemanager - REMOVE on "+prj_id.to_s
        end
        
        # Now write view config file for this project
        redirect_to "/projects/tablecreator.html?prjid="+prj_id.to_s
        
    end
  
    # Method adds selected items to the table template
    def add
    end
  
    # Method remove selected items from the table template
    def remove
    end
  
    # Method reorder contents within a table template
    def moveUp
    end
  
    # Method reorder contents within a table template
    def moveDown
    end
  
    # Export Table Creator Project to EXCEL
    def export_to_excel
		# Pull TC data from the session object
        tc_project = session[:tc_project]
        reportconfig = tc_project["reportconfig"]
        reportset = tc_project["reportset"]
        
      	# construct the Excel file and get a list of files created
      	filenames = TCExcelExport.project_to_xls(tc_project, reportconfig, reportset, current_user)
      	
        user = current_user.login
      	fname = "#{user}_project_export.xls"
      	send_data(filenames, :type=>"application/xls",:filename=>fname)
    end
end
