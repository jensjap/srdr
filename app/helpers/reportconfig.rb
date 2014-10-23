class Reportconfig

    # Reportconfig mirrors Reportset collecting and distinct data elements across studies within a project. Its primary purpose is to track which
    # data item was selected to for display and export.
    
    def initialize
        # Display controls
        @format_by_arms = 0
        @is_default = 1
        @cfgname = nil
        @project_id = nil
        @meta = Hash.new
        @meta["name"] = "default"
        @meta["description"] = "Default"
        
        # Study - flags which study to render - allows large projects to limit the number of studies to report on
        @study_config = Hash.new
        @study_filter_pmids = ""
        @study_filter_titles = ""
        @study_filter_authors = ""
    
        # Project record defaults ---------------------------------------------------------------------------------------------------
        @project_config = Hash.new
        @project_config["prj_0"] = ["title", "Title", 1]
        @project_config["prj_1"] = ["description", "Description", 1]
        @project_config["prj_2"] = ["notes", "Notes", 0]
        @project_config["prj_3"] = ["sponsor", "Sponsor", 1]
        @project_config["prj_4"] = ["creatorid", "Created By", 0]
        @project_config["prj_5"] = ["createdate", "Create Date", 0]
        @project_config["prj_6"] = ["updatedate", "Last Updated", 0]
        
        # Publication record defaults ---------------------------------------------------------------------------------------------------
        @publication_config = Hash.new
        @publication_config["pub_0"] = ["pmid", "PubMed", 1]
        @publication_config["pub_1"] = ["altid", "Alternate IDs", 1]
        @publication_config["pub_2"] = ["title", "Title", 0]
        @publication_config["pub_3"] = ["author", "Author(s)", 1]
        @publication_config["pub_4"] = ["authorfirstonly", "First Author Only", 1]
        @publication_config["pub_5"] = ["year", "Year", 1]
        @publication_config["pub_6"] = ["country", "Country", 0]
        @publication_config["pub_7"] = ["journal", "Journal", 0]
        @publication_config["pub_8"] = ["volume", "Volume", 0]
        @publication_config["pub_9"] = ["issue", "Issue", 0]
        
        # Extraction Form list ---------------------------------------------------------------------------------------------------
        @ef_config = Hash.new
        
        # Instantiate individual section configurations ----------------------------------------
        @designdetails_config = DesignDetailsConfig.new
        @arm_config = ArmsConfig.new
        @armdetails_config = ArmDetailsConfig.new
        @baseline_config = BaselineConfig.new
        @outcomedetails_config = OutcomeDetailsConfig.new
        @outcomesgs_config = OutcomeSubgroupConfig.new
        @outcometpts_config = OutcomeTimepointConfig.new
        @outcomemeasures_config = OutcomeMeasConfig.new
        @outcomesx_config = OutcomesConfig.new
        @advevents_config = AdveventsConfig.new
        @qualdims_config = QualityConfig.new
        # Instantiate individual section configurations ----------------------------------------
        
        # Arms record details --------------------------------------------------------------------------------------------------
        @armsrec_config = Hash.new
        @armsrec_config["armsrec_0"] = ["description", "Description", 0]
        @armsrec_config["armsrec_1"] = ["note", "Note", 0]
        
        # Arms list ---------------------------------------------------------------------------------------------------
        @arms_config = Hash.new
        
        # Arms Details record details --------------------------------------------------------------------------------------------------
        @armdrec_config = Hash.new
        @armdrec_config["armdrec_0"] = ["instruction", "Instruction", 0]
        
        # Arms Details list ---------------------------------------------------------------------------------------------------
        @armd_config = Hash.new
        @armdfield_config = Hash.new      # Hash[<arm details idx>.<armdf row idx>.0] = 0 | 1 to indicate show
        @armdmatrix_config = Hash.new      # Hash[<arm details idx>.<armdf row idx>.<armdf col idx>] = 0 | 1 to indicate show
        
        # Design Details record details --------------------------------------------------------------------------------------------------
        @ddrec_config = Hash.new
        @ddrec_config["ddrec_0"] = ["instructions", "Instructions", 0]
        
        # Design Details list ---------------------------------------------------------------------------------------------------
        @dd_config = Hash.new
        @ddfield_config = Hash.new      # Hash[<design details idx>.<ddf row idx>.0] = 0 | 1 to indicate show
        @ddmatrix_config = Hash.new      # Hash[<design details idx>.<ddf row idx>.<ddf col idx>] = 0 | 1 to indicate show
        
        # Baseline Characteristics list ---------------------------------------------------------------------------------------------------
        @bl_config = Hash.new
        @blfield_config = Hash.new      # Hash[<baseline idx>.<blf row idx>.0] = 0 | 1 to indicate show
        @blmatrix_config = Hash.new      # Hash[<baseline idx>.<blf row idx>.<blf col idx>] = 0 | 1 to indicate show
        
        # Outcomes list ---------------------------------------------------------------------------------------------------
        @outcomes_config = Hash.new
        
        # Outcome Arms list ---------------------------------------------------------------------------------------------------
        @outcomearms_config = Hash.new
        
        # Outcome Subgroup list ---------------------------------------------------------------------------------------------------
        @outcomesg_config = Hash.new
        
        # Outcome Time point list ---------------------------------------------------------------------------------------------------
        @outcometp_config = Hash.new
        
        # Outcome Measures list ---------------------------------------------------------------------------------------------------
        @outcomemeas_config = Hash.new
        
        # Outcome Measures record details --------------------------------------------------------------------------------------------------
        @outcomerec_config = Hash.new
        @outcomerec_config["outmeasrec_0"] = ["description", "Description", 0]
        @outcomerec_config["outmeasrec_1"] = ["note", "Note", 0]
        
        # Outcome Details record details --------------------------------------------------------------------------------------------------
        @outcomedrec_config = Hash.new
        @outcomedrec_config["outcomedrec_0"] = ["instruction", "Instruction", 0]
        
        # Outcome Details list ---------------------------------------------------------------------------------------------------
        @outcomed_config = Hash.new
        @outcomedfield_config = Hash.new      # Hash[<outcome details idx>.<outdf row idx>.0] = 0 | 1 to indicate show
        @outcomedmatrix_config = Hash.new      # Hash[<outcome details idx>.<outdf row idx>.<outdf col idx>] = 0 | 1 to indicate show
        
        # Adverse Events record details --------------------------------------------------------------------------------------------------
        @advevtrec_config = Hash.new
        @advevtrec_config["advrec_0"] = ["description", "Description", 0]
        
        # Adverse Events list ---------------------------------------------------------------------------------------------------
        @advevt_config = Hash.new
        
        # Quality Dimensions record details --------------------------------------------------------------------------------------------------
        @qualdimrec_config = Hash.new
        @qualdimrec_config["qualrec_0"] = ["note", "Field Notes", 0]
        
        # Quality Dimensions list ---------------------------------------------------------------------------------------------------
        @qualdim_config = Hash.new
        
        # Within Arms Comparison list ---------------------------------------------------------------------------------------------------
        @wac_config = Hash.new
        
        # Between Arms Comparison list ---------------------------------------------------------------------------------------------------
        @bac_config = Hash.new
    end
    
    def setConfig(reportset)
        nsize = reportset.size();
        if nsize > 0
            for idx in 0..nsize - 1
                @study_config["study_"+idx.to_s] = [reportset.getStudyTitle(idx), reportset.getStudyTitle(idx), 1, reportset.getStudyID(idx)]
            end
        end    
    
        puts "..........reportconfig::adding report set"
        @project_id = reportset.getProjectID()
        puts "..........reportconfig::adding report set for project "+@project_id.to_s
        
        nsize = reportset.getEFSize()
        if nsize > 0
            for idx in 0..nsize - 1
                @ef_config["ef_"+idx.to_s] = [reportset.getEFTitle(idx), "["+reportset.getEFID(idx).to_s+"] "+reportset.getEFTitle(idx), 1, reportset.getEFID(idx)]
                # ------------------------ New Container Design -----------------------------------------
                # Add reportset sections to reportconfig containers --------------------------------------------
                @designdetails_config.setConfig(reportset.getDesignDetails(reportset.getEFID(idx)))
                @arm_config.setConfig(reportset.getArms(reportset.getEFID(idx)))
                @armdetails_config.setConfig(reportset.getArmDetails(reportset.getEFID(idx)))
                @armdetails_config.setArmsConfig(@arm_config)
                @baseline_config.setConfig(reportset.getBaseline(reportset.getEFID(idx)))
                @baseline_config.setArmsConfig(@arm_config)
                @outcomedetails_config.setConfig(reportset.getOutcomeDetails(reportset.getEFID(idx)))
                @outcomesgs_config.setConfig(reportset.getOutcomeSubgroups(reportset.getEFID(idx)))
                @outcometpts_config.setConfig(reportset.getOutcomeTimepoints(reportset.getEFID(idx)));
                @outcomemeasures_config.setConfig(reportset.getOutcomeMeasures(reportset.getEFID(idx)));
                @outcomesx_config.setConfig(reportset.getOutcomes(reportset.getEFID(idx)));
                @advevents_config.setConfig(reportset.getAdvEvents(reportset.getEFID(idx)));
                @advevents_config.setArmsConfig(@arm_config)
                @qualdims_config.setConfig(reportset.getQuality(reportset.getEFID(idx)));
                # ------------------------ New Container Design -----------------------------------------
            end
        end    
        
        nsize = reportset.getNumDistinctArms()
        if nsize > 0
            for idx in 0..nsize - 1
                @arms_config["arms_"+idx.to_s] = [reportset.getArmName(idx), reportset.getArmName(idx), 0]
            end
        end   
        
        
        # Arm Details --------------------------------------------------------------------------------------------------
        nsize = reportset.getNumDistinctArmDetails()
        if nsize > 0
            for idx in 0..nsize - 1
                @armd_config["armd_"+idx.to_s] = [reportset.getArmDetailsName(idx), reportset.getArmDetailsName(idx), 0]
                if (reportset.getNumArmDetailsRows(idx) == 0) &&
                    (reportset.getNumDistinctArmDetailsCols(idx) == 0)
                    # Single value 
                elsif reportset.getNumDistinctArmDetailsCols(idx) == 0
                    # Row only
                    armdrnames = reportset.getArmDetailsRowNames(idx)
                    armdfidx = 0
                    fieldnames = Hash.new 
                    armdrnames.each do |name|
                        fieldnames["armd_"+idx.to_s+"."+armdfidx.to_s+".0"] = [name, name, 0]
                        armdfidx = armdfidx + 1
                    end
                    @armdfield_config["armd_"+idx.to_s] = fieldnames
                else
                    # Table format
                    armdrnames = reportset.getArmDetailsRowNames(idx)
                    armdcnames = reportset.getArmDetailsColNames(idx)
                    puts "reportconfig::ARMDETAILS - armdrnames="+armdrnames.to_s
                    puts "reportconfig::ARMDETAILS - armdcnames="+armdcnames.to_s
                    armdfidx = 0
                    matrixnames = Hash.new 
                    armdrnames.each do |name|
                        matrixnames["armd_"+idx.to_s+"."+armdfidx.to_s+".x"] = [name, name, 0]
                        carmdfidx = 0
                        armdcnames.each do |cname|
                            matrixnames["armd_"+idx.to_s+".x."+carmdfidx.to_s] = [cname, cname, 0]
                            matrixnames["armd_"+idx.to_s+"."+armdfidx.to_s+"."+carmdfidx.to_s] = [name+"|"+cname, name+"|"+cname, 0]
                            carmdfidx = carmdfidx + 1
                        end
                        armdfidx = armdfidx + 1
                    end
                    @armdmatrix_config["armd_"+idx.to_s+".rows"] = armdrnames
                    @armdmatrix_config["armd_"+idx.to_s+".cols"] = armdcnames
                    @armdmatrix_config["armd_"+idx.to_s] = matrixnames
                end
            end
        end   
        
        # Design Details --------------------------------------------------------------------------------------------------
        nsize = reportset.getNumDistinctDesignDetails()
        if nsize > 0
            for idx in 0..nsize - 1
                @dd_config["dd_"+idx.to_s] = [reportset.getDesignDetailsName(idx), reportset.getDesignDetailsName(idx), 0]
                if (reportset.getNumDesignDetailsRows(idx) == 0) &&
                    (reportset.getNumDistinctDesignDetailsCols(idx) == 0)
                    # Single value 
                elsif reportset.getNumDistinctDesignDetailsCols(idx) == 0
                    # Row only
                    ddrnames = reportset.getDesignDetailsRowNames(idx)
                    ddfidx = 0
                    fieldnames = Hash.new 
                    ddrnames.each do |name|
                        fieldnames["dd_"+idx.to_s+"."+ddfidx.to_s+".0"] = [name, name, 0]
                        ddfidx = ddfidx + 1
                    end
                    @ddfield_config["dd_"+idx.to_s] = fieldnames
                else
                    # Table format
                    ddrnames = reportset.getDesignDetailsRowNames(idx)
                    ddcnames = reportset.getDesignDetailsColNames(idx)
                    ddfidx = 0
                    matrixnames = Hash.new 
                    ddrnames.each do |name|
                        matrixnames["dd_"+idx.to_s+"."+ddfidx.to_s+".x"] = [name, name, 0]
                        cddfidx = 0
                        ddcnames.each do |cname|
                            matrixnames["dd_"+idx.to_s+".x."+cddfidx.to_s] = [cname, cname, 0]
                            matrixnames["dd_"+idx.to_s+"."+ddfidx.to_s+"."+cddfidx.to_s] = [name+"|"+cname, name+"|"+cname, 0]
                            cddfidx = cddfidx + 1
                        end
                        ddfidx = ddfidx + 1
                    end
                    @ddmatrix_config["dd_"+idx.to_s+".rows"] = ddrnames
                    @ddmatrix_config["dd_"+idx.to_s+".cols"] = ddcnames
                    @ddmatrix_config["dd_"+idx.to_s] = matrixnames
                end
            end
        end   
        
        # Baseline --------------------------------------------------------------------------------------------------
        nsize = reportset.getNumDistinctBaselines()
        if nsize > 0
            for idx in 0..nsize - 1
                @bl_config["bl_"+idx.to_s] = [reportset.getBaselinesName(idx), reportset.getBaselinesName(idx), 0]
                if (reportset.getNumBaselineRows(idx) == 0) &&
                    (reportset.getNumDistinctBaselineCols(idx) == 0)
                    # Single value 
                elsif reportset.getNumDistinctBaselineCols(idx) == 0
                    # Row only
                    blrnames = reportset.getBaselineRowNames(idx)
                    blfidx = 0
                    fieldnames = Hash.new 
                    blrnames.each do |name|
                        fieldnames["bl_"+idx.to_s+"."+blfidx.to_s+".0"] = [name, name, 0]
                        blfidx = blfidx + 1
                    end
                    @ddfield_config["bl_"+idx.to_s] = fieldnames
                else
                    # Table format
                    blrnames = reportset.getBaselineRowNames(idx)
                    blcnames = reportset.getBaselineColNames(idx)
                    blfidx = 0
                    matrixnames = Hash.new 
                    blrnames.each do |name|
                        matrixnames["bl_"+idx.to_s+"."+blfidx.to_s+".x"] = [name, name, 0]
                        cblfidx = 0
                        blcnames.each do |cname|
                            matrixnames["bl_"+idx.to_s+".x."+cblfidx.to_s] = [cname, cname, 0]
                            matrixnames["bl_"+idx.to_s+"."+blfidx.to_s+"."+cblfidx.to_s] = [name+"|"+cname, name+"|"+cname, 0]
                            cblfidx = cblfidx + 1
                        end
                        blfidx = blfidx + 1
                    end
                    @blmatrix_config["bl_"+idx.to_s+".rows"] = blrnames
                    @blmatrix_config["bl_"+idx.to_s+".cols"] = blcnames
                    @blmatrix_config["bl_"+idx.to_s] = matrixnames
                end
            end
        end   
        
        # Outcomes --------------------------------------------------------------------------------------------------
        nsize = reportset.getNumDistinctOutcomes()
        if nsize > 0
            for idx in 0..nsize - 1
                @outcomes_config["outcomes_"+idx.to_s] = [reportset.getOutcomeName(idx), reportset.getOutcomeName(idx), 0]
            end
        end   
        
        nsize = reportset.getNumDistinctOutcomeArms()
        if nsize > 0
            for idx in 0..nsize - 1
                @outcomearms_config["outarms_"+idx.to_s] = [reportset.getOutcomeResultsTimePoints(idx), reportset.getOutcomeResultsTimePoints(idx), 0]
            end
        end   
        
        nsize = reportset.getNumDistinctOutcomeSubGroups()
        if nsize > 0
            for idx in 0..nsize - 1
                @outcomesg_config["outsg_"+idx.to_s] = [reportset.getDistinctOutcomeResultsSubGroups(idx), reportset.getDistinctOutcomeResultsSubGroups(idx), 0]
            end
        end   
        
        nsize = reportset.getNumDistinctOutcomeTimePoints()
        if nsize > 0
            for idx in 0..nsize - 1
                @outcometp_config["outtp_"+idx.to_s] = [reportset.getOutcomeResultsTimePoints(idx), reportset.getOutcomeResultsTimePoints(idx), 0]
            end
        end   
        
        nsize = reportset.getNumDistinctOutcomeMeasures()
        if nsize > 0
            for idx in 0..nsize - 1
                @outcomemeas_config["outmeas_"+idx.to_s] = [reportset.getOutcomeResultsMeasure(idx), reportset.getOutcomeResultsMeasure(idx), 0]
            end
        end   
        
        # Outcome Details ---------------------------------------------------------------------------------------------------
        nsize = reportset.getNumDistinctOutcomeDetails()
        if nsize > 0
            for idx in 0..nsize - 1
                @outcomed_config["outd_"+idx.to_s] = [reportset.getOutcomeDetailsName(idx), reportset.getOutcomeDetailsName(idx), 0]
                if (reportset.getNumOutcomeDetailsRows(idx) == 0) &&
                    (reportset.getNumDistinctOutcomeDetailsCols(idx) == 0)
                    # Single value 
                elsif reportset.getNumDistinctOutcomeDetailsCols(idx) == 0
                    # Row only
                    outdrnames = reportset.getOutcomeDetailsRowNames(idx)
                    outdfidx = 0
                    fieldnames = Hash.new 
                    outdrnames.each do |name|
                        fieldnames["outd_"+idx.to_s+"."+outdfidx.to_s+".0"] = [name, name, 0]
                        outdfidx = outdfidx + 1
                    end
                    @ddfield_config["outd_"+idx.to_s] = fieldnames
                else
                    # Table format
                    outdrnames = reportset.getOutcomeDetailsRowNames(idx)
                    outdcnames = reportset.getOutcomeDetailsColNames(idx)
                    outdfidx = 0
                    matrixnames = Hash.new 
                    outdrnames.each do |name|
                        matrixnames["outd_"+idx.to_s+"."+outdfidx.to_s+".x"] = [name, name, 0]
                        coutdfidx = 0
                        outdcnames.each do |cname|
                            matrixnames["outd_"+idx.to_s+".x."+coutdfidx.to_s] = [cname, cname, 0]
                            matrixnames["outd_"+idx.to_s+"."+outdfidx.to_s+"."+coutdfidx.to_s] = [name+"|"+cname, name+"|"+cname, 0]
                            coutdfidx = coutdfidx + 1
                        end
                        outdfidx = outdfidx + 1
                    end
                    @outcomedmatrix_config["outd_"+idx.to_s+".rows"] = outdrnames
                    @outcomedmatrix_config["outd_"+idx.to_s+".cols"] = outdcnames
                    @outcomedmatrix_config["outd_"+idx.to_s] = matrixnames
                end
            end
        end  
        
        # Adverse Events ---------------------------------------------------------------------------------------------------
        nsize = reportset.getNumDistinctAdverseEvents()
        if nsize > 0
            for idx in 0..nsize - 1
                @advevt_config["adv_"+idx.to_s] = [reportset.getAdverseEventsName(idx), reportset.getAdverseEventsName(idx), 0]
            end
        end   
        
        # Quality ---------------------------------------------------------------------------------------------------
        nsize = reportset.getNumDistinctQualityDim()
        if nsize > 0
            for idx in 0..nsize - 1
                qd_name = reportset.getDistinctQualityDimName(idx)
                @qualdim_config["qual_"+idx.to_s] = [qd_name, qd_name, 0]
            end
        end   
        
        nsize = reportset.getNumDistinctWACComparators()
        if nsize > 0
            for idx in 0..nsize - 1
                @wac_config["wac_"+idx.to_s] = [reportset.getWACComparatorName(idx), reportset.getWACComparatorName(idx), 0]
            end
            @wac_config["wac_size"] = nsize
        else
            @wac_config["wac_size"] = 0
        end   
        nsize = reportset.getNumDistinctWACMeasures()
        if nsize > 0
            for idx in 0..nsize - 1
                @wac_config["wac_measure_"+idx.to_s] = [reportset.getWACMeasureName(idx), reportset.getWACMeasureName(idx), 0]
            end
            @wac_config["wac_measure_size"] = nsize
        else
            @wac_config["wac_measure_size"] = 0
        end   
        
        nsize = reportset.getNumDistinctBACComparators()
        if nsize > 0
            for idx in 0..nsize - 1
                @bac_config["bac_"+idx.to_s] = [reportset.getBACComparatorName(idx), reportset.getBACComparatorName(idx), 0]
            end
            @bac_config["bac_size"] = nsize
        else
            @bac_config["bac_size"] = 0
        end   
        nsize = reportset.getNumDistinctBACMeasures()
        if nsize > 0
            for idx in 0..nsize - 1
                @bac_config["bac_measure_"+idx.to_s] = [reportset.getBACMeasureName(idx), reportset.getBACMeasureName(idx), 0]
            end
            @bac_config["bac_measure_size"] = nsize
        else
            @bac_config["bac_measure_size"] = 0
        end   
         
    end
    
    # Add study sections to reportconfig containers --------------------------------------------
    def getDesignDetails()
        return @designdetails_config
    end
    
    def getArms()
        return @arm_config
    end
    
    def getArmDetails()
        return @armdetails_config
    end
    
    def getBaseline()
        return @baseline_config
    end
    
    def getOutcomeDetails()
        return @outcomedetails_config
    end
    
    def getOutcomeSubgroups()
        return @outcomesgs_config
    end
    
    def getOutcomeTimepoints()
        return @outcometpts_config
    end
    
    def getOutcomeMeasures()
        return @outcomemeasures_config
    end
    
    def getOutcomes()
        return @outcomesx_config
    end
    
    def getAdvEvents()
        return @advevents_config
    end
    
    def getQuality()
        return @qualdims_config
    end
    
    # Add study sections to reportconfig containers --------------------------------------------
    
    def loadConfig(project_id, fname)
        if File.exist?(fname)
            @cfgname = fname
            config = YAML.load_file(fname)
            puts "........... reportconfig::loadConfig - loaded config file "+config.to_s
            # Meta data ----------------------------------------------------------------------------------------
            metadata = config["meta"]
            setMetaName(metadata["name"])
            setMetaDescription(metadata["description"])
            
            # Project data ----------------------------------------------------------------------------------------
            cfgdata = config["tablecreator-projects"]
            numitems = cfgdata["n"].to_i
            for idx in 0..numitems - 1
               cfg = cfgdata["prj_"+idx.to_s]
               name = cfg["name"]
               desc = cfg["description"]
               showflag = cfg["show"]
               @project_config["prj_"+idx.to_s] = [name,desc,showflag.to_i]
            end
            
            # Study data ----------------------------------------------------------------------------------------
            cfgdata = config["tablecreator-studies"]
            @study_filter_pmids = cfgdata["study_filter_pmids"]
            @study_filter_titles = cfgdata["study_filter_titles"]
            @study_filter_authors = cfgdata["study_filter_authors"]
            numitems = cfgdata["n"].to_i
            for idx in 0..numitems - 1
               cfg = cfgdata["study_"+idx.to_s]
               name = cfg["name"]
               desc = cfg["description"]
               showflag = cfg["show"]
               @study_config["study_"+idx.to_s] = [name,desc,showflag.to_i]
            end
            
            # Publication data ----------------------------------------------------------------------------------------
            cfgdata = config["tablecreator-pub"]
            numitems = cfgdata["n"].to_i
            for idx in 0..numitems - 1
               cfg = cfgdata["pub_"+idx.to_s]
               name = cfg["name"]
               desc = cfg["description"]
               showflag = cfg["show"]
               @publication_config["pub_"+idx.to_s] = [name,desc,showflag.to_i]
            end
            
            # Design Details config ----------------------------------------------------------------------------------------
            @designdetails_config = DesignDetailsConfig.new
            @designdetails_config.loadConfig(config)
            # Arms config ----------------------------------------------------------------------------------------
            @arm_config = ArmsConfig.new
            @arm_config.loadConfig(config)
            # Arms Details config ----------------------------------------------------------------------------------------
            @armdetails_config = ArmDetailsConfig.new
            @armdetails_config.loadConfig(config)
            # Baseline Characteristics config ----------------------------------------------------------------------------------------
            @baseline_config = BaselineConfig.new
            @baseline_config.loadConfig(config)
            # Outcome Details config ----------------------------------------------------------------------------------------
            @outcomedetails_config = OutcomeDetailsConfig.new
            @outcomedetails_config.loadConfig(config)
            # Outcome Subgroup config ----------------------------------------------------------------------------------------
            @outcomesgs_config = OutcomeSubgroupConfig.new
            @outcomesgs_config.loadConfig(config)
            # Outcome Timepoints config ----------------------------------------------------------------------------------------
            @outcometpts_config = OutcomeTimepointConfig.new
            @outcometpts_config.loadConfig(config)
            # Outcome Measures Record config ----------------------------------------------------------------------------------------
            @outcomemeasures_config = OutcomeMeasConfig.new
            @outcomemeasures_config.loadConfig(config)
            # Outcomes config ----------------------------------------------------------------------------------------
            @outcomesx_config = OutcomesConfig.new
            @outcomesx_config.loadConfig(config)
            # Adverse Events config ----------------------------------------------------------------------------------------
            @advevents_config = AdveventsConfig.new
            @advevents_config.loadConfig(config)
            # Quality Dimensions record data ----------------------------------------------------------------------------------------
            @qualdims_config = QualityConfig.new
            @qualdims_config.loadConfig(config)
        elsif File.exist?("reports/tables/"+project_id+"/default.conf")
            config = YAML.load_file("reports/tables/"+project_id+"/default.conf")
            @cfgname = "reports/tables/"+project_id+"/default.conf"
            puts "........... loaded config file "+config.to_s
        end
    end
    
    def saveConfig(project_id, name, description)
        setMetaName(name)
        setMetaDescription(description)
        @cfgname = "reports/tables/"+project_id+"/"+name+".conf"
        if !File.directory?("reports/tables/"+project_id)
            Dir.mkdir("reports/tables/"+project_id)
        end
        File.open(@cfgname,"w") do | f|
            f.puts "#---------------------------------------------------------"
            f.puts "# Table Creator Form Configuration"
            f.puts "#---------------------------------------------------------"
            f.puts "meta:"
            f.puts "  name: "+getMetaName()
            f.puts "  description: "+getMetaDescription()
            f.puts "  created: "+Time.now.strftime("%Y-%m-%d %H:%M:%S")
            # Project config -------------------------------------------------
            f.puts "# Project --------------------------------------------------------"
            f.puts "tablecreator-projects:"
            f.puts "  n: "+getNumProjectItems().to_s
            for ridx in 0..getNumProjectItems() - 1
                f.puts "  prj_"+ridx.to_s+":"
                # cfg format [<item name>, <item desc>, <0 | 1>]
                cfg = getProjectConfig(ridx)
                name = cfg[0]
                desc = cfg[1]
                showflag = cfg[2]
                f.puts "    name: \""+name+"\""
                f.puts "    description: \""+desc+"\""
                f.puts "    show: "+showflag.to_s
            end
            
            # Specific Publication Selections and filters --------------------------------
            f.puts "# Studies --------------------------------------------------------"
            f.puts "tablecreator-studies:"
            f.puts "  study_filter_pmids: \""+@study_filter_pmids+"\""
            f.puts "  study_filter_titles: \""+@study_filter_titles+"\""
            f.puts "  study_filter_authors: \""+@study_filter_authors+"\""
            f.puts "  n: "+getNumStudyItems().to_s
            for ridx in 0..getNumStudyItems() - 1
                f.puts "  study_"+ridx.to_s+":"
                # cfg format [<item name>, <item desc>, <0 | 1>]
                cfg = getStudyConfig(ridx)
                name = cfg[0]
                desc = cfg[1]
                showflag = cfg[2]
                f.puts "    name: \""+name+"\""
                f.puts "    description: \""+desc+"\""
                f.puts "    show: "+showflag.to_s
            end
            
            # Publication details config -------------------------------------------------
            f.puts "# Publication --------------------------------------------------------"
            f.puts "tablecreator-pub:"
            f.puts "  n: "+getNumPublicationItems().to_s
            for ridx in 0..getNumPublicationItems() - 1
                f.puts "  pub_"+ridx.to_s+":"
                # cfg format [<item name>, <item desc>, <0 | 1>]
                cfg = getPublicationConfig(ridx)
                name = cfg[0]
                desc = cfg[1]
                showflag = cfg[2]
                f.puts "    name: \""+name+"\""
                f.puts "    description: \""+desc+"\""
                f.puts "    show: "+showflag.to_s
            end
            
            
            # Design Details config ----------------------------------------------------------------------------------------
            @designdetails_config.saveConfig(f)
            # Arms config ----------------------------------------------------------------------------------------
            @arm_config.saveConfig(f)
            # Arms Details config ----------------------------------------------------------------------------------------
            @armdetails_config.saveConfig(f)
            # Baseline Characteristics config ----------------------------------------------------------------------------------------
            @baseline_config.saveConfig(f)
            # Outcome Details config ----------------------------------------------------------------------------------------
            @outcomedetails_config.saveConfig(f)
            # Outcome Subgroup config ----------------------------------------------------------------------------------------
            @outcomesgs_config.saveConfig(f)
            # Outcome Timepoints config ----------------------------------------------------------------------------------------
            @outcometpts_config.saveConfig(f)
            # Outcome Measures Record config ----------------------------------------------------------------------------------------
            @outcomemeasures_config.saveConfig(f)
            # Outcomes config ----------------------------------------------------------------------------------------
            @outcomesx_config.saveConfig(f)
            # Adverse Events config ----------------------------------------------------------------------------------------
            @advevents_config.saveConfig(f)
            # Quality Dimensions config ----------------------------------------------------------------------------------------
            @qualdims_config.saveConfig(f)
            
            f.puts "formatbyarms: "+@format_by_arms.to_s
            # Arms config -------------------------------------------------
            f.puts "# Arms ------------------------------------------------"
            f.puts "tablecreator-arms:"
            f.puts "  n: "+getNumArmsItems().to_s
            for ridx in 0..getNumArmsItems() - 1
                f.puts "  arms_"+ridx.to_s+":"
                # cfg format [<item name>, <item desc>, <0 | 1>]
                cfg = getArmsConfig(ridx)
                name = cfg[0]
                desc = cfg[1]
                showflag = cfg[2]
                f.puts "    name: \""+name+"\""
                f.puts "    description: \""+desc+"\""
                f.puts "    show: "+showflag.to_s
            end
            
            # Arms record config -------------------------------------------------
            f.puts "# Arms record ------------------------------------------------"
            f.puts "tablecreator-armsrec:"
            f.puts "  n: "+getNumArmsRecordItems().to_s
            for ridx in 0..getNumArmsRecordItems() - 1
                f.puts "  armsrec_"+ridx.to_s+":"
                # cfg format [<item name>, <item desc>, <0 | 1>]
                cfg = getArmsRecrdConfig(ridx)
                name = cfg[0]
                desc = cfg[1]
                showflag = cfg[2]
                f.puts "    name: \""+name+"\""
                f.puts "    description: \""+desc+"\""
                f.puts "    show: "+showflag.to_s
            end
            
            # Arm Details config -------------------------------------------------
            f.puts "# Arms Details -----------------------------------------------"
            f.puts "tablecreator-armd:"
            f.puts "  n: "+getNumArmDetailsItems().to_s
            for ridx in 0..getNumArmDetailsItems() - 1
                f.puts "  armd_"+ridx.to_s+":"
                # cfg format [<item name>, <item desc>, <0 | 1>]
                cfg = getArmDetailsConfig(ridx)
                name = cfg[0]
                desc = cfg[1]
                showflag = cfg[2]
                f.puts "    name: \""+name+"\""
                f.puts "    description: \""+desc+"\""
                f.puts "    show: "+showflag.to_s
                
                nmatrix = getNumArmDetailsMatrixConfig(ridx)
                nfields = getNumArmDetailsFieldConfig(ridx)
                if nmatrix > 0
                    f.puts "    nmatrix: "+nmatrix.to_s
                    f.puts "    nrows: "+getNumArmDetailsMatrixRowsConfig(ridx).to_s
                    f.puts "    ncols: "+getNumArmDetailsMatrixColsConfig(ridx).to_s
                    armdrnames = getArmDetailsMatrixRowsConfig(ridx)
                    armdcnames = getArmDetailsMatrixColsConfig(ridx)
                    f.puts "    narms: "+armdrnames.size.to_s
                    for armdfidx in 0..armdrnames.size - 1
                        for carmdfidx in 0..armdcnames.size - 1
                            f.puts "    armd_"+armdfidx.to_s+"_"+carmdfidx.to_s+":"
                            f.puts "      name: \""+getArmDetailsMatrixName(ridx,armdfidx,carmdfidx)+"\""
                            f.puts "      description: \""+getArmDetailsMatrixDesc(ridx,armdfidx,carmdfidx)+"\""
                            f.puts "      show: "+getArmDetailsMatrixFlag(ridx,armdfidx,carmdfidx).to_s
                        end
                    end
                elsif nfields > 0
                    f.puts "    nfields: "+nfields.to_s
                    for armdfidx in 0..getNumArmDetailsFieldConfig(ridx) - 1
                        f.puts "    armd_"+armdfidx.to_s+":"
                        f.puts "      name: \""+getArmDetailsFieldName(ridx,armdfidx)+"\""
                        f.puts "      description: \""+getArmDetailsFieldDesc(ridx,armdfidx)+"\""
                        f.puts "      show: "+getArmDetailsFieldFlag(ridx,armdfidx).to_s
                    end
                end
            end
            
            # Arms Details record config -------------------------------------------------
            f.puts "# Arms Details record ------------------------------------------------"
            f.puts "tablecreator-armdrec:"
            f.puts "  n: "+getNumArmDetailsDetailItems().to_s
            for ridx in 0..getNumArmDetailsDetailItems() - 1
                f.puts "  armdrec_"+ridx.to_s+":"
                # cfg format [<item name>, <item desc>, <0 | 1>]
                cfg = getArmDetailsDetailConfig(ridx)
                name = cfg[0]
                desc = cfg[1]
                showflag = cfg[2]
                f.puts "    name: \""+name+"\""
                f.puts "    description: \""+desc+"\""
                f.puts "    show: "+showflag.to_s
            end
            
            # Design Details config -------------------------------------------------
            f.puts "# Design Details ------------------------------------------------"
            f.puts "tablecreator-dd:"
            f.puts "  n: "+getNumDesignDetailsItems().to_s
            for ridx in 0..getNumDesignDetailsItems() - 1
                f.puts "  dd_"+ridx.to_s+":"
                # cfg format [<item name>, <item desc>, <0 | 1>]
                cfg = getDesignDetailsConfig(ridx)
                name = cfg[0]
                desc = cfg[1]
                showflag = cfg[2]
                f.puts "    name: \""+name+"\""
                f.puts "    description: \""+desc+"\""
                f.puts "    show: "+showflag.to_s
                
                nmatrix = getNumDesignDetailsMatrixConfig(ridx)
                nfields = getNumDesignDetailsFieldConfig(ridx)
                if nmatrix > 0
                    f.puts "    nmatrix: "+nmatrix.to_s
                    f.puts "    nrows: "+getNumDesignDetailsMatrixRowsConfig(ridx).to_s
                    f.puts "    ncols: "+getNumDesignDetailsMatrixColsConfig(ridx).to_s
                    ddrnames = getDesignDetailsMatrixRowsConfig(ridx)
                    ddcnames = getDesignDetailsMatrixColsConfig(ridx)
                    f.puts "    narms: "+ddrnames.size.to_s
                    for ddfidx in 0..ddrnames.size - 1
                        for cddfidx in 0..ddcnames.size - 1
                            f.puts "    dd_"+ddfidx.to_s+"_"+cddfidx.to_s+":"
                            f.puts "      name: \""+getDesignDetailsMatrixName(ridx,ddfidx,cddfidx)+"\""
                            f.puts "      description: \""+getDesignDetailsMatrixDesc(ridx,ddfidx,cddfidx)+"\""
                            f.puts "      show: "+getDesignDetailsMatrixFlag(ridx,ddfidx,cddfidx).to_s
                        end
                    end
                elsif nfields > 0
                    f.puts "    nfields: "+nfields.to_s
                    for ddfidx in 0..getNumDesignDetailsFieldConfig(ridx) - 1
                        f.puts "    dd_"+ddfidx.to_s+":"
                        f.puts "      name: \""+getDesignDetailsFieldName(ridx,ddfidx)+"\""
                        f.puts "      description: \""+getDesignDetailsFieldDesc(ridx,ddfidx)+"\""
                        f.puts "      show: "+getDesignDetailsFieldFlag(ridx,ddfidx).to_s
                    end
                end
            end
            
            # Design Details record config -------------------------------------------------
            f.puts "# Design Details record ------------------------------------------------"
            f.puts "tablecreator-ddrec:"
            f.puts "  n: "+getNumDesignDetailsDetailItems().to_s
            for ridx in 0..getNumDesignDetailsDetailItems() - 1
                f.puts "  ddrec_"+ridx.to_s+":"
                # cfg format [<item name>, <item desc>, <0 | 1>]
                cfg = getDesignDetailsDetailConfig(ridx)
                name = cfg[0]
                desc = cfg[1]
                showflag = cfg[2]
                f.puts "    name: \""+name+"\""
                f.puts "    description: \""+desc+"\""
                f.puts "    show: "+showflag.to_s
            end
            
            # Baseline Characteristics config -------------------------------------------------
            f.puts "# Baseline Characteristics ------------------------------------------------"
            f.puts "tablecreator-bl:"
            f.puts "  n: "+getNumBaselineItems().to_s
            for ridx in 0..getNumBaselineItems() - 1
                f.puts "  bl_"+ridx.to_s+":"
                # cfg format [<item name>, <item desc>, <0 | 1>]
                cfg = getBaselineConfig(ridx)
                name = cfg[0]
                desc = cfg[1]
                showflag = cfg[2]
                f.puts "    name: \""+name+"\""
                f.puts "    description: \""+desc+"\""
                f.puts "    show: "+showflag.to_s
            end
            
            # Outcomes config -------------------------------------------------
            f.puts "# Outcomes ------------------------------------------------"
            f.puts "tablecreator-outcomes:"
            f.puts "  n: "+getNumOutcomesItems().to_s
            for ridx in 0..getNumOutcomesItems() - 1
                f.puts "  outcomes_"+ridx.to_s+":"
                # cfg format [<item name>, <item desc>, <0 | 1>]
                cfg = getOutcomesConfig(ridx)
                name = cfg[0]
                desc = cfg[1]
                showflag = cfg[2]
                f.puts "    name: \""+name+"\""
                f.puts "    description: \""+desc+"\""
                f.puts "    show: "+showflag.to_s
            end
            
            # Outcome Subgroups config -------------------------------------------------
            f.puts "# Outcome Subgroups ------------------------------------------------"
            f.puts "tablecreator-outsg:"
            f.puts "  n: "+getNumOutcomeSubgroupsItems().to_s
            for ridx in 0..getNumOutcomeSubgroupsItems() - 1
                f.puts "  outtp_"+ridx.to_s+":"
                # cfg format [<item name>, <item desc>, <0 | 1>]
                cfg = getOutcomeSubgroupsConfig(ridx)
                name = cfg[0]
                desc = cfg[1]
                showflag = cfg[2]
                f.puts "    name: \""+name+"\""
                f.puts "    description: \""+desc+"\""
                f.puts "    show: "+showflag.to_s
            end
            
            # Outcome Timepoints config -------------------------------------------------
            f.puts "# Outcome Time points -----------------------------------------------"
            f.puts "tablecreator-outtp:"
            f.puts "  n: "+getNumOutcomeTimepointsItems().to_s
            for ridx in 0..getNumOutcomeTimepointsItems() - 1
                f.puts "  outtp_"+ridx.to_s+":"
                # cfg format [<item name>, <item desc>, <0 | 1>]
                cfg = getOutcomeTimepointsConfig(ridx)
                name = cfg[0]
                desc = cfg[1]
                showflag = cfg[2]
                f.puts "    name: \""+name+"\""
                f.puts "    description: \""+desc+"\""
                f.puts "    show: "+showflag.to_s
            end
            
            # Outcome Measures config -------------------------------------------------
            f.puts "# Outcome Measure -------------------------------------------------"
            f.puts "tablecreator-outmeas:"
            f.puts "  n: "+getNumOutcomeMeasuresItems().to_s
            for ridx in 0..getNumOutcomeMeasuresItems() - 1
                f.puts "  outmeas_"+ridx.to_s+":"
                # cfg format [<item name>, <item desc>, <0 | 1>]
                cfg = getOutcomeMeasuresConfig(ridx)
                name = cfg[0]
                desc = cfg[1]
                showflag = cfg[2]
                f.puts "    name: \""+name+"\""
                f.puts "    description: \""+desc+"\""
                f.puts "    show: "+showflag.to_s
            end
            
            # Outcome Measures Record config -------------------------------------------------
            f.puts "# Outcome Measure record -------------------------------------------------"
            f.puts "tablecreator-outmeasrec:"
            f.puts "  n: "+getNumOutcomeMeasuresDetailItems().to_s
            for ridx in 0..getNumOutcomeMeasuresDetailItems() - 1
                f.puts "  outmeasrec_"+ridx.to_s+":"
                # cfg format [<item name>, <item desc>, <0 | 1>]
                cfg = getOutcomeMeasuresDetailConfig(ridx)
                name = cfg[0]
                desc = cfg[1]
                showflag = cfg[2]
                f.puts "    name: \""+name+"\""
                f.puts "    description: \""+desc+"\""
                f.puts "    show: "+showflag.to_s
            end
            
            # Outcome Arms config -------------------------------------------------
            f.puts "# Outcome Arms ------------------------------------------------"
            f.puts "tablecreator-outarms:"
            f.puts "  n: "+getNumOutcomeArmsItems().to_s
            for ridx in 0..getNumOutcomeArmsItems() - 1
                f.puts "  outarms_"+ridx.to_s+":"
                # cfg format [<item name>, <item desc>, <0 | 1>]
                cfg = getOutcomeArmsConfig(ridx)
                name = cfg[0]
                desc = cfg[1]
                showflag = cfg[2]
                f.puts "    name: \""+name+"\""
                f.puts "    description: \""+desc+"\""
                f.puts "    show: "+showflag.to_s
            end
            
            # Outcome Details config -------------------------------------------------
            f.puts "# Outcome Details ------------------------------------------------"
            f.puts "tablecreator-outcomed:"
            f.puts "  n: "+getNumOutcomeDetailsItems().to_s
            for ridx in 0..getNumOutcomeDetailsItems() - 1
                f.puts "  outcomed_"+ridx.to_s+":"
                # cfg format [<item name>, <item desc>, <0 | 1>]
                cfg = getOutcomeDetailsConfig(ridx)
                name = cfg[0]
                desc = cfg[1]
                showflag = cfg[2]
                f.puts "    name: \""+name+"\""
                f.puts "    description: \""+desc+"\""
                f.puts "    show: "+showflag.to_s
                
                nmatrix = getNumOutcomeDetailsMatrixConfig(ridx)
                nfields = getNumOutcomeDetailsFieldConfig(ridx)
                if nmatrix > 0
                    f.puts "    nmatrix: "+nmatrix.to_s
                    f.puts "    nrows: "+getNumOutcomeDetailsMatrixRowsConfig(ridx).to_s
                    f.puts "    ncols: "+getNumOutcomeDetailsMatrixColsConfig(ridx).to_s
                    outcomedrnames = getOutcomeDetailsMatrixRowsConfig(ridx)
                    outcomedcnames = getOutcomeDetailsMatrixColsConfig(ridx)
                    f.puts "    narms: "+outcomedrnames.size.to_s
                    for outcomedfidx in 0..outcomedrnames.size - 1
                        for coutcomedfidx in 0..outcomedcnames.size - 1
                            f.puts "    outcomed_"+outcomedfidx.to_s+"_"+coutcomedfidx.to_s+":"
                            f.puts "      name: \""+getOutcomeDetailsMatrixName(ridx,outcomedfidx,coutcomedfidx)+"\""
                            f.puts "      description: \""+getOutcomeDetailsMatrixDesc(ridx,outcomedfidx,coutcomedfidx)+"\""
                            f.puts "      show: "+getOutcomeDetailsMatrixFlag(ridx,outcomedfidx,coutcomedfidx).to_s
                        end
                    end
                elsif nfields > 0
                    f.puts "    nfields: "+nfields.to_s
                    for outcomedfidx in 0..getNumOutcomeDetailsFieldConfig(ridx) - 1
                        f.puts "    outcomed_"+outcomedfidx.to_s+":"
                        f.puts "      name: \""+getOutcomeDetailsFieldName(ridx,outcomedfidx)+"\""
                        f.puts "      description: \""+getOutcomeDetailsFieldDesc(ridx,outcomedfidx)+"\""
                        f.puts "      show: "+getOutcomeDetailsFieldFlag(ridx,outcomedfidx).to_s
                    end
                end
            end
            
            # Outcome Details record config -------------------------------------------------
            f.puts "# Outcome Details record ------------------------------------------------"
            f.puts "tablecreator-outcomedrec:"
            f.puts "  n: "+getNumOutcomeDetailsDetailItems().to_s
            for ridx in 0..getNumOutcomeDetailsDetailItems() - 1
                f.puts "  outcomedrec_"+ridx.to_s+":"
                # cfg format [<item name>, <item desc>, <0 | 1>]
                cfg = getOutcomeDetailsDetailConfig(ridx)
                name = cfg[0]
                desc = cfg[1]
                showflag = cfg[2]
                f.puts "    name: \""+name+"\""
                f.puts "    description: \""+desc+"\""
                f.puts "    show: "+showflag.to_s
            end
            
            # Adverse Events config -------------------------------------------------
            f.puts "# Adverse Events ------------------------------------------------"
            f.puts "tablecreator-adv:"
            f.puts "  n: "+getNumAdverseEventsItems().to_s
            for ridx in 0..getNumAdverseEventsItems() - 1
                f.puts "  adv_"+ridx.to_s+":"
                # cfg format [<item name>, <item desc>, <0 | 1>]
                cfg = getAdverseEventsConfig(ridx)
                name = cfg[0]
                desc = cfg[1]
                showflag = cfg[2]
                f.puts "    name: \""+name+"\""
                f.puts "    description: \""+desc+"\""
                f.puts "    show: "+showflag.to_s
            end
            
            # Adverse Events record config -------------------------------------------------
            f.puts "# Adverse Events record ------------------------------------------------"
            f.puts "tablecreator-advrec:"
            f.puts "  n: "+getNumAdverseEventsDetailItems().to_s
            for ridx in 0..getNumAdverseEventsDetailItems() - 1
                f.puts "  advrec_"+ridx.to_s+":"
                # cfg format [<item name>, <item desc>, <0 | 1>]
                cfg = getAdverseEventsDetailConfig(ridx)
                name = cfg[0]
                desc = cfg[1]
                showflag = cfg[2]
                f.puts "    name: \""+name+"\""
                f.puts "    description: \""+desc+"\""
                f.puts "    show: "+showflag.to_s
            end
            
            # Quality Dimensions config -------------------------------------------------
            f.puts "# Quality Dimensions ------------------------------------------------"
            f.puts "tablecreator-qual:"
            f.puts "  n: "+getNumQualityDimItems().to_s
            for ridx in 0..getNumQualityDimItems() - 1
                f.puts "  qual_"+ridx.to_s+":"
                # cfg format [<item name>, <item desc>, <0 | 1>]
                cfg = getQualityDimConfig(ridx)
                name = cfg[0]
                desc = cfg[1]
                showflag = cfg[2]
                f.puts "    name: \""+name+"\""
                f.puts "    description: \""+desc+"\""
                f.puts "    show: "+showflag.to_s
            end
            
            # Quality Dimensions record config -------------------------------------------------
            f.puts "# Quality Dimensions record ------------------------------------------------"
            f.puts "tablecreator-qualrec:"
            f.puts "  n: "+getNumQualityDimDetailItems().to_s
            for ridx in 0..getNumQualityDimDetailItems() - 1
                f.puts "  qualrec_"+ridx.to_s+":"
                # cfg format [<item name>, <item desc>, <0 | 1>]
                cfg = getQualityDimDetailConfig(ridx)
                name = cfg[0]
                desc = cfg[1]
                showflag = cfg[2]
                f.puts "    name: \""+name+"\""
                f.puts "    description: \""+desc+"\""
                f.puts "    show: "+showflag.to_s
            end
        end
    end
    
    def reportconfig()
        if @cfgname.nil?
            return "reports/tables/default/default.conf"
        else
            return @cfgname
        end
    end
    
    def getMetaName()
        return @meta["name"]
    end
    
    def setMetaName(v)
        @meta["name"] = v
    end
    
    def getMetaDescription()
        return @meta["description"]
    end
    
    def setMetaDescription(v)
        @meta["description"] = v
    end
    
    # Display controls ---------------------------------------------------------------------
    def isFormatByArm()
        return (@format_by_arms == 1)
    end
    
    def setFormatByArm(v)
        @format_by_arms = v
    end
    
    # Default configuration - set to 0 when values are set for any item below
    def isDefault()
        return (@is_default == 1)
    end
    
    def setIsDefault(v)
        @is_default = v
    end
    
    # Calculates the total number of columns to be rendered based on selected display items
    def getTotalCols()
        # Publication items are lumped into one column
        n_cols = 1
        # Design Details ------------------------------------------
        n_cols = n_cols + getNumDesignDetailsCols()
        # Arms ------------------------------------------
        n_cols = n_cols + getNumArmsCols()
        # Arms Details ------------------------------------------
        n_cols = n_cols + getNumArmDetailsCols()
        # Baseline Characteristics ------------------------------------------
        n_cols = n_cols + getNumBaselineCols()
        # Outcome Timepoints ------------------------------------------
        n_cols = n_cols + getNumOutcomeTimepointsCols()
        # Outcome Measures ------------------------------------------
        n_cols = n_cols + getNumOutcomeMeasuresCols()
        # Outcome Results ------------------------------------------
        n_cols = n_cols + getNumOutcomesCols()
        # Outcome Details ------------------------------------------
        n_cols = n_cols + getNumOutcomeDetailsCols()
        # Adverse Events ------------------------------------------
        n_cols = n_cols + getNumAdverseEventsCols()
        # Quality Dimensions ------------------------------------------
        n_cols = n_cols + getNumQualityDimCols()
        # Overall quality column ----------------------------------
        n_cols = n_cols + 1
        return n_cols
    end
    
    # Extraction Forms ------------------------------------------------------------------------------
    def getNumExtractionFormsItems()
        return @ef_config.size()
    end
    
    def getExtractionFormsConfig(idx)
        return @ef_config["ef_"+idx.to_s]
    end
    
    def getExtractionFormID(idx)
        return @ef_config["ef_"+idx.to_s][3]
    end
    
    # Project ------------------------------------------------------------------------------
    def getNumProjectItems()
        return @project_config.size()
    end
    
    def getProjectConfig(idx)
        return @project_config["prj_"+idx.to_s]
    end
    
    def getProjectConfigName(idx)
        return @project_config["prj_"+idx.to_s][0]
    end
    
    def getProjectConfigDesc(idx)
        return @project_config["prj_"+idx.to_s][1]
    end
    
    def getProjectConfigFlag(idx)
        return @project_config["prj_"+idx.to_s][2]
    end
    
    def showProjectItem(idx,v)
        if @project_config["prj_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @project_config["prj_"+idx.to_s][2] = v
    end
    
    def showProject(idx)
        return getProjectConfigFlag(idx) == 1
    end
    
    # Studies ------------------------------------------------------------------------------
    def getNumStudyItems()
        return @study_config.size()
    end
    
    def getStudyConfig(idx)
        return @study_config["study_"+idx.to_s]
    end
    
    def getStudyConfigName(idx)
        return @study_config["study_"+idx.to_s][0]
    end
    
    def getStudyConfigDesc(idx)
        return @study_config["study_"+idx.to_s][1]
    end
    
    def getStudyConfigFlag(idx)
        return @study_config["study_"+idx.to_s][2]
    end
    
    def showStudyItem(idx,v)
        if @study_config["study_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @study_config["study_"+idx.to_s][2] = v
    end
    
    def showStudy(idx)
        return getStudyConfigFlag(idx) == 1
    end
    
    def setStudyFilterPMIDs(fpmids)
        if !fpmids.nil? &&
            fpmids.size > 0
            @study_filter_pmids = fpmids
        else
            @study_filter_pmids = ""
        end
    end
    
    def getStudyFilterPMIDs()
        return @study_filter_pmids
    end
    
    def setStudyFilterTitles(ftitles)
        if !ftitles.nil? &&
            ftitles.size > 0
            @study_filter_titles = ftitles
        else
            @study_filter_titles = ""
        end
    end
    
    def getStudyFilterTitles()
        return @study_filter_titles
    end
    
    def setStudyFilterAuthors(fauthors)
        if !fauthors.nil? &&
            fauthors.size > 0
            @study_filter_authors = fauthors
        else
            @study_filter_authors = ""
        end
    end
    
    def getStudyFilterAuthors()
        return @study_filter_authors
    end
    
    # Publications ------------------------------------------------------------------------------
    def getNumPublicationItems()
        return @publication_config.size()
    end
    
    def getPublicationConfig(idx)
        return @publication_config["pub_"+idx.to_s]
    end
    
    def getPublicationConfigName(idx)
        return @publication_config["pub_"+idx.to_s][0]
    end
    
    def getPublicationConfigDesc(idx)
        return @publication_config["pub_"+idx.to_s][1]
    end
    
    def getPublicationConfigFlag(idx)
        return @publication_config["pub_"+idx.to_s][2]
    end
    
    def showPublicationItem(idx,v)
        if @publication_config["pub_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @publication_config["pub_"+idx.to_s][2] = v
    end
    
    def showPublication(idx)
        return getPublicationConfigFlag(idx) == 1
    end
    
    # Arms ------------------------------------------------------------------------------
    def getNumArmsRecordItems()
        return @armsrec_config.size()
    end
    
    def getArmsRecordConfig(idx)
        return @armsrec_config["armsrec_"+idx.to_s]
    end
    
    def showArmsRecordItem(idx,v)
        if @armsrec_config["armsrec_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @armsrec_config["armsrec_"+idx.to_s][2] = v
    end
    
    def getNumShowArms()
        nshow = 0
        for aidx in 0..getNumArmsItems()
            if showArms(aidx)
                nshow = nshow + 1
            end
        end
        return nshow
    end
    
    def getNumArmsItems()
        return @arms_config.size()
    end
    
    def getArmsConfig(idx)
        return @arms_config["arms_"+idx.to_s]
    end
    
    def getArmsName(idx)
        if idx == @arms_config.size()
            return "total"
        else
            return @arms_config["arms_"+idx.to_s][0]
        end
    end
    
    def getArmsDesc(idx)
        if idx == @arms_config.size()
            return "Total"
        else
            # config format [<name>, <desc>, <0 | 1>]
            return @arms_config["arms_"+idx.to_s][1]
        end
    end
    
    def getArmsFlag(idx)
        if idx == @arms_config.size()
            return 1
        else
            return @arms_config["arms_"+idx.to_s][2]
        end
    end
    
    def showArmsItem(idx,v)
        if @arms_config["arms_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @arms_config["arms_"+idx.to_s][2] = v
    end
    
    def showArms(idx)
        return getArmsFlag(idx) == 1
    end
    
    def getNumShowArms()
        n_cols = 0
        for ridx in 0..getNumArmsItems() - 1
            if showArms(ridx)
                n_cols = n_cols + 1
            end
        end
        return n_cols
    end
    
    def getNumArmsCols()
        n_cols = 0
        for ridx in 0..getNumArmsItems() - 1
            if showArms(ridx)
                n_cols = n_cols + 1
            end
        end
        return n_cols
    end
    
    # Arms Details ------------------------------------------------------------------------------
    def getNumArmDetailsDetailItems()
        return @armdrec_config.size()
    end
    
    def getArmDetailsDetailConfig(idx)
        return @armdrec_config["armdrec_"+idx.to_s]
    end
    
    def showArmDetailsDetailItem(idx,v)
        if @armdrec_config["armdrec_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @armdrec_config["armdrec_"+idx.to_s][2] = v
    end
    
    def getNumArmDetailsItems()
        return @armd_config.size()
    end
    
    def getArmDetailsConfig(idx)
        return @armd_config["armd_"+idx.to_s]
    end
    
    def getArmDetailsName(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @armd_config["armd_"+idx.to_s][0]
    end
    
    def getArmDetailsDesc(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @armd_config["armd_"+idx.to_s][1]
    end
    
    def getArmDetailsFlag(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @armd_config["armd_"+idx.to_s][2]
    end
    
    def showArmDetailsItem(idx,v)
        if @armd_config["armd_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @armd_config["armd_"+idx.to_s][2] = v
    end
    
    def showArmDetails(idx)
        return getArmDetailsFlag(idx) == 1
    end
    
    def getNumArmDetailsCols()
        n_cols = 0
        for ridx in 0..getNumArmDetailsItems() - 1
            if showArmDetails(ridx)
                n = getArmDetailsMatrixNCols(ridx)
                n_cols = n_cols + n
                if (isArmDetailsMatrix(ridx))
                    # Adjust 1 for row titles
                    n_cols = n_cols + 1
                end
            end
        end
        return n_cols
    end
    
    def showArmDetailsItem(idx,v)
        if @armd_config["armd_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @armd_config["armd_"+idx.to_s][2] = v
    end
    
    def getNumShowArmDetails()
        nshow = 0
        for ridx in 0..getNumArmDetailsItems() - 1
            if showArmDetails(ridx)
                nshow = nshow + 1
            end
        end
        return nshow
    end
    
    # Fields (rows) -------------------------------------------------------------
    def getArmDetailsFieldConfig(idx)
        return @armdfield_config["armd_"+idx.to_s]
    end
    
    def getNumArmDetailsFieldConfig(idx)
        fields = @armdfield_config["armd_"+idx.to_s]
        if fields.nil?
            return 0
        else
            return fields.size
        end
    end
    
    def getArmDetailsFieldName(idx,armdfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @armdfield_config["armd_"+idx.to_s]["armd_"+idx.to_s+"."+armdfidx.to_s+".0"][0]
    end
    
    def getArmDetailsFieldDesc(idx,armdfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @armdfield_config["armd_"+idx.to_s]["armd_"+idx.to_s+"."+armdfidx.to_s+".0"][1]
    end
    
    def getArmDetailsFieldFlag(idx,armdfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @armdfield_config["armd_"+idx.to_s]["armd_"+idx.to_s+"."+armdfidx.to_s+".0"][2]
    end
    
    def showArmDetailsField(idx,armdfidx,v)
        if @armdfield_config["armd_"+idx.to_s]["armd_"+idx.to_s+"."+armdfidx.to_s+".0"][2] != v
            setIsDefault(0)
        end
        @armdfield_config["armd_"+idx.to_s]["armd_"+idx.to_s+"."+armdfidx.to_s+".0"][2] = v
    end
    
    # Matrix --------------------------------------------------------------------
    def isArmDetailsMatrix(ridx)
        return (getNumArmDetailsMatrixConfig(ridx) > 0)
    end
    
    def getArmDetailsMatrixConfig(idx)
        return @armdmatrix_config["armd_"+idx.to_s]
    end
    
    def getArmDetailsMatrixRowsConfig(idx)
        return @armdmatrix_config["armd_"+idx.to_s+".rows"]
    end
    
    def getNumArmDetailsMatrixRowsConfig(idx)
        armdrnames = @armdmatrix_config["armd_"+idx.to_s+".rows"]
        if armdrnames.nil?
            return 0
        else
            return armdrnames.size
        end
    end
    
    def getArmDetailsMatrixColsConfig(idx)
        return @armdmatrix_config["armd_"+idx.to_s+".cols"]
    end
    
    def getNumArmDetailsMatrixColsConfig(idx)
        armdcnames = @armdmatrix_config["armd_"+idx.to_s+".cols"]
        if armdcnames.nil?
            return 0
        else
            return armdcnames.size
        end
    end
    
    def getNumArmDetailsMatrixConfig(idx)
        matrix = @armdmatrix_config["armd_"+idx.to_s]
        if matrix.nil?
            return 0
        else
            return matrix.size
        end
    end
    
    def getArmDetailsMatrixName(idx,armdfidx,carmdfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @armdmatrix_config["armd_"+idx.to_s]["armd_"+idx.to_s+"."+armdfidx.to_s+"."+carmdfidx.to_s][0]
    end
    
    def getArmDetailsMatrixDesc(idx,armdfidx,carmdfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @armdmatrix_config["armd_"+idx.to_s]["armd_"+idx.to_s+"."+armdfidx.to_s+"."+carmdfidx.to_s][1]
    end
    
    def getArmDetailsMatrixFlag(idx,armdfidx,carmdfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @armdmatrix_config["armd_"+idx.to_s]["armd_"+idx.to_s+"."+armdfidx.to_s+"."+carmdfidx.to_s][2]
    end
    
    def getArmDetailsMatrixRowFlag(idx,armdfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @armdmatrix_config["armd_"+idx.to_s]["armd_"+idx.to_s+"."+armdfidx.to_s+".x"][2]
    end
    
    def getArmDetailsMatrixColFlag(idx,carmdfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @armdmatrix_config["armd_"+idx.to_s]["armd_"+idx.to_s+".x."+carmdfidx.to_s][2]
    end
    
    def showArmDetailsMatrix(idx,armdfidx,carmdfidx,v)
        if @armdmatrix_config["armd_"+idx.to_s]["armd_"+idx.to_s+"."+armdfidx.to_s+"."+carmdfidx.to_s][2] != v
            setIsDefault(0)
        end
        @armdmatrix_config["armd_"+idx.to_s]["armd_"+idx.to_s+"."+armdfidx.to_s+"."+carmdfidx.to_s][2] = v
    end
    
    def showArmDetailsMatrixRow(idx,armdfidx,v)
        if @armdmatrix_config["armd_"+idx.to_s]["armd_"+idx.to_s+"."+armdfidx.to_s+".x"][2] != v
            setIsDefault(0)
        end
        @armdmatrix_config["armd_"+idx.to_s]["armd_"+idx.to_s+"."+armdfidx.to_s+".x"][2] = v
    end
    
    def showArmDetailsMatrixCol(idx,carmdfidx,v)
        if @armdmatrix_config["armd_"+idx.to_s]["armd_"+idx.to_s+".x."+carmdfidx.to_s][2] != v
            setIsDefault(0)
        end
        @armdmatrix_config["armd_"+idx.to_s]["armd_"+idx.to_s+".x."+carmdfidx.to_s][2] = v
    end
    
    # These two methods are used by the EXCEL export to calculate how many rows and cols cells are involved
    def getArmDetailsMatrixNCols(ridx)
        nmatrix = getNumArmDetailsMatrixConfig(ridx)
        nfields = getNumArmDetailsFieldConfig(ridx)
        ncols = 0
        if nmatrix > 0
            armdrnames = getArmDetailsMatrixRowsConfig(ridx)
            armdcnames = getArmDetailsMatrixColsConfig(ridx)
            carmdfidx = 0
            armdcnames.each do |colname|
                showcol = getArmDetailsMatrixColFlag(ridx,carmdfidx)
                if showcol.to_s == "1"
                    ncols = ncols + 1 
                end
                carmdfidx = carmdfidx + 1
            end
        else
            ncols = 1
        end
        return ncols
    end
    
    def getArmDetailsMatrixNRows(ridx)
        nmatrix = getNumArmDetailsMatrixConfig(ridx)
        nfields = getNumArmDetailsFieldConfig(ridx)
        nrows = 0
        if nmatrix > 0
            armdrnames = getArmDetailsMatrixRowsConfig(ridx)
            armdcnames = getArmDetailsMatrixColsConfig(ridx)
            for armdfidx in 0..armdrnames.size - 1
                showcol = getArmDetailsMatrixRowFlag(ridx,armdfidx)
                if showcol.to_s == "1" 
                    nrows = nrows + 1 
                end
            end
        else
            nrows = 1
        end
        return nrows
    end
    
    def getNumArmDetailsToDisplay
        armd_ncols = 0;
        for ridx in 0..getNumArmDetailsItems() - 1
            if showArmDetails(ridx)
                armd_ncols = armd_ncols + 1
            end
        end
        return armd_ncols 
    end
    
    # Design Details ------------------------------------------------------------------------------
    def getNumDesignDetailsDetailItems()
        return @ddrec_config.size()
    end
    
    def getDesignDetailsDetailConfig(idx)
        return @ddrec_config["ddrec_"+idx.to_s]
    end
    
    def showDesignDetailsDetailItem(idx,v)
        if @ddrec_config["ddrec_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @ddrec_config["ddrec_"+idx.to_s][2] = v
    end
    
    def getNumDesignDetailsItems()
        return @dd_config.size()
    end
    
    def getDesignDetailsConfig(idx)
        return @dd_config["dd_"+idx.to_s]
    end
    
    def getDesignDetailsName(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @dd_config["dd_"+idx.to_s][0]
    end
    
    def getDesignDetailsDesc(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @dd_config["dd_"+idx.to_s][1]
    end
    
    def getDesignDetailsFlag(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @dd_config["dd_"+idx.to_s][2]
    end
    
    def showDesignDetailsItem(idx,v)
        if @dd_config["dd_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @dd_config["dd_"+idx.to_s][2] = v
    end
    
    def showDesignDetails(idx)
        return getDesignDetailsFlag(idx) == 1
    end
    
    def getNumShowDesignDetails()
        n_cols = 0
        for ridx in 0..getNumDesignDetailsItems() - 1
            if showDesignDetails(ridx)
                n_cols = n_cols + 1
            end
        end
        return n_cols
    end
    
    def getNumDesignDetailsCols()
        n_cols = 0
        for ridx in 0..getNumDesignDetailsItems() - 1
            if showDesignDetails(ridx)
                n_cols = n_cols + 1
            end
        end
        return n_cols
    end
    
    def showDesignDetailsItem(idx,v)
        if @dd_config["dd_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @dd_config["dd_"+idx.to_s][2] = v
    end
    
    def getNumShowDesignDetails()
        nshow = 0
        for ridx in 0..getNumDesignDetailsItems() - 1
            if showDesignDetails(ridx)
                nshow = nshow + 1
            end
        end
        return nshow
    end
    
    # Fields (rows) -------------------------------------------------------------
    def getDesignDetailsFieldConfig(idx)
        return @ddfield_config["dd_"+idx.to_s]
    end
    
    def getNumDesignDetailsFieldConfig(idx)
        fields = @ddfield_config["dd_"+idx.to_s]
        if fields.nil?
            return 0
        else
            return fields.size
        end
    end
    
    def getDesignDetailsFieldName(idx,ddfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @ddfield_config["dd_"+idx.to_s]["dd_"+idx.to_s+"."+ddfidx.to_s+".0"][0]
    end
    
    def getDesignDetailsFieldDesc(idx,ddfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @ddfield_config["dd_"+idx.to_s]["dd_"+idx.to_s+"."+ddfidx.to_s+".0"][1]
    end
    
    def getDesignDetailsFieldFlag(idx,ddfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @ddfield_config["dd_"+idx.to_s]["dd_"+idx.to_s+"."+ddfidx.to_s+".0"][2]
    end
    
    def showDesignDetailsField(idx,ddfidx,v)
        if @ddfield_config["dd_"+idx.to_s]["dd_"+idx.to_s+"."+ddfidx.to_s+".0"][2] != v
            setIsDefault(0)
        end
        @ddfield_config["dd_"+idx.to_s]["dd_"+idx.to_s+"."+ddfidx.to_s+".0"][2] = v
    end
    
    # Matrix --------------------------------------------------------------------
    def isDesignDetailsMatrix(ridx)
        return (getNumDesignDetailsMatrixConfig(ridx) > 0)
    end
    
    def getDesignDetailsMatrixConfig(idx)
        return @ddmatrix_config["dd_"+idx.to_s]
    end
    
    def getDesignDetailsMatrixRowsConfig(idx)
        return @ddmatrix_config["dd_"+idx.to_s+".rows"]
    end
    
    def getNumDesignDetailsMatrixRowsConfig(idx)
        ddrnames = @ddmatrix_config["dd_"+idx.to_s+".rows"]
        if ddrnames.nil?
            return 0
        else
            return ddrnames.size
        end
    end
    
    def getDesignDetailsMatrixColsConfig(idx)
        return @ddmatrix_config["dd_"+idx.to_s+".cols"]
    end
    
    def getNumDesignDetailsMatrixColsConfig(idx)
        ddcnames = @ddmatrix_config["dd_"+idx.to_s+".cols"]
        if ddcnames.nil?
            return 0
        else
            return ddcnames.size
        end
    end
    
    def getNumDesignDetailsMatrixConfig(idx)
        matrix = @ddmatrix_config["dd_"+idx.to_s]
        if matrix.nil?
            return 0
        else
            return matrix.size
        end
    end
    
    def getDesignDetailsMatrixName(idx,ddfidx,cddfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @ddmatrix_config["dd_"+idx.to_s]["dd_"+idx.to_s+"."+ddfidx.to_s+"."+cddfidx.to_s][0]
    end
    
    def getDesignDetailsMatrixDesc(idx,ddfidx,cddfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @ddmatrix_config["dd_"+idx.to_s]["dd_"+idx.to_s+"."+ddfidx.to_s+"."+cddfidx.to_s][1]
    end
    
    def getDesignDetailsMatrixFlag(idx,ddfidx,cddfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @ddmatrix_config["dd_"+idx.to_s]["dd_"+idx.to_s+"."+ddfidx.to_s+"."+cddfidx.to_s][2]
    end
    
    def getDesignDetailsMatrixRowFlag(idx,ddfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @ddmatrix_config["dd_"+idx.to_s]["dd_"+idx.to_s+"."+ddfidx.to_s+".x"][2]
    end
    
    def getDesignDetailsMatrixColFlag(idx,cddfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @ddmatrix_config["dd_"+idx.to_s]["dd_"+idx.to_s+".x."+cddfidx.to_s][2]
    end
    
    def showDesignDetailsMatrix(idx,ddfidx,cddfidx,v)
        if @ddmatrix_config["dd_"+idx.to_s]["dd_"+idx.to_s+"."+ddfidx.to_s+"."+cddfidx.to_s][2] != v
            setIsDefault(0)
        end
        @ddmatrix_config["dd_"+idx.to_s]["dd_"+idx.to_s+"."+ddfidx.to_s+"."+cddfidx.to_s][2] = v
    end
    
    def showDesignDetailsMatrixRow(idx,ddfidx,v)
        if @ddmatrix_config["dd_"+idx.to_s]["dd_"+idx.to_s+"."+ddfidx.to_s+".x"][2] != v
            setIsDefault(0)
        end
        @ddmatrix_config["dd_"+idx.to_s]["dd_"+idx.to_s+"."+ddfidx.to_s+".x"][2] = v
    end
    
    def showDesignDetailsMatrixCol(idx,cddfidx,v)
        if @ddmatrix_config["dd_"+idx.to_s]["dd_"+idx.to_s+".x."+cddfidx.to_s][2] != v
            setIsDefault(0)
        end
        @ddmatrix_config["dd_"+idx.to_s]["dd_"+idx.to_s+".x."+cddfidx.to_s][2] = v
    end
    
    # These two methods are used by the EXCEL export to calculate how many rows and cols cells are involved
    def getDesignDetailsMatrixNCols(ridx)
        nmatrix = getNumDesignDetailsMatrixConfig(ridx)
        nfields = getNumDesignDetailsFieldConfig(ridx)
        ncols = 0
        if nmatrix > 0
            ddrnames = getDesignDetailsMatrixRowsConfig(ridx)
            ddcnames = getDesignDetailsMatrixColsConfig(ridx)
            cddfidx = 0
            ddcnames.each do |colname|
                showcol = getDesignDetailsMatrixColFlag(ridx,cddfidx)
                if showcol.to_s == "1"
                    ncols = ncols + 1 
                end
                cddfidx = cddfidx + 1
            end
        else
            ncols = 1
        end
        return ncols
    end
    
    def getDesignDetailsMatrixNRows(ridx)
        nmatrix = getNumDesignDetailsMatrixConfig(ridx)
        nfields = getNumDesignDetailsFieldConfig(ridx)
        nrows = 0
        if nmatrix > 0
            ddrnames = getDesignDetailsMatrixRowsConfig(ridx)
            ddcnames = getDesignDetailsMatrixColsConfig(ridx)
            for ddfidx in 0..ddrnames.size - 1
                showcol = getDesignDetailsMatrixRowFlag(ridx,ddfidx)
                if showcol.to_s == "1" 
                    nrows = nrows + 1 
                end
            end
        else
            nrows = 1
        end
        return nrows
    end
    
    def getNumDesignDetailsToDisplay
        dd_ncols = 0;
        for ridx in 0..getNumDesignDetailsItems() - 1
            if showDesignDetails(ridx)
                dd_ncols = dd_ncols + 1
            end
        end
        return dd_ncols 
    end
    
    # DD EXCEL Export Methods ------------------------------------------------------------------------------
    def getTotalDesignDetailsEXCELSpan(reportset)
        dd_ncols = 0
        for ddidx in 0..getNumDesignDetailsItems() - 1
            if showDesignDetails(ddidx)
                # For each dd to show - get the total number columns to support the export of this dd
                dd_ncols = dd_ncols + getDesignDetailsEXCELSpan(ddidx,reportset)
            end
        end
        return dd_ncols
    end
    
    def getDesignDetailsEXCELSpan(ddidx,reportset)
        dd_name = getDesignDetailsName(ddidx)
        return reportset.getDesignDetailsEXCELSpan(dd_name)
    end
    
    def getDesignDetailsEXCELLabels(ddidx,reportset)
        dd_name = getDesignDetailsName(ddidx)
        return reportset.getDesignDetailsEXCELLabels(dd_name) 
    end
    
    def getDesignDetailEXCELValues(sidx,ddidx,reportset)
        dd_name = getDesignDetailsName(ddidx)
        dd_values = reportset.getDesignDetailEXCELValues(sidx,dd_name);
        return dd_values
    end
    
    # Baseline Characteristics ------------------------------------------------------------------------------
    def getNumBaselineDetailItems()
        return @baselinerec_config.size()
    end
    
    def getBaselineDetailConfig(idx)
        return @baselinerec_config["blrec_"+idx.to_s]
    end
    
    def showBaselineDetailItem(idx,v)
        if @baselinerec_config["blrec_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @baselinerec_config["blrec_"+idx.to_s][2] = v
    end
    
    def getNumBaselineItems()
        return @bl_config.size()
    end
    
    def getBaselineConfig(idx)
        return @bl_config["bl_"+idx.to_s]
    end
    
    def getBaselineName(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @bl_config["bl_"+idx.to_s][0]
    end
    
    def getBaselineDesc(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @bl_config["bl_"+idx.to_s][1]
    end
    
    def getBaselineFlag(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @bl_config["bl_"+idx.to_s][2]
    end
    
    def showBaselineItem(idx,v)
        if @bl_config["bl_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @bl_config["bl_"+idx.to_s][2] = v
    end
    
    def showBaseline(idx)
        return getBaselineFlag(idx) == 1
    end
    
    def getNumBaselineCols()
        n_cols = 0
        for ridx in 0..getNumBaselineItems() - 1
            if showBaseline(ridx)
                n = getBaselineMatrixNCols(ridx)
                n_cols = n_cols + n
                if (isBaselineMatrix(ridx))
                    # Adjust 1 for row titles
                    n_cols = n_cols + 1
                end
            end
        end
        return n_cols
    end
    
    def showBaselineItem(idx,v)
        if @bl_config["bl_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @bl_config["bl_"+idx.to_s][2] = v
    end
    
    def getNumShowBaseline()
        nshow = 0
        for ridx in 0..getNumBaselineItems() - 1
            if showBaseline(ridx)
                nshow = nshow + 1
            end
        end
        return nshow
    end
    
    # Fields (rows) -------------------------------------------------------------
    def getBaselineFieldConfig(idx)
        return @blfield_config["bl_"+idx.to_s]
    end
    
    def getNumBaselineFieldConfig(idx)
        fields = @blfield_config["bl_"+idx.to_s]
        if fields.nil?
            return 0
        else
            return fields.size
        end
    end
    
    def getBaselineFieldName(idx,blfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @blfield_config["bl_"+idx.to_s]["bl_"+idx.to_s+"."+blfidx.to_s+".0"][0]
    end
    
    def getBaselineFieldDesc(idx,blfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @blfield_config["bl_"+idx.to_s]["bl_"+idx.to_s+"."+blfidx.to_s+".0"][1]
    end
    
    def getBaselineFieldFlag(idx,blfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @blfield_config["bl_"+idx.to_s]["bl_"+idx.to_s+"."+blfidx.to_s+".0"][2]
    end
    
    def showBaselineField(idx,blfidx,v)
        if @blfield_config["bl_"+idx.to_s]["bl_"+idx.to_s+"."+blfidx.to_s+".0"][2] != v
            setIsDefault(0)
        end
        @blfield_config["bl_"+idx.to_s]["bl_"+idx.to_s+"."+blfidx.to_s+".0"][2] = v
    end
    
    # Matrix --------------------------------------------------------------------
    def isBaselineMatrix(ridx)
        return (getNumBaselineMatrixConfig(ridx) > 0)
    end
    
    def getBaselineMatrixConfig(idx)
        return @blmatrix_config["bl_"+idx.to_s]
    end
    
    def getBaselineMatrixRowsConfig(idx)
        return @blmatrix_config["bl_"+idx.to_s+".rows"]
    end
    
    def getNumBaselineMatrixRowsConfig(idx)
        blrnames = @blmatrix_config["bl_"+idx.to_s+".rows"]
        if blrnames.nil?
            return 0
        else
            return blrnames.size
        end
    end
    
    def getBaselineMatrixColsConfig(idx)
        return @blmatrix_config["bl_"+idx.to_s+".cols"]
    end
    
    def getNumBaselineMatrixColsConfig(idx)
        blcnames = @blmatrix_config["bl_"+idx.to_s+".cols"]
        if blcnames.nil?
            return 0
        else
            return blcnames.size
        end
    end
    
    def getNumBaselineMatrixConfig(idx)
        matrix = @blmatrix_config["bl_"+idx.to_s]
        if matrix.nil?
            return 0
        else
            return matrix.size
        end
    end
    
    def getBaselineMatrixName(idx,blfidx,cblfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @blmatrix_config["bl_"+idx.to_s]["bl_"+idx.to_s+"."+blfidx.to_s+"."+cblfidx.to_s][0]
    end
    
    def getBaselineMatrixDesc(idx,blfidx,cblfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @blmatrix_config["bl_"+idx.to_s]["bl_"+idx.to_s+"."+blfidx.to_s+"."+cblfidx.to_s][1]
    end
    
    def getBaselineMatrixFlag(idx,blfidx,cblfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @blmatrix_config["bl_"+idx.to_s]["bl_"+idx.to_s+"."+blfidx.to_s+"."+cblfidx.to_s][2]
    end
    
    def getBaselineMatrixRowFlag(idx,blfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @blmatrix_config["bl_"+idx.to_s]["bl_"+idx.to_s+"."+blfidx.to_s+".x"][2]
    end
    
    def getBaselineMatrixColFlag(idx,cblfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @blmatrix_config["bl_"+idx.to_s]["bl_"+idx.to_s+".x."+cblfidx.to_s][2]
    end
    
    def showBaselineMatrix(idx,blfidx,cblfidx,v)
        if @blmatrix_config["bl_"+idx.to_s]["bl_"+idx.to_s+"."+blfidx.to_s+"."+cblfidx.to_s][2] != v
            setIsDefault(0)
        end
        @blmatrix_config["bl_"+idx.to_s]["bl_"+idx.to_s+"."+blfidx.to_s+"."+cblfidx.to_s][2] = v
    end
    
    def showBaselineMatrixRow(idx,blfidx,v)
        if @blmatrix_config["bl_"+idx.to_s]["bl_"+idx.to_s+"."+blfidx.to_s+".x"][2] != v
            setIsDefault(0)
        end
        @blmatrix_config["bl_"+idx.to_s]["bl_"+idx.to_s+"."+blfidx.to_s+".x"][2] = v
    end
    
    def showBaselineMatrixCol(idx,cblfidx,v)
        if @blmatrix_config["bl_"+idx.to_s]["bl_"+idx.to_s+".x."+cblfidx.to_s][2] != v
            setIsDefault(0)
        end
        @blmatrix_config["bl_"+idx.to_s]["bl_"+idx.to_s+".x."+cblfidx.to_s][2] = v
    end
    
    # These two methods are used by the EXCEL export to calculate how many rows and cols cells are involved
    def getBaselineMatrixNCols(ridx)
        nmatrix = getNumBaselineMatrixConfig(ridx)
        nfields = getNumBaselineFieldConfig(ridx)
        ncols = 0
        if nmatrix > 0
            blrnames = getBaselineMatrixRowsConfig(ridx)
            blcnames = getBaselineMatrixColsConfig(ridx)
            cblfidx = 0
            blcnames.each do |colname|
                showcol = getBaselineMatrixColFlag(ridx,cblfidx)
                if showcol.to_s == "1"
                    ncols = ncols + 1 
                end
                cblfidx = cblfidx + 1
            end
        else
            ncols = 1
        end
        return ncols
    end
    
    def getBaselineMatrixNRows(ridx)
        nmatrix = getNumBaselineMatrixConfig(ridx)
        nfields = getNumBaselineFieldConfig(ridx)
        nrows = 0
        if nmatrix > 0
            blrnames = getBaselineMatrixRowsConfig(ridx)
            blcnames = getBaselineMatrixColsConfig(ridx)
            for blfidx in 0..blrnames.size - 1
                showcol = getBaselineMatrixRowFlag(ridx,blfidx)
                if showcol.to_s == "1" 
                    nrows = nrows + 1 
                end
            end
        else
            nrows = 1
        end
        return nrows
    end
    
    def getNumBaselineToDisplay
        bl_ncols = 0;
        for ridx in 0..getNumBaselineItems() - 1
            if showBaseline(ridx)
                bl_ncols = bl_ncols + 1
            end
        end
        return bl_ncols 
    end
    
    # Outcome Arms ------------------------------------------------------------------------------
    def getNumOutcomeArmsItems()
        return @outcomearms_config.size()
    end
    
    def getOutcomeArmsConfig(idx)
        return @outcomearms_config["outarms_"+idx.to_s]
    end
    
    def getOutcomeArmsName(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomearms_config["outarms_"+idx.to_s][0]
    end
    
    def getOutcomeArmsDesc(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomearms_config["outarms_"+idx.to_s][1]
    end
    
    def getOutcomeArmsFlag(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomearms_config["outarms_"+idx.to_s][2]
    end
    
    def showOutcomeArmsItem(idx,v)
        if @outcomearms_config["outarms_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @outcomearms_config["outarms_"+idx.to_s][2] = v
    end
    
    def showOutcomeArms(idx)
        return getOutcomeArmsFlag(idx) == 1
    end
    
    def getNumOutcomeArmsCols()
        n_cols = 0
        for ridx in 0..getNumOutcomeArmsItems() - 1
            if showOutcomeArms(ridx)
                n_cols = n_cols + 1
            end
        end
        return n_cols
    end
    
    # Outcome Subgroup ------------------------------------------------------------------------------
    def getNumOutcomeSubgroupsItems()
        return @outcomesg_config.size()
    end
    
    def getOutcomeSubgroupsConfig(idx)
        return @outcomesg_config["outsg_"+idx.to_s]
    end
    
    def getOutcomeSubgroupsName(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomesg_config["outsg_"+idx.to_s][0]
    end
    
    def getOutcomeSubgroupsDesc(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomesg_config["outsg_"+idx.to_s][1]
    end
    
    def getOutcomeSubgroupsFlag(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomesg_config["outsg_"+idx.to_s][2]
    end
    
    def showOutcomeSubgroupsItem(idx,v)
        if @outcomesg_config["outsg_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @outcomesg_config["outsg_"+idx.to_s][2] = v
    end
    
    def showOutcomeSubgroups(idx)
        return getOutcomeSubgroupsFlag(idx) == 1
    end
    
    def getNumOutcomeSubgroupsCols()
        n_cols = 0
        for ridx in 0..getNumOutcomeSubgroupsItems() - 1
            if showOutcomeSubgroups(ridx)
                n_cols = n_cols + 1
            end
        end
        return n_cols
    end
    
    # Outcome Timepoints ------------------------------------------------------------------------------
    def getNumOutcomeTimepointsItems()
        return @outcometp_config.size()
    end
    
    def getOutcomeTimepointsConfig(idx)
        return @outcometp_config["outtp_"+idx.to_s]
    end
    
    def getOutcomeTimepointsName(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcometp_config["outtp_"+idx.to_s][0]
    end
    
    def getOutcomeTimepointsDesc(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcometp_config["outtp_"+idx.to_s][1]
    end
    
    def getOutcomeTimepointsFlag(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcometp_config["outtp_"+idx.to_s][2]
    end
    
    def showOutcomeTimepointsItem(idx,v)
        if @outcometp_config["outtp_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @outcometp_config["outtp_"+idx.to_s][2] = v
    end
    
    def showOutcomeTimepoints(idx)
        return getOutcomeTimepointsFlag(idx) == 1
    end
    
    def getNumOutcomeTimepointsCols()
        n_cols = 0
        for ridx in 0..getNumOutcomeTimepointsItems() - 1
            if showOutcomeTimepoints(ridx)
                n_cols = n_cols + 1
            end
        end
        return n_cols
    end
    
    # Outcome Measures ------------------------------------------------------------------------------
    # Outcome Measures Record Details ------------------------------------------------------------------------------
    def getNumOutcomeMeasuresDetailItems()
        return @outcomerec_config.size()
    end
    
    def getOutcomeMeasuresDetailConfig(idx)
        return @outcomerec_config["outmeasrec_"+idx.to_s]
    end
    
    def getOutcomeMeasuresDetailName(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomerec_config["outmeasrec_"+idx.to_s][0]
    end
    
    def getOutcomeMeasuresDetailDesc(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomerec_config["outmeasrec_"+idx.to_s][1]
    end
    
    def getOutcomeMeasuresDetailFlag(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomerec_config["outmeasrec_"+idx.to_s][2]
    end
    
    def showOutcomeMeasuresDetailItem(idx,v)
        if @outcomerec_config["outmeasrec_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @outcomerec_config["outmeasrec_"+idx.to_s][2] = v
    end
    
    # Outcome Measures ------------------------------------------------------------------------------
    def getNumOutcomeMeasuresItems()
        return @outcomemeas_config.size()
    end
    
    def getOutcomeMeasuresConfig(idx)
        return @outcomemeas_config["outmeas_"+idx.to_s]
    end
    
    def getOutcomeMeasuresName(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomemeas_config["outmeas_"+idx.to_s][0]
    end
    
    def getOutcomeMeasuresDesc(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomemeas_config["outmeas_"+idx.to_s][1]
    end
    
    def getOutcomeMeasuresFlag(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomemeas_config["outmeas_"+idx.to_s][2]
    end
    
    def showOutcomeMeasuresItem(idx,v)
        if @outcomemeas_config["outmeas_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @outcomemeas_config["outmeas_"+idx.to_s][2] = v
    end
    
    def showOutcomeMeasures(idx)
        return getOutcomeMeasuresFlag(idx) == 1
    end
    
    def getNumOutcomeMeasuresCols()
        n_cols = 0
        for ridx in 0..getNumOutcomeMeasuresItems() - 1
            if showOutcomeMeasures(ridx)
                n_cols = n_cols + 1
            end
        end
        return n_cols
    end
    
    # Outcomes ------------------------------------------------------------------------------
    def getNumOutcomesItems()
        return @outcomes_config.size()
    end
    
    def getOutcomesConfig(idx)
        return @outcomes_config["outcomes_"+idx.to_s]
    end
    
    def getOutcomesName(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomes_config["outcomes_"+idx.to_s][0]
    end
    
    def getOutcomesDesc(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomes_config["outcomes_"+idx.to_s][1]
    end
    
    def getOutcomesFlag(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomes_config["outcomes_"+idx.to_s][2]
    end
    
    def showOutcomesItem(idx,v)
        if @outcomes_config["outcomes_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @outcomes_config["outcomes_"+idx.to_s][2] = v
    end
    
    def showOutcomes(idx)
        return getOutcomesFlag(idx) == 1
    end
    
    def getNumOutcomesCols()
        n_cols = 0
        for ridx in 0..getNumOutcomesItems() - 1
            if showOutcomes(ridx)
                n_cols = n_cols + 1
            end
        end
        return n_cols
    end
    
    # Outcome Details ------------------------------------------------------------------------------
    def getNumOutcomeDetailsDetailItems()
        return @outcomedrec_config.size()
    end
    
    def getOutcomeDetailsDetailConfig(idx)
        return @outcomedrec_config["outcomedrec_"+idx.to_s]
    end
    
    def showOutcomeDetailsDetailItem(idx,v)
        if @outcomedrec_config["outcomedrec_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @outcomedrec_config["outcomedrec_"+idx.to_s][2] = v
    end
    
    def getNumOutcomeDetailsItems()
        return @outcomed_config.size()
    end
    
    def getOutcomeDetailsConfig(idx)
        return @outcomed_config["outd_"+idx.to_s]
    end
    
    def getOutcomeDetailsName(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomed_config["outd_"+idx.to_s][0]
    end
    
    def getOutcomeDetailsDesc(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomed_config["outd_"+idx.to_s][1]
    end
    
    def getOutcomeDetailsFlag(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomed_config["outd_"+idx.to_s][2]
    end
    
    def showOutcomeDetailsItem(idx,v)
        if @outcomed_config["outd_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @outcomed_config["outd_"+idx.to_s][2] = v
    end
    
    def showOutcomeDetails(idx)
        return getOutcomeDetailsFlag(idx) == 1
    end
    
    def getNumShowOutcomeDetails()
        n_cols = 0
        for ridx in 0..getNumOutcomeDetailsItems() - 1
            if showOutcomeDetails(ridx)
                n_cols = n_cols + 1
            end
        end
        return n_cols
    end
    
    def getNumOutcomeDetailsCols()
        n_cols = 0
        for ridx in 0..getNumOutcomeDetailsItems() - 1
            if showOutcomeDetails(ridx)
                n = getOutcomeDetailsMatrixNCols(ridx)
                n_cols = n_cols + n
                if (isOutcomeDetailsMatrix(ridx))
                    # Adjust 1 for row titles
                    n_cols = n_cols + 1
                end
            end
        end
        return n_cols
    end
    
    def showOutcomeDetailsItem(idx,v)
        if @outcomed_config["outd_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @outcomed_config["outd_"+idx.to_s][2] = v
    end
    
    # Fields (rows) -------------------------------------------------------------
    def getOutcomeDetailsFieldConfig(idx)
        return @outcomedfield_config["outd_"+idx.to_s]
    end
    
    def getNumOutcomeDetailsFieldConfig(idx)
        fields = @outcomedfield_config["outd_"+idx.to_s]
        if fields.nil?
            return 0
        else
            return fields.size
        end
    end
    
    def getOutcomeDetailsFieldName(idx,outdfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomedfield_config["outd_"+idx.to_s]["outd_"+idx.to_s+"."+outdfidx.to_s+".0"][0]
    end
    
    def getOutcomeDetailsFieldDesc(idx,outdfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomedfield_config["outd_"+idx.to_s]["outd_"+idx.to_s+"."+outdfidx.to_s+".0"][1]
    end
    
    def getOutcomeDetailsFieldFlag(idx,outdfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomedfield_config["outd_"+idx.to_s]["outd_"+idx.to_s+"."+outdfidx.to_s+".0"][2]
    end
    
    def showOutcomeDetailsField(idx,outdfidx,v)
        if @outcomedfield_config["outd_"+idx.to_s]["outd_"+idx.to_s+"."+outdfidx.to_s+".0"][2] != v
            setIsDefault(0)
        end
        @outcomedfield_config["outd_"+idx.to_s]["outd_"+idx.to_s+"."+outdfidx.to_s+".0"][2] = v
    end
    
    # Matrix --------------------------------------------------------------------
    def isOutcomeDetailsMatrix(ridx)
        return (getNumOutcomeDetailsMatrixConfig(ridx) > 0)
    end
    
    def getOutcomeDetailsMatrixConfig(idx)
        return @outcomedmatrix_config["outd_"+idx.to_s]
    end
    
    def getOutcomeDetailsMatrixRowsConfig(idx)
        return @outcomedmatrix_config["outd_"+idx.to_s+".rows"]
    end
    
    def getNumOutcomeDetailsMatrixRowsConfig(idx)
        outdrnames = @outcomedmatrix_config["outd_"+idx.to_s+".rows"]
        if outdrnames.nil?
            return 0
        else
            return outdrnames.size
        end
    end
    
    def getOutcomeDetailsMatrixColsConfig(idx)
        return @outcomedmatrix_config["outd_"+idx.to_s+".cols"]
    end
    
    def getNumOutcomeDetailsMatrixColsConfig(idx)
        outdcnames = @outcomedmatrix_config["outd_"+idx.to_s+".cols"]
        if outdcnames.nil?
            return 0
        else
            return outdcnames.size
        end
    end
    
    def getNumOutcomeDetailsMatrixConfig(idx)
        matrix = @outcomedmatrix_config["outd_"+idx.to_s]
        if matrix.nil?
            return 0
        else
            return matrix.size
        end
    end
    
    def getOutcomeDetailsMatrixName(idx,outdfidx,coutdfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomedmatrix_config["outd_"+idx.to_s]["outd_"+idx.to_s+"."+outdfidx.to_s+"."+coutdfidx.to_s][0]
    end
    
    def getOutcomeDetailsMatrixDesc(idx,outdfidx,coutdfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomedmatrix_config["outd_"+idx.to_s]["outd_"+idx.to_s+"."+outdfidx.to_s+"."+coutdfidx.to_s][1]
    end
    
    def getOutcomeDetailsMatrixFlag(idx,outdfidx,coutdfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomedmatrix_config["outd_"+idx.to_s]["outd_"+idx.to_s+"."+outdfidx.to_s+"."+coutdfidx.to_s][2]
    end
    
    def getOutcomeDetailsMatrixRowFlag(idx,outdfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomedmatrix_config["outd_"+idx.to_s]["outd_"+idx.to_s+"."+outdfidx.to_s+".x"][2]
    end
    
    def getOutcomeDetailsMatrixColFlag(idx,coutdfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @outcomedmatrix_config["outd_"+idx.to_s]["outd_"+idx.to_s+".x."+coutdfidx.to_s][2]
    end
    
    def showOutcomeDetailsMatrix(idx,outdfidx,coutdfidx,v)
        if @outcomedmatrix_config["outd_"+idx.to_s]["outd_"+idx.to_s+"."+outdfidx.to_s+"."+coutdfidx.to_s][2] != v
            setIsDefault(0)
        end
        @outcomedmatrix_config["outd_"+idx.to_s]["outd_"+idx.to_s+"."+outdfidx.to_s+"."+coutdfidx.to_s][2] = v
    end
    
    def showOutcomeDetailsMatrixRow(idx,outdfidx,v)
        if @outcomedmatrix_config["outd_"+idx.to_s]["outd_"+idx.to_s+"."+outdfidx.to_s+".x"][2] != v
            setIsDefault(0)
        end
        @outcomedmatrix_config["outd_"+idx.to_s]["outd_"+idx.to_s+"."+outdfidx.to_s+".x"][2] = v
    end
    
    def showOutcomeDetailsMatrixCol(idx,coutdfidx,v)
        if @outcomedmatrix_config["outd_"+idx.to_s]["outd_"+idx.to_s+".x."+coutdfidx.to_s][2] != v
            setIsDefault(0)
        end
        @outcomedmatrix_config["outd_"+idx.to_s]["outd_"+idx.to_s+".x."+coutdfidx.to_s][2] = v
    end
    
    # These two methods are used by the EXCEL export to calculate how many rows and cols cells are involved
    def getOutcomeDetailsMatrixNCols(ridx)
        nmatrix = getNumOutcomeDetailsMatrixConfig(ridx)
        nfields = getNumOutcomeDetailsFieldConfig(ridx)
        ncols = 0
        if nmatrix > 0
            outdrnames = getOutcomeDetailsMatrixRowsConfig(ridx)
            outdcnames = getOutcomeDetailsMatrixColsConfig(ridx)
            coutdfidx = 0
            outdcnames.each do |colname|
                showcol = getOutcomeDetailsMatrixColFlag(ridx,coutdfidx)
                if showcol.to_s == "1"
                    ncols = ncols + 1 
                end
                coutdfidx = coutdfidx + 1
            end
        else
            ncols = 1
        end
        return ncols
    end
    
    def getOutcomeDetailsMatrixNRows(ridx)
        nmatrix = getNumOutcomeDetailsMatrixConfig(ridx)
        nfields = getNumOutcomeDetailsFieldConfig(ridx)
        nrows = 0
        if nmatrix > 0
            outdrnames = getOutcomeDetailsMatrixRowsConfig(ridx)
            outdcnames = getOutcomeDetailsMatrixColsConfig(ridx)
            for outdfidx in 0..outdrnames.size - 1
                showcol = getOutcomeDetailsMatrixRowFlag(ridx,outdfidx)
                if showcol.to_s == "1" 
                    nrows = nrows + 1 
                end
            end
        else
            nrows = 1
        end
        return nrows
    end
    
    def getNumOutcomeDetailsToDisplay
        outd_ncols = 0;
        for ridx in 0..getNumOutcomeDetailsItems() - 1
            if showOutcomeDetails(ridx)
                outd_ncols = outd_ncols + 1
            end
        end
        return outd_ncols 
    end
    
    # Adverse Events ------------------------------------------------------------------------------
    def getNumAdverseEventsDetailItems()
        return @advevtrec_config.size()
    end
    
    def getAdverseEventsDetailConfig(idx)
        return @advevtrec_config["advrec_"+idx.to_s]
    end
    
    def showAdverseEventsDetailItem(idx,v)
        if @advevtrec_config["advrec_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @advevtrec_config["advrec_"+idx.to_s][2] = v
    end
    
    def getNumAdverseEventsItems()
        return @advevt_config.size()
    end
    
    def getAdverseEventsConfig(idx)
        return @advevt_config["adv_"+idx.to_s]
    end
    
    def getAdverseEventsName(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @advevt_config["adv_"+idx.to_s][0]
    end
    
    def getAdverseEventsDesc(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @advevt_config["adv_"+idx.to_s][1]
    end
    
    def getAdverseEventsFlag(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @advevt_config["adv_"+idx.to_s][2]
    end
    
    def showAdverseEventsItem(idx,v)
        if @advevt_config["adv_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @advevt_config["adv_"+idx.to_s][2] = v
    end
    
    def showAdverseEvents(idx)
        return @advevt_config["adv_"+idx.to_s][2] == 1
    end
    
    def getNumAdverseEventsCols()
        n_cols = 0
        for ridx in 0..getNumAdverseEventsItems() - 1
            if showAdverseEvents(ridx)
                n_cols = n_cols + 1
            end
        end
        return n_cols
    end
    
    # Quality Dimensions ------------------------------------------------------------------------------
    def getNumQualityDimDetailItems()
        return @qualdimrec_config.size()
    end
    
    def getQualityDimDetailConfig(idx)
        return @qualdimrec_config["qualrec_"+idx.to_s]
    end
    
    def showQualityDimDetailItem(idx,v)
        if @qualdimrec_config["qualrec_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @qualdimrec_config["qualrec_"+idx.to_s][2] = v
    end
    
    def getNumQualityDimItems()
        return @qualdim_config.size()
    end
    
    def getQualityDimConfig(idx)
        return @qualdim_config["qual_"+idx.to_s]
    end
    
    def getQualityDimName(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @qualdim_config["qual_"+idx.to_s][0]
    end
    
    def getQualityDimDesc(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @qualdim_config["qual_"+idx.to_s][1]
    end
    
    def getQualityDimFlag(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @qualdim_config["qual_"+idx.to_s][2]
    end
    
    def showQualityDimItem(idx,v)
        if @qualdim_config["qual_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @qualdim_config["qual_"+idx.to_s][2] = v
    end
    
    def showQualityDim(idx)
        return @qualdim_config["qual_"+idx.to_s][2] == 1
    end
    
    def getNumQualityDimCols()
        n_cols = 0
        for ridx in 0..getNumQualityDimItems() - 1
            if showQualityDim(ridx)
                n_cols = n_cols + 1
            end
        end
        return n_cols
    end
    
    # Within Arms Comparisons --------------------------------------------------------------
    def getNumWAC()
        return @wac_config.size()
    end
    
    def getNumWACItems()
        return @wac_config["wac_size"].to_i
    end
    
    def getWACConfig(idx)
        # Comparators
        return @wac_config["wac_"+idx.to_s]
    end
    
    def getWACName(idx)
        # Comparators - config format [<name>, <desc>, <0 | 1>]
        return @wac_config["wac_"+idx.to_s][0]
    end
    
    def getWACDesc(idx)
        # Comparators - config format [<name>, <desc>, <0 | 1>]
        return @wac_config["wac_"+idx.to_s][1]
    end
    
    def getWACFlag(idx)
        # Comparators - config format [<name>, <desc>, <0 | 1>]
        return @wac_config["wac_"+idx.to_s][2]
    end
    
    def showWACItem(idx,v)
        if @wac_config["wac_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @wac_config["wac_"+idx.to_s][2] = v
    end
    
    def showWAC(idx)
        return @wac_config["wac_"+idx.to_s][2] == 1
    end
    
    def getNumWACCols()
        n_cols = 0
        for ridx in 0..getNumWACItems() - 1
            if showWAC(ridx)
                n_cols = n_cols + 1
            end
        end
        return n_cols
    end
    
    # Comparison Measures -----------------------------------
    def getNumWACMeasureItems()
        return @wac_config["wac_measure_size"].to_i
    end
    
    def getWACMeasureConfig(idx)
        # Comparators
        return @wac_config["wac_measure_"+idx.to_s]
    end
    
    def getWACMeasureName(idx)
        # Comparators - config format [<name>, <desc>, <0 | 1>]
        return @wac_config["wac_measure_"+idx.to_s][0]
    end
    
    def getWACMeasureDesc(idx)
        # Comparators - config format [<name>, <desc>, <0 | 1>]
        return @wac_config["wac_measure_"+idx.to_s][1]
    end
    
    def getWACMeasureFlag(idx)
        # Comparators - config format [<name>, <desc>, <0 | 1>]
        return @wac_config["wac_measure_"+idx.to_s][2]
    end
    
    def showWACMeasureItem(idx,v)
        if @wac_config["wac_measure_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @wac_config["wac_measure_"+idx.to_s][2] = v
    end
    
    def showWACMeasure(idx)
        return @wac_config["wac_measure_"+idx.to_s][2] == 1
    end
    
    def getNumWACMeasureCols()
        n_cols = 0
        for ridx in 0..getNumWACMeasureItems() - 1
            if showWACMeasure(ridx)
                n_cols = n_cols + 1
            end
        end
        return n_cols
    end
    
    # Between Arms Comparisons --------------------------------------------------------------
    def getNumBAC()
        return @bac_config.size()
    end
    
    def getNumBACItems()
        return @bac_config["bac_size"].to_i
    end
    
    def getBACConfig(idx)
        # Comparators
        return @bac_config["bac_"+idx.to_s]
    end
    
    def getBACName(idx)
        # Comparators - config format [<name>, <desc>, <0 | 1>]
        return @bac_config["bac_"+idx.to_s][0]
    end
    
    def getBACDesc(idx)
        # Comparators - config format [<name>, <desc>, <0 | 1>]
        return @bac_config["bac_"+idx.to_s][1]
    end
    
    def getBACFlag(idx)
        # Comparators - config format [<name>, <desc>, <0 | 1>]
        return @bac_config["bac_"+idx.to_s][2]
    end
    
    def showBACItem(idx,v)
        if @bac_config["bac_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @bac_config["bac_"+idx.to_s][2] = v
    end
    
    def showBAC(idx)
        return @bac_config["bac_"+idx.to_s][2] == 1
    end
    
    def getNumBACCols()
        n_cols = 0
        for ridx in 0..getNumBACItems() - 1
            if showBAC(ridx)
                n_cols = n_cols + 1
            end
        end
        return n_cols
    end
    
    # Comparison Measures -----------------------------------
    def getNumBACMeasureItems()
        return @bac_config["bac_measure_size"].to_i
    end
    
    def getBACMeasureConfig(idx)
        # Comparator measure
        return @bac_config["bac_measure_"+idx.to_s]
    end
    
    def getBACMeasureName(idx)
        # Comparator measure - config format [<name>, <desc>, <0 | 1>]
        return @bac_config["bac_measure_"+idx.to_s][0]
    end
    
    def getBACMeasureDesc(idx)
        # Comparator measure - config format [<name>, <desc>, <0 | 1>]
        return @bac_config["bac_measure_"+idx.to_s][1]
    end
    
    def getBACMeasureFlag(idx)
        # Comparators - config format [<name>, <desc>, <0 | 1>]
        return @bac_config["bac_measure_"+idx.to_s][2]
    end
    
    def showBACMeasureItem(idx,v)
        if @bac_config["bac_measure_"+idx.to_s][2] != v
            setIsDefault(0)
        end
        @bac_config["bac_measure_"+idx.to_s][2] = v
    end
    
    def showBACMeasure(idx)
        return @bac_config["bac_measure_"+idx.to_s][2] == 1
    end
    
    def getNumBACMeasureCols()
        n_cols = 0
        for ridx in 0..getNumBACMeasureItems() - 1
            if showBACMeasure(ridx)
                n_cols = n_cols + 1
            end
        end
        return n_cols
    end
end
