class Studydata

    # Studydata is a container object containing study data associated with a specific study_id and extraction_form_id. This class
    # is used to aggregate all the study data into a single object
    def load(project_id,study_id,extraction_form_id)
        # First check for cached study data. If none, then load from the database
        # Get site properties
        # Note: - since the cache folder is placed under the public/ folder - cachepath needs to have this pre-pended to it to get the correct file path
        siteproperties = Guiproperties.new
        cachepath = siteproperties.getProjectCachePath()
        cachefname = "public/"+cachepath + "studies/study-"+project_id.to_s+"-"+study_id.to_s+"-"+extraction_form_id.to_s+".yml"
        puts "............ searching for cached studies in "+cachefname+" exists? "+File.exists?(cachefname).to_s
        # ------------ Debug -------------------------
        #cachefname = cachepath + "studies/study-test.yml"
        # ------------ Debug -------------------------
        @test_designdetails = DesignDetailsData.new
        @test_arms = ArmsData.new
        @test_armdetails = ArmDetailsData.new
        @test_baselines = BaselineData.new
        @test_outcomedetails = OutcomeDetailsData.new
        @test_outcomesubgroups = OutcomeSubgroupData.new
        @test_outcometimepoints = OutcomeTimepointData.new
        @test_outcomemeas = OutcomeMeasData.new
        @test_outcomes = OutcomesData.new
        @test_advevents = AdveventsData.new
        @test_qualdims = QualityData.new
        if File.exists?(cachefname)
            loadYAML(project_id,study_id,extraction_form_id,cachefname)
        else
            loadDb(project_id,study_id,extraction_form_id)
        end
        puts ">>>>>>>>>>>>>>>>>>> DesignDetails - "+@test_designdetails.getSectionName().to_s+" N "+@test_designdetails.getNumQuestions().to_s
        puts ">>>>>>>>>>>>>>>>>>> Arms - "+@test_arms.getSectionName().to_s+" N "+@test_arms.getNumQuestions().to_s
        puts ">>>>>>>>>>>>>>>>>>> ArmDetails - "+@test_armdetails.getSectionName().to_s+" N "+@test_armdetails.getNumQuestions().to_s
        puts ">>>>>>>>>>>>>>>>>>> Baseline - "+@test_baselines.getSectionName().to_s+" N "+@test_baselines.getNumQuestions().to_s
        puts ">>>>>>>>>>>>>>>>>>> OutcomeDetails - "+@test_outcomedetails.getSectionName().to_s+" N "+@test_outcomedetails.getNumQuestions().to_s
        puts ">>>>>>>>>>>>>>>>>>> OutcomeSubgroupData - "+@test_outcomesubgroups.getSectionName().to_s+" N "+@test_outcomesubgroups.getNumQuestions().to_s
        puts ">>>>>>>>>>>>>>>>>>> OutcomeTimepointData - "+@test_outcometimepoints.getSectionName().to_s+" N "+@test_outcometimepoints.getNumQuestions().to_s
        puts ">>>>>>>>>>>>>>>>>>> OutcomeMeasData - "+@test_outcomemeas.getSectionName().to_s+" N "+@test_outcomemeas.getNumQuestions().to_s
        puts ">>>>>>>>>>>>>>>>>>> OutcomesData - "+@test_outcomes.getSectionName().to_s+" N "+@test_outcomes.getNumQuestions().to_s
        puts ">>>>>>>>>>>>>>>>>>> AdveventsData - "+@test_advevents.getSectionName().to_s+" N "+@test_advevents.getNumQuestions().to_s
        puts ">>>>>>>>>>>>>>>>>>> QualityData - "+@test_qualdims.getSectionName().to_s+" N "+@test_qualdims.getNumQuestions().to_s
    end
    
    def getDesignDetails()
        return @test_designdetails
    end
    
    def getArms()
        return @test_arms
    end
    
    def getArmDetails()
        return @test_armdetails
    end
    
    def getBaselines()
        return @test_baselines
    end
    
    def getOutcomeDetails()
        return @test_outcomedetails
    end
    
    def getOutcomeSubgroups()
        return @test_outcomesubgroups
    end
    
    def getOutcomeTimepoints()
        return @test_outcometimepoints
    end
    
    def getOutcomeMeasures()
        return @test_outcomemeas
    end
    
    def getOutcomes()
        return @test_outcomes
    end
    
    def getAdvEvents()
        return @test_advevents
    end
    
    def getQuality()
        return @test_qualdims
    end
    
    def loadYAML(project_id,study_id,extraction_form_id,cachefname)
        cachestudy = YAML.load_file(cachefname)
        puts "studydata::loadYAML - loading from "+cachefname
        # Extraction form data
        @efid = extraction_form_id
        @eftitle = cachestudy["ef"]["title"]
        if @eftitle.nil?
            @eftitle = "-"
        end
        @efnotes = cachestudy["ef"]["notes"]
        if @efnotes.nil?
            @efnotes = ""
        end
        
        # Load components ----------------------------------------------
        @test_designdetails.loadYAML(project_id,study_id,extraction_form_id,cachestudy)
        @test_arms.loadYAML(project_id,study_id,extraction_form_id,cachestudy)
        puts "studydata::loadYAML - loading arms details -------------------------------------------------<<"
        @test_armdetails.loadYAML(project_id,study_id,extraction_form_id,cachestudy)
        @test_baselines.loadYAML(project_id,study_id,extraction_form_id,cachestudy)
        @test_outcomedetails.loadYAML(project_id,study_id,extraction_form_id,cachestudy)
        @test_outcomesubgroups.loadYAML(project_id,study_id,extraction_form_id,cachestudy)
        @test_outcometimepoints.loadYAML(project_id,study_id,extraction_form_id,cachestudy)
        @test_outcomemeas.loadYAML(project_id,study_id,extraction_form_id,cachestudy)
        @test_outcomes.loadYAML(project_id,study_id,extraction_form_id,cachestudy)
        @test_advevents.loadYAML(project_id,study_id,extraction_form_id,cachestudy)
        @test_qualdims.loadYAML(project_id,study_id,extraction_form_id,cachestudy)
        
        # Study Arms ---------------------------------------------------
        study = cachestudy["study"]
        @study_id = study["id"].to_i
        @study_creator_id = study["creator_id"].to_i
        @study_created_at = study["created_at"]
        @study_updated_at = study["updated_at"]
        
        # Load publication data ---------------------------------------------------
        publication = cachestudy["publication"]
        
        @alternate_ids = Array.new
        if !publication["numbers"].nil?
            altids = publication["numbers"]
            if altids.size > 0
                altids.each do |altid|
                    @alternate_ids << altid.split("-");
                end
            end
        end
        
        @publication_data = Array.new
        if publication["pmid"].nil?
            @publication_data << "-"
        else
            @publication_data << publication["pmid"]
        end
        if @alternate_ids.size > 0
            @publication_data << getAlternateNumbers()
        else
            @publication_data << "-"
        end
        if publication["title"].nil?
            @publication_data << "-"
        else
            @publication_data << TextUtil.restoreCodedText(publication["title"])
        end
        if publication["author"].nil?
            @publication_data << "-"
        else
            @publication_data << TextUtil.restoreCodedText(publication["author"])
            @publication_data << "-"    # place holder for first author flag
        end
        if publication["year"].nil?
            @publication_data << "-"
        else
            @publication_data << publication["year"]
        end
        if publication["country"].nil?
            @publication_data << "-"
        else
            @publication_data << TextUtil.restoreCodedText(publication["country"])
        end
        if publication["journal"].nil?
            @publication_data << "-"
        else
            @publication_data << TextUtil.restoreCodedText(publication["journal"])
        end
        if publication["volume"].nil?
            @publication_data << "-"
        else
            @publication_data << "Vol "+publication["volume"]
        end
        if publication["issue"].nil?
            @publication_data << "-"
        else
            @publication_data << "Issue "+publication["issue"]
        end
        if publication["trial_title"].nil?
            @publication_data << "-"
        else
            @publication_data << "Trial Title "+TextUtil.restoreCodedText(publication["trial_title"])
        end
        
        # Study Arms ---------------------------------------------------
        # Load arms data
=begin
        Replaced by @test_arms
        @num_arms = cachestudy["arms"]
        @arms_map = cachestudy["arms_map"]
        # Like Outcomes - "Setup" which indicates list of unique [Arms.title] for a given [extraction form id + stucy id] criteria
        @armids = cachestudy["arm_ids"]
        if @armids.nil?
            @armids = Array.new
        end
        @armnames = TextUtil.restoreCodedList(cachestudy["arm_names"])
        if @armnames.nil?
            @armnames = Array.new
        end
=end
        
=begin
        Replaced by @test_armdetails
        # Arm details --------------------------------------------------------
        @armdetails = cachestudy["armdetails"]
        if @armdetails.nil?
            @armdetails = Hash.new
            @armdetails["armd.size"] = 0
        else
            if @armdetails["armd.size"].nil?
                @armdetails["armd.size"] = 0
            else
                # change the data type to int from string
                @armdetails["armd.size"] = @armdetails["armd.size"].to_i
            end
        end
        @armdetailsids = cachestudy["armd_ids"]
        if @armdetailsids.nil?
            @armdetailsids = Array.new
        end
        @armdetailsnames = TextUtil.restoreCodedList(cachestudy["armd_names"])
        if @armdetailsnames.nil?
            @armdetailsnames = Array.new
        end
        # Convert other size fields from string to int data type - keep it in sync with database load method and results
        if getNumArmDetails() > 0
            for armdidx in 0..getNumArmDetails() - 1
                if !@armdetails["armd.armdf."+armdidx.to_s+".size"].nil?
                    @armdetails["armd.armdf."+armdidx.to_s+".size"] = @armdetails["armd.armdf."+armdidx.to_s+".size"].to_i
                end
                if !@armdetails["armd.carmdf."+armdidx.to_s+".size"].nil?
                    @armdetails["armd.carmdf."+armdidx.to_s+".size"] = @armdetails["armd.carmdf."+armdidx.to_s+".size"].to_i
                end
                armd_id = getArmDetailID(armdidx)
                @armids.each do |arm_id|
                    if !@armdetails["armd.armdf."+arm_id.to_s+"."+armd_id.to_s+".size"].nil?
                        @armdetails["armd.armdf."+arm_id.to_s+"."+armd_id.to_s+".size"] = @armdetails["armd.armdf."+arm_id.to_s+"."+armd_id.to_s+".size"].to_i
                    end
                    if !@armdetails["armd.carmdf."+arm_id.to_s+"."+armd_id.to_s+".size"].nil?
                        @armdetails["armd.carmdf."+arm_id.to_s+"."+armd_id.to_s+".size"] = @armdetails["armd.carmdf."+arm_id.to_s+"."+armd_id.to_s+".size"].to_i
                    end
                end
            end
        end
=end
        
=begin
        Replaced by @test_designdetails
        # Design details --------------------------------------------------------
        @designdetails = cachestudy["designdetails"]
        if @designdetails.nil?
            @designdetails = Hash.new
            @designdetails["dd.size"] = 0
        else
            if @designdetails["dd.size"].nil?
                @designdetails["dd.size"] = 0
            else
                @designdetails["dd.size"] = @designdetails["dd.size"].to_i
            end
        end
        if @designdetails["dd.size"] > 0
            for ddidx in 0..@designdetails["dd.size"] - 1
                if !@designdetails["dd.ddf."+ddidx.to_s+".size"].nil?
                    @designdetails["dd.ddf."+ddidx.to_s+".size"] = @designdetails["dd.ddf."+ddidx.to_s+".size"].to_i
                end
                if !@designdetails["dd.cddf."+ddidx.to_s+".size"].nil?
                    @designdetails["dd.cddf."+ddidx.to_s+".size"] = @designdetails["dd.cddf."+ddidx.to_s+".size"].to_i
                end
            end
        end
        @designdetailsids = cachestudy["designd_ids"]
        if @designdetailsids.nil?
            @designdetailsids = Array.new
        end
        @designdetailsnames = TextUtil.restoreCodedList(cachestudy["designd_names"])
        if @designdetailsnames.nil?
            @designdetailsnames = Array.new
        end
=end
        
=begin
        Replaced by @test_baselines
        # Baseline characteristics -------------------------------------------------------------
        # @baseline is a mixed Hash of different structures sorted in different ways
        @baseline = cachestudy["baselinedetails"]
        if @baseline.nil?
            @baseline = Hash.new
            @baseline["bl.size"] = 0
        else
            if @baseline["bl.size"].nil?
                @baseline["bl.size"] = 0
            else
                # change the data type to int from string
                @baseline["bl.size"] = @baseline["bl.size"].to_i
            end
        end
        @baselineids = cachestudy["baseline_ids"]
        if @baselineids.nil?
            @baselineids = Array.new
        end
        @baselinenames = TextUtil.restoreCodedList(cachestudy["baseline_names"])
        if @baselinenames.nil?
            @baselinenames = Array.new
        end
        # Convert other size fields from string to int data type - keep it in sync with database load method and results
        if getNumBaselines() > 0
            for blidx in 0..getNumBaselines() - 1
                if !@baseline["bl.blf."+blidx.to_s+".size"].nil?
                    @baseline["bl.blf."+blidx.to_s+".size"] = @baseline["bl.blf."+blidx.to_s+".size"].to_i
                end
                if !@baseline["bl.cblf."+blidx.to_s+".size"].nil?
                    @baseline["bl.cblf."+blidx.to_s+".size"] = @baseline["bl.cblf."+blidx.to_s+".size"].to_i
                end
                bl_id = getArmDetailID(blidx)
                @armids.each do |arm_id|
                    if !@baseline["bl.blf."+arm_id.to_s+"."+bl_id.to_s+".size"].nil?
                        @baseline["bl.blf."+arm_id.to_s+"."+bl_id.to_s+".size"] = @baseline["bl.blf."+arm_id.to_s+"."+bl_id.to_s+".size"].to_i
                    end
                    if !@baseline["bl.cblf."+arm_id.to_s+"."+bl_id.to_s+".size"].nil?
                        @baseline["bl.cblf."+arm_id.to_s+"."+bl_id.to_s+".size"] = @baseline["bl.cblf."+arm_id.to_s+"."+bl_id.to_s+".size"].to_i
                    end
                end
            end
        end
=end
                
        # Outcomes ---------------------------------------------------
        # Outcomes come in two sets - "Setup" which indicates list of unique [Outcome.title] for a given [extraction form id + stucy id] criteria
        # Outcome results is organized in three dimensions - flattened to <Outcome.title>.<OutcomeTimepoint.[number + time_unit]>.<OutcomeMeasure.title>.<OutcomeMeasure.arm name>
        @outcome_n = cachestudy["outcomes"].to_i
        @outcomeids = cachestudy["outcomes_ids"]
        if @outcomeids.nil?
            @outcomeids = Array.new
        end
        @outcomenames = TextUtil.restoreCodedList(cachestudy["outcomes_names"])
        if @outcomenames.nil?
            @outcomenames = Array.new
        end
        @outcomestimept_ids = cachestudy["outcomes_timept_ids"]
        if @outcomestimept_ids.nil?
            @outcomestimept_ids = Array.new
        end
        @outcomestimept_names = TextUtil.restoreCodedList(cachestudy["outcomes_timept_names"]) 
        if @outcomestimept_names.nil?
            @outcomestimept_names = Array.new
        end
        @outcomesmeas_names = TextUtil.restoreCodedList(cachestudy["outcomes_meas_names"]) 
        if @outcomesmeas_names.nil?
            @outcomesmeas_names = Array.new
        end
        @outcomesarms_names = TextUtil.restoreCodedList(cachestudy["outcomes_arms_names"]) 
        if @outcomesarms_names.nil?
            @outcomesarms_names = Array.new
        end
        @outcomesdata = cachestudy["outcomes_data"] 
        if @outcomesdata.nil?
            @outcomesdata = Hash.new
        end
        # Iterate through the number of outcomes and pick up the subgroup data for each outcome
        # put the results in the @outcomesdata Hash
        @outcomessubgroup_ids = Array.new
        @outcomessubgroup_names = Array.new
        if @outcome_n > 0
            for outidx in 0..@outcome_n - 1
                ids = cachestudy["outcomes_"+outidx.to_s+"_subgroup_ids"] 
                if ids.nil?
                    ids = Array.new
                end
                @outcomesdata["outcomes_"+outidx.to_s+"_subgroup_ids"] = ids
                if !ids.nil? &&
                    ids.size > 0
                    ids.each do |sgid|
                        if !@outcomessubgroup_ids.include?(sgid)
                            @outcomessubgroup_ids << sgid
                        end
                    end
                end
                
                names = TextUtil.restoreCodedList(cachestudy["outcomes_"+outidx.to_s+"_subgroup_names"]) 
                if names.nil?
                    names = Array.new
                end
                @outcomesdata["outcomes_"+outidx.to_s+"_subgroup_names"] = names
                if !names.nil? &&
                    names.size > 0
                    names.each do |sg|
                        if !@outcomessubgroup_names.include?(sg)
                            @outcomessubgroup_names << sg
                        end
                    end
                end
                
                descs = TextUtil.restoreCodedList(cachestudy["outcomes_"+outidx.to_s+"_subgroup_descs"]) 
                if descs.nil?
                    descs = Array.new
                end
                @outcomesdata["outcomes_"+outidx.to_s+"_subgroup_descs"] = descs
                
                ids = cachestudy["outcomes_"+outidx.to_s+"_timepoints_ids"] 
                if ids.nil?
                    ids = Array.new
                end
                @outcomesdata["outcomes_"+outidx.to_s+"_timepoints_ids"] = ids
                
                names = TextUtil.restoreCodedList(cachestudy["outcomes_"+outidx.to_s+"_timepoints_names"]) 
                if names.nil?
                    names = Array.new
                end
                @outcomesdata["outcomes_"+outidx.to_s+"_timepoints_names"] = names
            end
        end
        
=begin
        Replaced by @test_outcomedetails
        # Outcome Details --------------------------------------------------------
        @outcomedetails = cachestudy["outcomedetails"]
        if @outcomedetails.nil?
            @outcomedetails = Hash.new
            @outcomedetails["outd.size"] = 0
        else
            if @outcomedetails["outd.size"].nil?
                @outcomedetails["outd.size"] = 0
            else
                @outcomedetails["outd.size"] = @outcomedetails["outd.size"].to_i
            end
        end
        if @outcomedetails["outd.size"] > 0
            for outdidx in 0..@outcomedetails["outd.size"] - 1
                if !@outcomedetails["outd.outdf."+outdidx.to_s+".size"].nil?
                    @outcomedetails["outd.outdf."+outdidx.to_s+".size"] = @outcomedetails["outd.outdf."+outdidx.to_s+".size"].to_i
                end
                if !@outcomedetails["outd.coutdf."+outdidx.to_s+".size"].nil?
                    @outcomedetails["outd.coutdf."+outdidx.to_s+".size"] = @outcomedetails["outd.coutdf."+outdidx.to_s+".size"].to_i
                end
            end
        end
        @outcomedetailsids = cachestudy["outcomed_ids"]
        if @outcomedetailsids.nil?
            @outcomedetailsids = Array.new
        end
        @outcomedetailsnames = TextUtil.restoreCodedList(cachestudy["outcomed_names"])
        if @outcomedetailsnames.nil?
            @outcomedetailsnames = Array.new
        end
=end
        
        # Adverse Events ----------------------------------------------------------------------------------------------------------------
=begin
        @adverseevents = cachestudy["advevents_data"]
        if @adverseevents.nil?
            @adverseevents = Hash.new
            @adverseevents["adve.size"] = 0
        else
            if @adverseevents["adve.size"].nil?
                @adverseevents["adve.size"] = 0
            else
                @adverseevents["adve.size"] = @adverseevents["adve.size"].to_i
            end
        end
        # AdverseEvent.id is linked to AdverseEventResult.adverse_event_id
        # AdverseEventResult.column_id is linked to AdverseEventColumn.id
        if cachestudy["advevents"].nil?
            @adverseevents["adve.size"] = 0
        else
            @adverseevents["adve.size"] = cachestudy["advevents"].to_i
        end
        @adverseevents["adve.ids"] = cachestudy["advevents_ids"]
        @adverseevents["adve.names"] = TextUtil.restoreCodedList(cachestudy["advevents_names"])
        @adverseevents["adve.rid"] = cachestudy["advevents_rids"]
        @adverseevents["adve.cid"] = cachestudy["advevents_cids"]
        @adverseevents["adve.cname"] = TextUtil.restoreCodedList(cachestudy["advevents_cnames"])
        @adverseevents["adve.cdesc"] = TextUtil.restoreCodedList(cachestudy["advevents_cdesc"])
=end
                
        # Overall Quality Rating ---------------------------------------------------
        @quality_rating = ""
        @quality_id = "-1"
        if !cachestudy["quality_rating"].nil?
            @quality_id = cachestudy["quality_rating"]["id"]
            if !cachestudy["quality_rating"]["current_overall_rating"].nil?
                @quality_rating = cachestudy["quality_rating"]["current_overall_rating"]
            else
                @quality_rating = "-"
            end
        end
        
        # Quality Dimensions ----------------------------------------------------------------------------------------------
=begin
        @quality = cachestudy["quality_data"]
        if @quality.nil?
            @quality = Hash.new
        end
        @quality_ids = cachestudy["quality_ids"]
        @quality_names = TextUtil.restoreCodedList(cachestudy["quality_names"])
        if !@quality_ids.nil?
            for qualdimidx in 0..@quality_ids.size() - 1
                @quality["qd.name."+qualdimidx.to_s] = @quality_names[qualdimidx]
                @quality["qd.id."+qualdimidx.to_s] = @quality_ids[qualdimidx]
            end 
            @quality["qd.size"] = @quality_ids.size()
        else
            @quality["qd.size"] = 0
        end
=end
        
        # Within Arms Comparisons --------------------------------------------------------
        @wac_num = cachestudy["wac"].to_i
        @wac_ids = cachestudy["wac_ids"]
        @wac_timepts = cachestudy["wac_tps"]                                    # Array of [ID | Number | Units]
        @wac_names = TextUtil.restoreCodedList(cachestudy["wac_names"])                  # Comparison time point name <TP X> vs <TP Y>
        @wac_arms = TextUtil.restoreCodedList(cachestudy["wac_arms"])                    # Array of [Arm ID | Arm Name]
        @wac_comp_measures = TextUtil.restoreCodedList(cachestudy["wac_comp_measures"])  # Array of [Measure ID | Measure Title]
        @wac_data = cachestudy["wac_data"]
        
        # Between Arms Comparisons --------------------------------------------------------
        @bac_num = cachestudy["bac"].to_i
        @bac_ids = cachestudy["bac_ids"]
        @bac_arms = TextUtil.restoreCodedList(cachestudy["bac_arms"])                    # Array of [Arm ID | Arm Name]
        @bac_names = TextUtil.restoreCodedList(cachestudy["bac_names"])                  # Comparison arm name <Arm X> vs <Arm Y>
        @bac_timepts = TextUtil.restoreCodedList(cachestudy["bac_tps"])                  # Array of [ID | Number | Units]
        @bac_comp_measures = TextUtil.restoreCodedList(cachestudy["bac_comp_measures"])  # Array of [Measure ID | Measure Title]
        @bac_data = cachestudy["bac_data"]
    end
    
    def loadDb(project_id,study_id,extraction_form_id)
        # clear all data containers
        puts "studydata::loadDb................ load studydata project id "+project_id.to_s+" ef id "+extraction_form_id.to_s
        ef = ExtractionForm.find(:first,:conditions=>["project_id = ? and id = ?", project_id, extraction_form_id])
        @efid = ef.id
        @eftitle = ef.title
        @efnotes = ef.notes
        if @efnotes.nil?
            @efnotes = ""
        end
        @study = Study.find(:first, :conditions=>["project_id = ? and id = ?", project_id,study_id])
        @study_id = @study.id  
        @study_creator_id = @study.creator_id
        @study_created_at = @study.created_at.to_s
        @study_updated_at = @study.updated_at.to_s
        @publication = PrimaryPublication.find(:first, :conditions=>["study_id = ?", study_id])
        if @publication.nil?
            puts "......... Studydta::load - nil publication id "+study_id.to_s
            @alternate_ids = Array.new
        else
            @alternate_ids = PrimaryPublicationNumber.where(:primary_publication_id=>@publication.id).select(["number","number_type"]).order("number_type ASC")
        end                    
    	@qualityratings = QualityRatingDataPoint.find(:first, :conditions=>["extraction_form_id = ? and study_id = ?", extraction_form_id, study_id])
        @arms = Arm.find(:all,:conditions=>["extraction_form_id = ? and study_id = ?", extraction_form_id,study_id])
        # build arms map - id to title value
        @arms_map = Hash.new
        @arms.each do |arm|
            @arms_map[arm.id] = arm.title    
        end
        
        # Publication data, keep in sync with reportconfig order ---------------------------------------------------
        @publication_data = Array.new
        if !@publication.nil?
            if @publication.pmid.nil?
                @publication_data << "-"
            else
                @publication_data << @publication.pmid
            end
            if @alternate_ids.size > 0
                @publication_data << getAlternateNumbers()
            else
                @publication_data << "-"
            end
            if @publication.title.nil?
                @publication_data << "-"
            else
                @publication_data << @publication.title
            end
            if @publication.author.nil?
                @publication_data << "-"
            else
                @publication_data << @publication.author
                @publication_data << "-"    # place holder for first author flag
            end
            if @publication.year.nil?
                @publication_data << "-"
            else
                @publication_data << @publication.year
            end
            if @publication.country.nil?
                @publication_data << "-"
            else
                @publication_data << @publication.country
            end
            if @publication.journal.nil?
                @publication_data << "-"
            else
                @publication_data << @publication.journal
            end
            if @publication.volume.nil?
                @publication_data << "-"
            else
                @publication_data << "Vol "+@publication.volume
            end                                              
            if @publication.issue.nil?
                @publication_data << "-"
            else
                @publication_data << "Issue "+@publication.issue
            end
        end
        
        # Study Arms ---------------------------------------------------
        # Like Outcomes - "Setup" which indicates list of unique [Arms.title] for a given [extraction form id + stucy id] criteria
        arms = Arm.find(:all, :conditions=>["extraction_form_id = ? and study_id = ?", extraction_form_id, study_id], :order => "title")
        @armids = Array.new
        @armnames = Array.new
        outidx = 0
        if !arms.nil? && (arms.size > 0)
            for arm in arms
                @armids << arm.id
                # Collect unique arm names that belong to this study x extraction form
                if !@armnames.include?(arm.title)
                    @armnames << arm.title
                end
            end
        end
        
        # Arm details --------------------------------------------------------
        @armdetails = Hash.new
        @armdetailsnames = Array.new
        armds = ArmDetail.find(:all,:conditions=>["extraction_form_id = ?", extraction_form_id], :order=>"question_number")
        # Using the armds - pull all the entered values via ArmDetailDataPoint(extraction_form_id, armd.id) and store them into a HashMap for lookup
        armdidx = 0
        armds.each do |armd|
            @armdetails["armd.id."+armdidx.to_s+""] = armd.id.to_s
            @armdetails["armd.name."+armdidx.to_s+""] = armd.question
            if !@armdetailsnames.include?(armd.question)
                @armdetailsnames << armd.question
            end
            
            # Use the ArmDetail.field_type to determine if the DD is a single entity or more complex entity
            # involvng multiple ArmDetailFields with rows and columns
            # Saved data values are stored in key format armd.dp.armdidx.rowidx,colidx - single values have rowidx and colidx = 0
            if armd.field_type == "text" || armd.field_type == "radio"
                # Single value DD - set zero rows and columns and armdf sizes
                @armdetails["armd.armdf."+armdidx.to_s+".size"] = 0
                @armdetails["armd.carmdf."+armdidx.to_s+".size"] = 0
                # Get datapoint value if it exists - ArmDetailsDataPoints.arm_detail_field_id really points the ArmDetail.id
                armdval = ArmDetailDataPoint.find(:first,:conditions=>["extraction_form_id = ? and study_id = ? and arm_detail_field_id = ?",extraction_form_id,study_id,armd.id])
                if armdval.nil?
                    @armdetails["armd.dp."+armdidx.to_s+".0.0"] = ""
                elsif armdval.subquestion_value.nil?
                    @armdetails["armd.dp."+armdidx.to_s+".0.0"] = armdval.value.to_s
                else
                    @armdetails["armd.dp."+armdidx.to_s+".0.0"] = armdval.value.to_s + "|" + armdval.subquestion_value.to_s
                end
            elsif armd.field_type == "checkbox"
                # get list of row fields
                @armdetails["armd.armdf."+armdidx.to_s+".size"] = 0
                @armdetails["armd.carmdf."+armdidx.to_s+".size"] = 0
                armdvals = ArmDetailDataPoint.find(:all,:conditions=>["extraction_form_id = ? and study_id = ? and arm_detail_field_id = ?",extraction_form_id,study_id,armd.id], :order=>"id")
                compoundv = ""
                if !armdvals.nil? && (armdvals.size > 0)
                    armdvals.each do |armdval|
                        if compoundv.size > 0
                            compoundv = compoundv + ";"
                        end
                        if armdval.subquestion_value.nil?
                            compoundv = compoundv + armdval.value.to_s
                        else
                            compoundv = compoundv + armdval.value.to_s + "|" + armdval.subquestion_value.to_s
                        end
                    end
                end
                @armdetails["armd.dp."+armdidx.to_s+".0.0"] = compoundv
            else
                # complex matrix data
                # get list of row fields
                rarmdfs = ArmDetailField.find(:all, :conditions=>["arm_detail_id = ? and column_number = 0",armd.id], :order=>"row_number")
                armdfidx = 0;
                rarmdfs.each do |armdf|
                    @armdetails["armd.armdf."+armdidx.to_s+"."+armdfidx.to_s] = armdf.option_text
                    @armdetails["armd.armdf."+armdidx.to_s+"."+armdfidx.to_s+".id"] = armdf.id.to_s
                    armdfidx = armdfidx + 1
                end
                @armdetails["armd.armdf."+armdidx.to_s+".size"] = armdfidx
                
                # check and get column fields
                carmdfs = ArmDetailField.find(:all, :conditions=>["arm_detail_id = ? and column_number > 0 and row_number = 0",armd.id], :order=>"column_number")
                carmdfidx = 0;
                carmdfs.each do |armdf|
                    @armdetails["armd.carmdf."+armdidx.to_s+"."+carmdfidx.to_s] = armdf.option_text
                    @armdetails["armd.carmdf."+armdidx.to_s+"."+carmdfidx.to_s+".id"] = armdf.id.to_s
                    carmdfidx = carmdfidx + 1
                end
                @armdetails["armd.carmdf."+armdidx.to_s+".size"] = carmdfidx
                for armdfidx in 0..rarmdfs.size - 1
                    for carmdfidx in 0..carmdfs.size - 1
                        armdval = ArmDetailDataPoint.find(:first,:conditions=>["extraction_form_id = ? and study_id = ? and arm_detail_field_id = ? and row_field_id = ? and column_field_id = ?",extraction_form_id,study_id,armd.id,@armdetails["armd.armdf."+armdidx.to_s+"."+armdfidx.to_s+".id"].to_i,@armdetails["armd.carmdf."+armdidx.to_s+"."+carmdfidx.to_s+".id"].to_i])
                        if armdval.nil?
                            @armdetails["armd.dp."+armdidx.to_s+"."+armdfidx.to_s+"."+carmdfidx.to_s] = ""
                        elsif armdval.subquestion_value.nil?
                            @armdetails["armd.dp."+armdidx.to_s+"."+armdfidx.to_s+"."+carmdfidx.to_s] = armdval.value.to_s
                        else
                            @armdetails["armd.dp."+armdidx.to_s+"."+armdfidx.to_s+"."+carmdfidx.to_s] = armdval.value.to_s + "|" + armdval.subquestion_value.to_s
                        end
                    end
                end
            end
            armdidx = armdidx + 1 
        end
        @armdetails["armd.size"] = armdidx
        
        # Design details --------------------------------------------------------
        @designdetails = Hash.new
        @designdetailsnames = Array.new
        dds = DesignDetail.find(:all,:conditions=>["extraction_form_id = ?", extraction_form_id], :order=>"question_number")
        # Using the dds - pull all the entered values via DesignDetailDataPoint(extraction_form_id, dd.id) and store them into a HashMap for lookup
        ddidx = 0
        dds.each do |dd|
            @designdetails["dd.id."+ddidx.to_s+""] = dd.id.to_s
            @designdetails["dd.name."+ddidx.to_s+""] = dd.question
            if !@designdetailsnames.include?(dd.question)
                @designdetailsnames << dd.question
            end
            
            # Use the DesignDetail.field_type to determine if the DD is a single entity or more complex entity
            # involvng multiple DesignDetailFields with rows and columns
            # Saved data values are stored in key format dd.dp.ddidx.rowidx,colidx - single values have rowidx and colidx = 0
            if dd.field_type == "text" || dd.field_type == "radio"
                # Single value DD - set zero rows and columns and ddf sizes
                @designdetails["dd.ddf."+ddidx.to_s+".size"] = 0
                @designdetails["dd.cddf."+ddidx.to_s+".size"] = 0
                # Get datapoint value if it exists - DesignDetailsDataPoints.design_detail_field_id really points the DesignDetail.id
                # puts "........studydata - dd ["+ddidx.to_s+"] ef = "+extraction_form_id.to_s+" sid = "+study_id.to_s+" ddf_id = "+dd.id.to_s
                ddval = DesignDetailDataPoint.find(:first,:conditions=>["extraction_form_id = ? and study_id = ? and design_detail_field_id = ?",extraction_form_id,study_id,dd.id])
                if ddval.nil?
                    @designdetails["dd.dp."+ddidx.to_s+".0.0"] = ""
                elsif ddval.subquestion_value.nil?
                    @designdetails["dd.dp."+ddidx.to_s+".0.0"] = ddval.value.to_s
                else
                    @designdetails["dd.dp."+ddidx.to_s+".0.0"] = ddval.value.to_s + "|" + ddval.subquestion_value.to_s
                end
            elsif dd.field_type == "checkbox"
                # get list of row fields
                @designdetails["dd.ddf."+ddidx.to_s+".size"] = 0
                @designdetails["dd.cddf."+ddidx.to_s+".size"] = 0
                ddvals = DesignDetailDataPoint.find(:all,:conditions=>["extraction_form_id = ? and study_id = ? and design_detail_field_id = ?",extraction_form_id,study_id,dd.id], :order=>"id")
                compoundv = ""
                if !ddvals.nil? && (ddvals.size > 0)
                    ddvals.each do |ddval|
                        if compoundv.size > 0
                            compoundv = compoundv + ";"
                        end
                        if ddval.subquestion_value.nil?
                            compoundv = compoundv + ddval.value.to_s
                        else
                            compoundv = compoundv + ddval.value.to_s + "|" + ddval.subquestion_value.to_s
                        end
                    end
                end
                @designdetails["dd.dp."+ddidx.to_s+".0.0"] = compoundv
            else
                # complex matrix data
                # get list of row fields
                rddfs = DesignDetailField.find(:all, :conditions=>["design_detail_id = ? and column_number = 0",dd.id], :order=>"row_number")
                ddfidx = 0;
                rddfs.each do |ddf|
                    @designdetails["dd.ddf."+ddidx.to_s+"."+ddfidx.to_s] = ddf.option_text
                    @designdetails["dd.ddf."+ddidx.to_s+"."+ddfidx.to_s+".id"] = ddf.id.to_s
                    ddfidx = ddfidx + 1
                end
                @designdetails["dd.ddf."+ddidx.to_s+".size"] = ddfidx
                
                # check and get column fields
                cddfs = DesignDetailField.find(:all, :conditions=>["design_detail_id = ? and column_number > 0 and row_number = 0",dd.id], :order=>"column_number")
                cddfidx = 0;
                cddfs.each do |ddf|
                    @designdetails["dd.cddf."+ddidx.to_s+"."+cddfidx.to_s] = ddf.option_text
                    @designdetails["dd.cddf."+ddidx.to_s+"."+cddfidx.to_s+".id"] = ddf.id.to_s
                    cddfidx = cddfidx + 1
                end
                @designdetails["dd.cddf."+ddidx.to_s+".size"] = cddfidx
                
                for ddfidx in 0..rddfs.size - 1
                    for cddfidx in 0..cddfs.size - 1
                        ddval = DesignDetailDataPoint.find(:first,:conditions=>["extraction_form_id = ? and study_id = ? and design_detail_field_id = ? and row_field_id = ? and column_field_id = ?",extraction_form_id,study_id,dd.id,@designdetails["dd.ddf."+ddidx.to_s+"."+ddfidx.to_s+".id"].to_i,@designdetails["dd.cddf."+ddidx.to_s+"."+cddfidx.to_s+".id"].to_i])
                        if ddval.nil?
                            @designdetails["dd.dp."+ddidx.to_s+"."+ddfidx.to_s+"."+cddfidx.to_s] = ""
                        elsif ddval.subquestion_value.nil?
                            @designdetails["dd.dp."+ddidx.to_s+"."+ddfidx.to_s+"."+cddfidx.to_s] = ddval.value.to_s
                        else
                            @designdetails["dd.dp."+ddidx.to_s+"."+ddfidx.to_s+"."+cddfidx.to_s] = ddval.value.to_s + "|" + ddval.subquestion_value.to_s
                        end
                    end
                end
            end
            ddidx = ddidx + 1 
        end
        @designdetails["dd.size"] = ddidx
        
        # Baseline characteristics -------------------------------------------------------------
        # @baseline is a mixed Hash of different structures sorted in different ways
        @baseline = Hash.new
        @baseline_map = Hash.new
        @baseline_colnames = Hash.new
        bls = BaselineCharacteristic.find(:all, :conditions=>["extraction_form_id = ?", extraction_form_id], :order=>"question_number")
        @baseline["bl.size"] = bls.size()
        @baseline["bl.ids"] = Array.new
        @baseline["bl.names"] = Array.new
        # Add arm id = 0 (total) to the baseline list
        @baseline_arm_ids = Array.new
        @armids.each do |armid|
            @baseline_arm_ids << armid
        end
        @baseline_arm_ids << 0
        
        # Compile baseline ids Map by armid
        @baselineids = Hash.new
        @baselinenames = Hash.new
        @baseline_arm_ids.each do |arm_id|
            bl_ids = Array.new    
            bl_names = Array.new    
            bl_ftypes = Array.new  
            @baselineids[arm_id.to_s] = bl_ids  
            @baselinenames[arm_id.to_s] = bl_names 
            arm_name = getArmNameByID(arm_id) 
            bls.each do |bl|
                bl_id = bl.id
                bl_name = bl.question
                bl_ids << bl_id
                bl_names << bl_name
                bl_ftype = bl.field_type
                @baseline_map["bl."+bl_id.to_s] = bl_name
                @baseline_map["bl."+arm_id.to_s+"."+bl_id.to_s] = bl_name
                arm_bl_colnames = @baseline_colnames["bl."+arm_id.to_s+"."+bl_id.to_s]
                if arm_bl_colnames.nil?
                    arm_bl_colnames = Array.new
                    @baseline_colnames["bl."+arm_id.to_s+"."+bl_id.to_s] = arm_bl_colnames
                end
                bl_colnames = @baseline_colnames["bl."+bl_id.to_s]
                if bl_colnames.nil?
                    bl_colnames = Array.new
                    @baseline_colnames["bl."+bl_id.to_s] = bl_colnames
                end
                if (bl_ftype.eql?("text") || 
                    bl_ftype.eql?("radio") ||
                    bl_ftype.eql?("select") ||
                    bl_ftype.eql?("yesno"))
                    # Single value DD - set zero rows and columns and blf sizes
                    @baseline["bl.blf."+arm_id.to_s+"."+bl_id.to_s+".size"] = "0"
                    @baseline["bl.cblf."+arm_id.to_s+"."+bl_id.to_s+".size"] = "0"  
                    @baseline["bl.ncols."+arm_id.to_s+"."+bl_id.to_s] = "1"
                    bl_colnames << arm_name+"|"+bl_name         
                    arm_bl_colnames << bl_name         
                    @baseline_map["bl."+arm_id.to_s+"."+bl_id.to_s+".0.0"] = bl_name
                    # Get datapoint value if it exists - BaselineCharacteristicsDataPoints.arm_detail_field_id really points the BaselineCharacteristic.id
                    blval = BaselineCharacteristicDataPoint.find(:first,:conditions=>["extraction_form_id = ? and study_id = ? and arm_id = ? and baseline_characteristic_field_id = ?",extraction_form_id,study_id,arm_id,bl_id])
                    if blval.nil?
                        @baseline["bl.dp."+arm_id.to_s+"."+bl_id.to_s+".0.0"] = ""               
                    elsif !blval.subquestion_value.nil?
                        @baseline["bl.dp."+arm_id.to_s+"."+bl_id.to_s+".0.0"] = blval.value+"|" + blval.subquestion_value
                    else
                        @baseline["bl.dp."+arm_id.to_s+"."+bl_id.to_s+".0.0"] = blval.value
                    end  # end if
                elsif bl_ftype.eql?("checkbox")
                    # get list of row fields
                    @baseline["bl.blf."+arm_id.to_s+"."+bl_id.to_s+".size"] = "0"
                    @baseline["bl.cblf."+arm_id.to_s+"."+bl_id.to_s+".size"] = "0"
                    @baseline["bl.ncols."+arm_id.to_s+"."+bl_id.to_s] = "1"
                    bl_colnames << arm_name+"|"+bl_name         
                    arm_bl_colnames << bl_name         
                    @baseline_map["bl."+arm_id.to_s+"."+bl_id.to_s+".0.0"] = bl_name
                    bldps = BaselineCharacteristicDataPoint.find(:all,:conditions=>["extraction_form_id = ? and study_id = ? and arm_id = ? and baseline_characteristic_field_id = ?",extraction_form_id,study_id,arm_id,bl_id])
                    compoundv = ""
                    if !bldps.nil?
                        bldps.each do |blval|
                            if compoundv.size() > 0
                                compoundv = compoundv + ";";
                            end
                            if !blval.subquestion_value.nil?
                                compoundv = compoundv + blval.value+"|" + blval.subquestion_value
                            else
                                compoundv = compoundv + blval.value
                            end  # end if
                        end
                    end
                    @baseline["bl.dp."+arm_id.to_s+"."+bl_id.to_s+".0.0"] = compoundv;
                else
                    # complex matrix data
                    # First get other field
                    blf = BaselineCharacteristicField.find(:first,:conditions=>["baseline_characteristic_id = ? and column_number = 0 and row_number = -1",bl_id])
                    if !blf.nil?
                        @baseline["bl.blf."+arm_id.to_s+"."+bl_id.to_s+".other"] = blf.option_text
                        @baseline["bl.blf."+arm_id.to_s+"."+bl_id.to_s+".other.id"] = blf.id.to_s
                    end     # end if

                    # get list of row fields
                    rblfs = BaselineCharacteristicField.find(:all,:conditions=>["baseline_characteristic_id = ? and column_number = 0 and row_number >= 0",bl_id],:order=>"row_number")
                    nblfidx = 0
                    rblfs.each do |blf|
                        @baseline["bl.blf."+arm_id.to_s+"."+bl_id.to_s+"."+nblfidx.to_s] = blf.option_text
                        @baseline["bl.blf."+arm_id.to_s+"."+bl_id.to_s+"."+nblfidx.to_s+".id"] = blf.id.to_s
                        nblfidx = nblfidx + 1
                    end     # end if
                    @baseline["bl.blf."+arm_id.to_s+"."+bl_id.to_s+".size"] = rblfs.size().to_s

                    # check and get column fields
                    cblfs = BaselineCharacteristicField.find(:all,:conditions=>["baseline_characteristic_id = ? and column_number > 0 and row_number = 0",bl_id],:order=>"column_number")
                    ncblfidx = 0
                    cblfs.each do |blf|
                        @baseline["bl.cblf."+arm_id.to_s+"."+bl_id.to_s+"."+ncblfidx.to_s] = blf.option_text
                        @baseline["bl.cblf."+arm_id.to_s+"."+bl_id.to_s+"."+ncblfidx.to_s+".id"] = blf.id.to_s
                        ncblfidx = ncblfidx + 1
                    end     # end if
                    @baseline["bl.cblf."+arm_id.to_s+"."+bl_id.to_s+".size"] = cblfs.size().to_s
                    
                    @baseline["bl.ncols."+arm_id.to_s+"."+bl_id.to_s] = ""+(rblfs.size() * cblfs.size()).to_s
                    for blfidx in 0..rblfs.size() - 1
                        for cblfidx in 0..cblfs.size() - 1
                            bldp = BaselineCharacteristicDataPoint.find(:first,:conditions=>["extraction_form_id = ? and study_id = ? and arm_id = ? and baseline_characteristic_field_id = ? and row_field_id = ? and column_field_id = ?",extraction_form_id,study_id,arm_id,bl_id,@baseline["bl.blf."+arm_id.to_s+"."+bl_id.to_s+"."+blfidx.to_s+".id"].to_i,@baseline["bl.cblf."+arm_id.to_s+"."+bl_id.to_s+"."+cblfidx.to_s+".id"].to_i], :order=>"id")
                            if !bldp.nil?
                                val = bldp.value
                                subval = bldp.subquestion_value
                                if subval.nil? ||
                                    (subval.size() == 0)
                                    @baseline["bl.dp."+arm_id.to_s+"."+bl_id.to_s+"."+blfidx.to_s+"."+cblfidx.to_s] = val
                                else
                                    @baseline["bl.dp."+arm_id.to_s+"."+bl_id.to_s+"."+blfidx.to_s+"."+cblfidx.to_s] = val+"|"+subval
                                end     # end if
                            else
                                @baseline["bl.dp."+arm_id.to_s+"."+bl_id.to_s+"."+blfidx.to_s+"."+cblfidx.to_s] = ""
                            end     # end if
                            bl_colnames << arm_name+"|"+@baseline["bl.blf."+arm_id.to_s+"."+bl_id.to_s+"."+blfidx.to_s]+"|"+@baseline["bl.cblf."+arm_id.to_s+"."+bl_id.to_s+"."+cblfidx.to_s]         
                            arm_bl_colnames << @baseline["bl.blf."+arm_id.to_s+"."+bl_id.to_s+"."+blfidx.to_s]+"|"+@baseline["bl.cblf."+arm_id.to_s+"."+bl_id.to_s+"."+cblfidx.to_s]         
                            @baseline_map["bl."+arm_id.to_s+"."+bl_id.to_s+"."+blfidx.to_s+"."+cblfidx.to_s] = @baseline["bl.blf."+arm_id.to_s+"."+bl_id.to_s+"."+blfidx.to_s]+"|"+@baseline["bl.cblf."+arm_id.to_s+"."+bl_id.to_s+"."+cblfidx.to_s]         
                        end     # end for
                    end     # end for
                end     # end if
            end
        end
        
        # Outcomes ---------------------------------------------------
        # Outcomes come in two sets - "Setup" which indicates list of unique [Outcome.title] for a given [extraction form id + stucy id] criteria
        # Outcome results is organized in three dimensions - flattened to <Outcome.title>.<OutcomeTimepoint.[number + time_unit]>.<OutcomeMeasure.title>.<OutcomeMeasure.arm name>
        outcomes = Outcome.find(:all, :conditions=>["extraction_form_id = ? and study_id = ?", extraction_form_id, study_id], :order => "title")
        @outcomeids = Array.new
        @outcomenames = Array.new
        @outcomessubgroup_ids = Array.new
        @outcomessubgroup_names = Array.new
        @outcomestimept_ids = Array.new
        @outcomestimept_names = Array.new
        @outcomesmeas_names = Array.new
        @outcomesarms_names = Array.new
        @outcomesdata = Hash.new
        outidx = 0
        if !outcomes.nil? && (outcomes.size > 0)
            for outcome in outcomes
                @outcomeids << outcome.id
                # Collect unique outcome names that belong to this study x extraction form
                outcome_title = outcome.title
                # For test data without title entered
                if outcome_title.nil?
                    outcome_title = "ID="+outcome.id.to_s
                end
                if !@outcomenames.include?(outcome_title)
                    @outcomenames << outcome_title
                end
	            outcomedata = OutcomeDataEntry.find(:all, :conditions=>["extraction_form_id = ? and outcome_id = ? and study_id = ?", extraction_form_id,outcome.id,study_id])
                for data in outcomedata
                    # Collect subgroups
                    subgroup_id = data.subgroup_id
                    if !subgroup_id.nil?
                        @outcomessubgroup_ids << subgroup_id
    	                subgroup = OutcomeSubgroup.find(:first, :conditions=>["id = ?", subgroup_id])
                        if !subgroup.nil? &&
                            !subgroup.title.nil?
                            sgname = subgroup.title
                            if !@outcomessubgroup_names.include?(sgname)
                                @outcomessubgroup_names << sgname
                            end
                            # Collect time points
                            timepoint_id = data.timepoint_id
                            if !timepoint_id.nil?
                                @outcomestimept_ids << timepoint_id
            	                timepoint = OutcomeTimepoint.find(:first, :conditions=>["id = ?", timepoint_id])
                                if !timepoint.nil? &&
                                   !timepoint.number.nil?
                                    if !timepoint.time_unit.nil?
                                        tpname = timepoint.number + " "+timepoint.time_unit
                                    else
                                        tpname = timepoint.number
                                    end
                                    if !@outcomestimept_names.include?(tpname)
                                        @outcomestimept_names << tpname
                                    end
                                    
                                    # Collect measure values
                                    outmeass = OutcomeMeasure.find(:all,:conditions=>["outcome_data_entry_id = ?",data.id])
                                    for outmeas in outmeass
                                        @outcomesdata["outcome.name."+outidx.to_s] = outmeas.title
                                        if !@outcomesmeas_names.include?(outmeas.title)
                                            @outcomesmeas_names << outmeas.title
                                        end
                                        # Now save outcome value by title, ef and study id
                                        outvals = OutcomeDataPoint.find(:all, :conditions=>["outcome_measure_id = ?",outmeas.id])
                                        for outval in outvals
                                            if outval.arm_id == 0
                                                armname = "total"
                                            else
                                                armrec = Arm.find(:first, :conditions=>["id = ?",outval.arm_id])
                                                if !armrec.nil?
                                                    armname = armrec.title
                                                else
                                                    armname = "ID="+outval.arm_id.to_s
                                                end
                                            end
                                            if !@outcomesarms_names.include?(armname)
                                                @outcomesarms_names << armname
                                            end
                                            if !outval.nil?
                                                @outcomesdata["outcome.value."+outcome_title+"."+sgname+"."+tpname+"."+outmeas.title+"."+armname] = outval.value.to_s + "|" + outval.footnote.to_s
                                            else
                                                @outcomesdata["outcome.value."+outcome_title+"."+sgname+"."+tpname+"."+outmeas.title+"."+armname] = "na"
                                            end
                                            outidx = outidx + 1
                                        end # for outval
                                    end # for outmeas
                                end # if timepoint
                            end # if timepoint id
                        end # if subgroup
                    end # if subgroup id
                end # for outcome data entries
            end # for outcomes
        end
        @outcomesdata["outcome.size"] = outidx
        
        # Partition the outcome data into different groups
        # Get list of distinct time point ids from the OutcomeResult table
        @outcome_timepoint_ids = Array.new
        for oid in @outcomeids
            outresults = OutcomeResult.find(:all, :conditions=>["outcome_id = ? and extraction_form_id = ?", oid, extraction_form_id])
            outresults.each do |oresult|
                if !@outcome_timepoint_ids.include?(oresult.timepoint_id)
                    @outcome_timepoint_ids << oresult.timepoint_id
                end
            end
        end
        # By outcome.id x arm.id
        @outcome_results = Hash.new
        for oid in @outcomeids
            @arms.each do |arm|
                for tpid in @outcome_timepoint_ids
                    outresult = OutcomeResult.find(:first, :conditions=>["outcome_id = ? and extraction_form_id = ? and arm_id = ? and timepoint_id = ?", oid, extraction_form_id,arm.id,tpid])
                    if !outresult.nil?
                        @outcome_results[oid.to_s+"."+arm.id.to_s+"."+tpid.to_s] = outresult
                    end
                end
            end
        end
        
        # Outcome Details --------------------------------------------------------
        @outcomedetails = Hash.new
        @outcomedetailsnames = Array.new
        outcomeds = OutcomeDetail.find(:all,:conditions=>["extraction_form_id = ?", extraction_form_id], :order=>"question_number")
        # Using the outcomeds - pull all the entered values via OutcomeDetailDataPoint(extraction_form_id, outcomed.id) and store them into a HashMap for lookup
        outcomedidx = 0
        outcomeds.each do |outcomed|
            @outcomedetails["outcomed.id."+outcomedidx.to_s+""] = outcomed.id.to_s
            @outcomedetails["outcomed.name."+outcomedidx.to_s+""] = outcomed.question
            if !@outcomedetailsnames.include?(outcomed.question)
                @outcomedetailsnames << outcomed.question
            end
            
            # Use the OutcomeDetail.field_type to determine if the DD is a single entity or more complex entity
            # involvng multiple OutcomeDetailFields with rows and columns
            # Saved data values are stored in key format outcomed.dp.outcomedidx.rowidx,colidx - single values have rowidx and colidx = 0
            if outcomed.field_type == "text" || outcomed.field_type == "radio"
                # Single value DD - set zero rows and columns and outcomedf sizes
                @outcomedetails["outcomed.outcomedf."+outcomedidx.to_s+".size"] = 0
                @outcomedetails["outcomed.coutcomedf."+outcomedidx.to_s+".size"] = 0
                # Get datapoint value if it exists - OutcomeDetailsDataPoints.outcome_detail_field_id really points the OutcomeDetail.id
                outcomedval = OutcomeDetailDataPoint.find(:first,:conditions=>["extraction_form_id = ? and study_id = ? and outcome_detail_field_id = ?",extraction_form_id,study_id,outcomed.id])
                if outcomedval.nil?
                    @outcomedetails["outcomed.dp."+outcomedidx.to_s+".0.0"] = ""
                elsif outcomedval.subquestion_value.nil?
                    @outcomedetails["outcomed.dp."+outcomedidx.to_s+".0.0"] = outcomedval.value.to_s
                else
                    @outcomedetails["outcomed.dp."+outcomedidx.to_s+".0.0"] = outcomedval.value.to_s + "|" + outcomedval.subquestion_value.to_s
                end
            elsif outcomed.field_type == "checkbox"
                # get list of row fields
                @outcomedetails["outcomed.outcomedf."+outcomedidx.to_s+".size"] = 0
                @outcomedetails["outcomed.coutcomedf."+outcomedidx.to_s+".size"] = 0
                outcomedvals = OutcomeDetailDataPoint.find(:all,:conditions=>["extraction_form_id = ? and study_id = ? and outcome_detail_field_id = ?",extraction_form_id,study_id,outcomed.id], :order=>"id")
                compoundv = ""
                if !outcomedvals.nil? && (outcomedvals.size > 0)
                    outcomedvals.each do |outcomedval|
                        if compoundv.size > 0
                            compoundv = compoundv + ";"
                        end
                        if outcomedval.subquestion_value.nil?
                            compoundv = compoundv + outcomedval.value.to_s
                        else
                            compoundv = compoundv + outcomedval.value.to_s + "|" + outcomedval.subquestion_value.to_s
                        end
                    end
                end
                @outcomedetails["outcomed.dp."+outcomedidx.to_s+".0.0"] = compoundv
            else
                # complex matrix data
                # get list of row fields
                routcomedfs = OutcomeDetailField.find(:all, :conditions=>["outcome_detail_id = ? and column_number = 0",outcomed.id], :order=>"row_number")
                outcomedfidx = 0;
                routcomedfs.each do |outcomedf|
                    @outcomedetails["outcomed.outcomedf."+outcomedidx.to_s+"."+outcomedfidx.to_s] = outcomedf.option_text
                    @outcomedetails["outcomed.outcomedf."+outcomedidx.to_s+"."+outcomedfidx.to_s+".id"] = outcomedf.id.to_s
                    outcomedfidx = outcomedfidx + 1
                end
                @outcomedetails["outcomed.outcomedf."+outcomedidx.to_s+".size"] = outcomedfidx
                
                # check and get column fields
                coutcomedfs = OutcomeDetailField.find(:all, :conditions=>["outcome_detail_id = ? and column_number > 0 and row_number = 0",outcomed.id], :order=>"column_number")
                coutcomedfidx = 0;
                coutcomedfs.each do |outcomedf|
                    @outcomedetails["outcomed.coutcomedf."+outcomedidx.to_s+"."+coutcomedfidx.to_s] = outcomedf.option_text
                    @outcomedetails["outcomed.coutcomedf."+outcomedidx.to_s+"."+coutcomedfidx.to_s+".id"] = outcomedf.id.to_s
                    coutcomedfidx = coutcomedfidx + 1
                end
                @outcomedetails["outcomed.coutcomedf."+outcomedidx.to_s+".size"] = coutcomedfidx
                
                for outcomedfidx in 0..routcomedfs.size - 1
                    for coutcomedfidx in 0..coutcomedfs.size - 1
                        outcomedval = OutcomeDetailDataPoint.find(:first,:conditions=>["extraction_form_id = ? and study_id = ? and outcome_detail_field_id = ? and row_field_id = ? and column_field_id = ?",extraction_form_id,study_id,outcomed.id,@outcomedetails["outcomed.outcomedf."+outcomedidx.to_s+"."+outcomedfidx.to_s+".id"].to_i,@outcomedetails["outcomed.coutcomedf."+outcomedidx.to_s+"."+coutcomedfidx.to_s+".id"].to_i])
                        if outcomedval.nil?
                            @outcomedetails["outcomed.dp."+outcomedidx.to_s+"."+outcomedfidx.to_s+"."+coutcomedfidx.to_s] = ""
                        elsif outcomedval.subquestion_value.nil?
                            @outcomedetails["outcomed.dp."+outcomedidx.to_s+"."+outcomedfidx.to_s+"."+coutcomedfidx.to_s] = outcomedval.value.to_s
                        else
                            @outcomedetails["outcomed.dp."+outcomedidx.to_s+"."+outcomedfidx.to_s+"."+coutcomedfidx.to_s] = outcomedval.value.to_s + "|" + outcomedval.subquestion_value.to_s
                        end
                    end
                end
            end
            
            outcomedidx = outcomedidx + 1 
        end
        @outcomedetails["outcomed.size"] = outcomedidx
        
        # Adverse Events ----------------------------------------------------------------------------------------------------------------
        @adverseevents = Hash.new
        advevents = AdverseEvent.find(:all,:conditions=>["extraction_form_id = ? and study_id = ?", extraction_form_id,study_id], :order=>"title")
        # AdverseEvent.id is linked to AdverseEventResult.adverse_event_id
        # AdverseEventResult.column_id is linked to AdverseEventColumn.id
        @adverseevents["adve.size"] = advevents.size()
        @adverseevents["adve.ids"] = Array.new
        @adverseevents["adve.names"] = Array.new
        @adverseevents["adve.rid"] = Array.new
        @adverseevents["adve.cid"] = Array.new
        @adverseevents["adve.cname"] = Array.new
        @adverseevents["adve.cdesc"] = Array.new
        
        # Using the advevents - pull all the results values via AdverseEventResult(extraction_form_id, advevent.id) and store them into a HashMap for lookup
        adveidx = 0
        advevents.each do |advevent|
            @adverseevents["adve.ids"] << advevent.id.to_s   # References AdverseEvent.id
            dispname = "NA:"+adveidx.to_s
            if !advevent.title.nil?
                dispname = advevent.title
            end
            @adverseevents["adve.names"] << dispname
            
            advresults = AdverseEventResult.find(:all,:conditions=>["adverse_event_id = ?", advevent.id])
            if !advresults.nil?
                advresults.each do |advresult|
                    @adverseevents["adve.rid"] << advresult.id.to_s   # References AdverseEventResult.id
                    @adverseevents["adve.cid"] << advresult.column_id.to_s   # References AdverseEventColumn.id
                    advcol = AdverseEventColumn.find(:first,:conditions=>["id = ?",advresult.column_id])
                    if advcol.nil?
                        @adverseevents["adve.cname"] << "["+advresult.id.to_s+":"+advresult.column_id.to_s+"]"
                        @adverseevents["adve.cdesc"] << "["+advresult.id.to_s+":"+advresult.column_id.to_s+"]"
                    else
                        @adverseevents["adve.cname"] << advcol.name.to_s
                        @adverseevents["adve.cdesc"] << advcol.description.to_s
                    end
                    if !advresult.arm_id.nil? &&
                        (advresult.arm_id <= 0)
                        @adverseevents["adve.value.total."+advevent.title] = advresult.value.to_s
                    elsif !advresult.arm_id.nil? &&
                        (advresult.arm_id > 0)
                        arm_title = @arms_map[advresult.arm_id]
                        if arm_title.nil?
                            adv_arm = Arm.find(:first, :conditions=>["id = ?", advresult.arm_id])
                            if adv_arm.nil?
                                arm_title = "na"
                            else
                                @arms_map[advresult.arm_id] = adv_arm.title
                                arm_title = adv_arm.title
                            end
                        end
                        @adverseevents["adve.value."+arm_title+"."+advevent.title] = advresult.value.to_s
                    else
                        @adverseevents["adve.value.nil."+advevent.title] = advresult.value.to_s
                    end
                end
            end
            adveidx = adveidx + 1 
        end
        @adverseevents["adve.size"] = adveidx
                
        # Quality Dimensions ---------------------------------------------------
        @quality = Hash.new
        # Note QualityDimensionField does not populate study_id, this is handled in the QualityDimensionDataPoint table 
        qualdimfields = QualityDimensionField.find(:all,:conditions=>["extraction_form_id = ?", extraction_form_id], :order=>"title")
        # Using the qualdimfields - pull all the results values via QualityDimensionDataPoint(extraction_form_id, qualdim.id) and store them into a HashMap for lookup
        qualdimidx = 0
        qualdimfields.each do |qualdim|
            @quality["qd.name."+qualdimidx.to_s] = qualdim.title.to_s
            qdfval = QualityDimensionDataPoint.find(:first,:conditions=>["extraction_form_id = ? and quality_dimension_field_id = ? and study_id = ?",extraction_form_id,qualdim.id,study_id])
            if !qdfval.nil?
                @quality["qd.id."+qualdimidx.to_s] = qualdim.id.to_s
                @quality["qd.value."+qualdim.id.to_s] = qdfval.value.to_s
            end
            qualdimidx = qualdimidx + 1 
        end
        @quality["qd.size"] = qualdimidx
        
        
    end
    
    # Publication -------------------------------------------------------------------------------------------------
    def isStudy(study_id, ef_id)
        if @study_id.nil?
            return false
        end
        return (@study_id == study_id) && (@efid == ef_id)
    end
    
    def getExtractionFormID()
        return @efid
    end
    
    def getExtractionFormTitle()
        return @eftitle
    end
    
    def getExtractionFormNotes()
        return @efnotes
    end
    
    def getStudyID()
        if @study_id.nil?
            return nil
        else
            return @study_id
        end
    end
    
    def getPMID()
        if @publication_data.nil? || @publication_data[0].nil?
            return ""
        else
            return @publication_data[0]
        end
    end
    
    def getTitle()
        if @publication_data.nil? || @publication_data[2].nil?
            return ""
        else
            return @publication_data[2]
        end
    end
    
    def getAuthor()
        if @publication_data.nil? || @publication_data[3].nil?
            return ""
        else
            return @publication_data[3]
        end
    end
    
    def getFirstAuthor(author)
        if author.nil? || (author.length == 0)
            return ""
        else
            names = author.split(",")
            if names.size() == 1
                return author
            else
                return names[0]+" et al"
            end
        end
    end
    
    def getYear()
        if @publication_data.nil? || @publication_data[5].nil?
            return ""
        else
            return @publication_data[5].to_s
        end
    end
    
    def getCountry()
        if @publication_data.nil? || @publication_data[6].nil?
            return ""
        else
            return @publication_data[6]
        end
    end
    
    def getJournal()
        if @publication_data.nil? || @publication_data[7].nil?
            return ""
        else
            return @publication_data[7]
        end
    end
    
    def getVolume()
        if @publication_data.nil? || @publication_data[8].nil?
            return ""
        else
            return @publication_data[8]
        end
    end
    
    def getIssue()
        if @publication_data.nil? || @publication_data[9].nil?
            return ""
        else
            return @publication_data[9]
        end
    end
    
    def getAlternateNumbers()
        if @alternate_ids.nil? ||
            (@alternate_ids.size == 0)
            return ""
        else
            altids = ""
            @alternate_ids.each do |altid|
                if altids.size > 0
                    altids = altids + "; "
                end
                altids = altids + "["+altid[1] + "] " + altid[0]
            end
            return altids
        end
    end
    
    def getCreatorID()
        if @study_creator_id.nil?
            return nil
        else
            return @study_creator_id
        end
    end
    
    def getPublicationData(idx)
        if @publication_data.nil? || (@publication_data.size == 0) || (idx >= @publication_data.size)
            return ""
        else
            return @publication_data[idx]
        end
    end
    
    def getNumPublicationItems()
        return @publication_data.size()
    end
    
    # Arm Details ----------------------------------------------------------------
    def getNumArmDetails()
        if @armdetailsnames.nil? ||
           @armdetailsnames.size() == 0
            return 0
        else
            return @armdetailsnames.size
        end    
    end
    
    def containsArmDetail(name)
        return @armdetailsnames.include?(name)
    end
    
    def getArmDetailID(idx)
        return @armdetailsids[idx]
    end
    
    def getArmDetailName(idx)
        return @armdetailsnames[idx]
    end
    
    def getArmDetailIDByName(name)
        idx = @armdetailsnames.index(name)
        if idx.nil? || idx < 0
            return "x"
        else
            return @armdetailsids[idx]
        end
    end
    
    def getArmDetailDataTypeName(arm_id,armd_id)
        armdtype = @armdetails["armd.type."+arm_id.to_s+"."+armd_id.to_s]
        if armdtype.nil?
            armdtype = "na"
        end
        return armdtype
    end
    
    def isArmDetailComplex(arm_id, armd_id)
        nrows = @armdetails["armd.armdf."+arm_id.to_s+"."+armd_id.to_s+".size"]
        ncols = @armdetails["armd.carmdf."+arm_id.to_s+"."+armd_id.to_s+".size"]
        # matrix_radio type has ncol == 1, but no column names listed - TODO need better way of handling this
        # so need to check for this condition
        firstcolname = @armdetails["armd.carmdf."+arm_id.to_s+"."+armd_id.to_s+".0"]
        return (!nrows.nil? && (nrows.to_i > 0) && !ncols.nil? && (ncols.to_i > 0) && !firstcolname.nil?)
    end
    
    def getNumArmDetailRows(arm_id, armd_id)
        if isArmDetailComplex(arm_id,armd_id)
            nrows = @armdetails["armd.armdf."+arm_id.to_s+"."+armd_id.to_s+".size"]
            return nrows.to_i
        else
            return 1
        end
    end
    
    def getArmDetailRowNames(armdidx)
        armd_id = getArmDetailID(armdidx)
        # Iterate through all the arms and compile the list of uniq row names
        # Return array of datapoint names associated with the referenced ArmDetail
        compnames = Array.new
        @armids.each do |arm_id|
            if isArmDetailComplex(arm_id,armd_id)
                nrows = @armdetails["armd.armdf."+arm_id.to_s+"."+armd_id.to_s+".size"]
                if !nrows.nil? && (nrows.to_i > 0)
                    for rowidx in 0..nrows.to_i - 1
                        rowname = @armdetails["armd.armdf."+arm_id.to_s+"."+armd_id.to_s+"."+rowidx.to_s]
                        if !compnames.include?(rowname)
                            compnames << rowname
                        end
                    end
                end
            end
        end
        return compnames
    end
    
    def getArmDetailRowNamesByID(arm_id,armd_id)
        rownames = Array.new
        nrows = @armdetails["armd.armdf."+arm_id.to_s+"."+armd_id.to_s+".size"]
        if !nrows.nil? && (nrows.to_i > 0)
            for rowidx in 0..nrows.to_i - 1
                rowname = @armdetails["armd.armdf."+arm_id.to_s+"."+armd_id.to_s+"."+rowidx.to_s]
                if !rownames.include?(rowname)
                    rownames << rowname
                end
            end
        end
        return rownames
    end
    
    def getNumArmDetailCols(arm_id,armd_id)
        if isArmDetailComplex(arm_id,armd_id)
            ncols = @armdetails["armd.carmdf."+arm_id.to_s+"."+armd_id.to_s+".size"]
            return ncols.to_i + 1       # Compensate for extra column for row labels
        else
            return 1
        end
    end
    
    # Calculates the total columns each Arm Detail would take up
    def getTotalNumArmDetailCols(arm_id)
        totalcols = 0;
        @armdetailsids.each do |armd_id|
            totalcols = totalcols + getNumArmDetailCols(arm_id,armd_id)
        end
        return totalcols
    end
    
    def getArmDetailColNamesByID(arm_id,armd_id)
        colnames = Array.new
        ncols = @armdetails["armd.carmdf."+arm_id.to_s+"."+armd_id.to_s+".size"]
        if !ncols.nil? && (ncols.to_i > 0)
            for colidx in 0..ncols.to_i - 1
                colname = @armdetails["armd.carmdf."+arm_id.to_s+"."+armd_id.to_s+"."+colidx.to_s]
                if !colnames.include?(colname)
                    colnames << colname
                end
            end
        end
        return colnames
    end
    
    def getArmDetailColNames(armdidx)
        armd_id = getArmDetailID(armdidx)
        # Iterate through all the arms and compile the list of uniq row names
        # Return array of datapoint names associated with the referenced ArmDetail
        compnames = Array.new
        @armids.each do |arm_id|
            if isArmDetailComplex(arm_id,armd_id)
                ncols = @armdetails["armd.carmdf."+arm_id.to_s+"."+armd_id.to_s+".size"]
                if !ncols.nil? && (ncols.to_i > 0)
                    for colidx in 0..ncols.to_i - 1
                        colname = @armdetails["armd.carmdf."+arm_id.to_s+"."+armd_id.to_s+"."+colidx.to_s]
                        if !colname.nil? && !compnames.include?(colname)
                            compnames << colname
                        end
                    end
                end
            end
        end
        return compnames
    end
    
    def isArmDetailSingleValue(armdidx)
        nvals = @armdetails["armd.armdf."+armdidx.to_s+".size"]
        ncvals = @armdetails["armd.carmdf."+armdidx.to_s+".size"]
        return (!nvals.nil? && !ncvals.nil? && (nvals.to_i == 0) && (ncvals.to_i == 0))
    end
    
    def getArmDetailValue(arm_id,armd_id)
        val = @armdetails["armd.dp."+arm_id.to_s+"."+armd_id.to_s]
        if val.nil?
            val = @armdetails["armd.dp."+arm_id.to_s+"."+armd_id.to_s+".0.0"]
        end
        if val.nil?
            val = "-"
        end
        return val
    end
    
    def containsArmDetailValue(arm_id,armd_id)
        val = @armdetails["armd.dp."+arm_id.to_s+"."+armd_id.to_s]
        return !val.nil?
    end
    
    def getArmDetailFieldValue(armdidx,armdfidx)
        val = @armdetails["armd.dp."+armdidx.to_s+"."+armdfidx.to_s+".0"]
        if val.nil?
            val = "-"
        end
        return val
    end
    
    def containsArmDetailMatrixValue(arm_id,armd_id,row_idx,col_idx)
        val = @armdetails["armd.dp."+arm_id.to_s+"."+armd_id.to_s+"."+row_idx.to_s+"."+col_idx.to_s]
        return !val.nil?
    end
    
    def getArmDetailMatrixValue(arm_id,armd_id,row_idx,col_idx)
        val = @armdetails["armd.dp."+arm_id.to_s+"."+armd_id.to_s+"."+row_idx.to_s+"."+col_idx.to_s]
        if val.nil?
            val = "-"
        end
        return val
    end
    
    # Design Details ----------------------------------------------------------------
    def getNumDesignDetails()
        if @designdetailsnames.nil? ||
           @designdetailsnames.size() == 0
            return 0
        else
            return @designdetailsnames.size
        end    
    end
    
    def containsDesignDetail(name)
        return @designdetailsnames.include?(name)
    end
    
    def getDesignDetailID(idx)
        return @designdetailsids[idx]
    end
    
    def getDesignDetailName(idx)
        return @designdetailsnames[idx]
    end
    
    def getDesignDetailIDByName(name)
        idx = @designdetailsnames.index(name)
        if idx.nil? || idx < 0
            return "x"
        else
            return @designdetailsids[idx]
        end
    end
    
    def getDesignDetailDataTypeName(dd_id)
        ddtype = @designdetailsids["dd.type."+dd_id.to_s]
        if ddtype.nil?
            ddtype = "na"
        end
        return ddtype
    end
    
    def isDesignDetailComplex(dd_id)
        nrows = @designdetails["dd.ddf."+dd_id.to_s+".size"]
        ncols = @designdetails["dd.cddf."+dd_id.to_s+".size"]
        # matrix_radio type has ncol == 1, but no column names listed - TODO need better way of handling this
        # so need to check for this condition
        firstcolname = @designdetails["dd.cddf."+dd_id.to_s+".0"]
        return (!nrows.nil? && (nrows.to_i > 0) && !ncols.nil? && (ncols.to_i > 0) && !firstcolname.nil?)
    end
    
    def getNumDesignDetailRows(dd_id)
        if isDesignDetailComplex(dd_id)
            nrows = @designdetails["dd.ddf."+dd_id.to_s+".size"]
            return nrows.to_i
        else
            return 1
        end
    end
    
    def getDesignDetailRowNames(ddidx)
        dd_id = getDesignDetailID(ddidx)
        # Return array of datapoint names associated with the referenced DesignDetail
        compnames = Array.new
        if isDesignDetailComplex(dd_id)
            nrows = @designdetails["dd.ddf."+dd_id.to_s+".size"]
            if !nrows.nil? && (nrows.to_i > 0)
                for rowidx in 0..nrows.to_i - 1
                    rowname = @designdetails["dd.ddf."+dd_id.to_s+"."+rowidx.to_s]
                    if !compnames.include?(rowname)
                        compnames << rowname
                    end
                end
            end
        end
        return compnames
    end
    
    def getDesignDetailRowNamesByID(dd_id)
        rownames = Array.new
        nrows = @designdetails["dd.ddf."+dd_id.to_s+".size"]
        if !nrows.nil? && (nrows.to_i > 0)
            for rowidx in 0..nrows.to_i - 1
                rowname = @designdetails["dd.ddf."+dd_id.to_s+"."+rowidx.to_s]
                if !rownames.include?(rowname)
                    rownames << rowname
                end
            end
        end
        return rownames
    end
    
    def getNumDesignDetailCols(dd_id)
        if isDesignDetailComplex(dd_id)
            ncols = @designdetails["dd.cddf."+dd_id.to_s+".size"]
            return ncols.to_i + 1       # Compensate for extra column for row labels
        else
            return 1
        end
    end
    
    # Calculates the total columns each Design Detail would take up
    def getTotalNumDesignDetailCols()
        @designdetailsids.each do |dd_id|
            totalcols = totalcols + getNumDesignDetailCols(dd_id)
        end
        return totalcols
    end
    
    def getDesignDetailColNamesByID(dd_id)
        colnames = Array.new
        ncols = @designdetails["dd.cddf."+dd_id.to_s+".size"]
        if !ncols.nil? && (ncols.to_i > 0)
            for colidx in 0..ncols.to_i - 1
                colname = @designdetails["dd.cddf."+dd_id.to_s+"."+colidx.to_s]
                if !colnames.include?(colname)
                    colnames << colname
                end
            end
        end
        return colnames
    end
    
    def getDesignDetailColNames(ddidx)
        dd_id = getDesignDetailID(ddidx)
        # Return array of datapoint names associated with the referenced DesignDetail
        compnames = Array.new
        if isDesignDetailComplex(dd_id)
            ncols = @designdetails["dd.cddf."+dd_id.to_s+".size"]
            if !ncols.nil? && (ncols.to_i > 0)
                for colidx in 0..ncols.to_i - 1
                    colname = @designdetails["dd.cddf."+dd_id.to_s+"."+colidx.to_s]
                    if !colname.nil? && !compnames.include?(colname)
                        compnames << colname
                    end
                end
            end
        end
        return compnames
    end
    
    def isDesignDetailSingleValue(dd_id)
        nvals = @designdetails["dd.ddf."+dd_id.to_s+".size"]
        ncvals = @designdetails["dd.cddf."+dd_id.to_s+".size"]
        return (!nvals.nil? && !ncvals.nil? && (nvals.to_i == 0) && (ncvals.to_i == 0))
    end
    
    def containsDesignDetailValue(dd_id)
        val = @designdetails["dd.dp."+dd_id.to_s]
        return !val.nil?
    end
    
    def getDesignDetailValue(dd_id)
        val = @designdetails["dd.dp."+dd_id.to_s]
        if val.nil?
            val = @designdetails["dd.dp."+dd_id.to_s+".0.0"]
        end
        if val.nil?
            val = "-"
        end
        return val
    end
    
    def getDesignDetailFieldValue(ddidx,dd_id)
        val = @designdetails["dd.dp."+dd_id.to_s+"."+ddfidx.to_s+".0"]
        if val.nil?
            val = "-"
        end
        return val
    end
    
    def containsDesignDetailValue(dd_id,row_idx,col_idx)
        val = @designdetails["dd.dp."+dd_id.to_s+"."+row_idx.to_s+"."+col_idx.to_s]
        return !val.nil?
    end
    
    def getDesignDetailMatrixValue(dd_id,row_idx,col_idx)
        val = @designdetails["dd.dp."+dd_id.to_s+"."+row_idx.to_s+"."+col_idx.to_s]
        if val.nil?
            val = "-"
        end
        return val
    end
    
    # Design Details EXCEL Export Methods -----------------------------------------------------
    # Calculates the total span of columns for a design detail
    def getDesignDetailColSpan(dd_name)
        return getDesignDetailsEXCELLabels(dd_name).size()
    end
    
    def getDesignDetailsEXCELLabels(dd_name)
        dd_id = getDesignDetailIDByName(dd_name)
        ddlabels = Array.new
        if isDesignDetailComplex(dd_id)
            nrows = @designdetails["dd.ddf."+dd_id.to_s+".size"]
            ncols = @designdetails["dd.cddf."+dd_id.to_s+".size"]
            for rowidx in 0..nrows.to_i - 1
                rowname = @designdetails["dd.ddf."+dd_id.to_s+"."+rowidx.to_s]
                for colidx in 0..ncols.to_i - 1
                    colname = @designdetails["dd.cddf."+dd_id.to_s+"."+colidx.to_s]
                    ddlabels << dd_name+" ["+rowname+"/"+colname+"]"
                end
            end
        else
            ddlabels << dd_name
        end
        return ddlabels
    end
    
    def getDesignDetailEXCELValues(dd_name)
        dd_id = getDesignDetailIDByName(dd_name)
        ddvalues = Array.new
        if isDesignDetailComplex(dd_id)
            nrows = @designdetails["dd.ddf."+dd_id.to_s+".size"]
            ncols = @designdetails["dd.cddf."+dd_id.to_s+".size"]
            for rowidx in 0..nrows.to_i - 1
                for colidx in 0..ncols.to_i - 1
                    ddvalues << getDesignDetailMatrixValue(dd_id,rowidx,colidx)
                end
            end
        else
            ddvalues << getDesignDetailValue(dd_id)
        end
        return ddvalues
    end
    
    # Baseline Characteristics ----------------------------------------------------------------
    def getNumBaselines()
        if @baselinenames.nil? ||
           @baselinenames.size() == 0
            return 0
        else
            return @baselinenames.size
        end    
    end
    
    def containsBaseline(name)
        return @baselinenames.include?(name)
    end
    
    def getBaselineID(idx)
        return @baselineids[idx]
    end
    
    def getBaselineNamesByArm(arm_id)
        blnames = Array.new
        for blidx in 0..getNumBaselines() - 1
            bl_id = getBaselineID(blidx)
            if !@baseline["bl.name."+arm_id.to_s+"."+bl_id.to_s].nil?
                blnames << @baseline["bl.name."+arm_id.to_s+"."+bl_id.to_s]
            end
        end
    end
    
    def getBaselineName(idx)
        return @baselinenames[idx]
    end
    
    def getBaselineIDByName(name)
        idx = @baselinenames.index(name)
        if idx.nil? || idx < 0
            return "x"
        else
            return @baselineids[idx]
        end
    end
    
    def getBaselineDataTypeName(arm_id,bl_id)
        bltype = @baseline["bl.type."+arm_id.to_s+"."+bl_id.to_s]
        if bltype.nil?
            bltype = "na"
        end
        return bltype
    end
    
    def isBaselineComplex(arm_id, bl_id)
        nrows = @baseline["bl.blf."+arm_id.to_s+"."+bl_id.to_s+".size"]
        ncols = @baseline["bl.cblf."+arm_id.to_s+"."+bl_id.to_s+".size"]
        # matrix_radio type has ncol == 1, but no column names listed - TODO need better way of handling this
        # so need to check for this condition
        firstcolname = @baseline["bl.cblf."+arm_id.to_s+"."+bl_id.to_s+".0"]
        return (!nrows.nil? && (nrows.to_i > 0) && !ncols.nil? && (ncols.to_i > 0) && !firstcolname.nil?)
    end
    
    def getNumBaselineRows(arm_id, bl_id)
        if isBaselineComplex(arm_id, bl_id)
            nrows = @designdetails["bl.blf."+arm_id.to_s+"."+bl_id.to_s+".size"]
            return nrows.to_i
        else
            return 1
        end
    end
    
    def getBaselineRowNames(blidx)
        bl_id = getBaselineID(blidx)
        # Iterate through all the arms and compile the list of uniq row names
        # Return array of datapoint names associated with the referenced Baseline
        compnames = Array.new
        @armids.each do |arm_id|
            if isBaselineComplex(arm_id,bl_id)
                nrows = @baseline["bl.blf."+arm_id.to_s+"."+bl_id.to_s+".size"]
                if !nrows.nil? && (nrows.to_i > 0)
                    for rowidx in 0..nrows.to_i - 1
                        rowname = @baseline["bl.blf."+arm_id.to_s+"."+bl_id.to_s+"."+rowidx.to_s]
                        if !compnames.include?(rowname)
                            compnames << rowname
                        end
                    end
                end
            end
        end
        return compnames
    end
    
    def getBaselineRowNamesByID(arm_id,bl_id)
        rownames = Array.new
        nrows = @baseline["bl.blf."+arm_id.to_s+"."+bl_id.to_s+".size"]
        if !nrows.nil? && (nrows.to_i > 0)
            for rowidx in 0..nrows.to_i - 1
                rowname = @baseline["bl.blf."+arm_id.to_s+"."+bl_id.to_s+"."+rowidx.to_s]
                if !rownames.include?(rowname)
                    rownames << rowname
                end
            end
        end
        return rownames
    end
    
    def getNumBaselineCols(arm_id,bl_id)
        if isBaselineComplex(arm_id,bl_id)
            ncols = @baseline["bl.cblf."+arm_id.to_s+"."+bl_id.to_s+".size"]
            return ncols.to_i + 1       # Compensate for extra column for row labels
        else
            return 1
        end
    end
    
    # Calculates the total columns each Baseline would take up
    def getTotalNumBaselineCols(arm_id)
        totalcols = 0;
        @baselineids.each do |bl_id|
            totalcols = totalcols + getNumBaselineCols(arm_id,bl_id)
        end
        return totalcols
    end
    
    def getBaselineColNamesByID(arm_id,bl_id)
        colnames = Array.new
        ncols = @baseline["bl.cblf."+arm_id.to_s+"."+bl_id.to_s+".size"]
        if !ncols.nil? && (ncols.to_i > 0)
            for colidx in 0..ncols.to_i - 1
                colname = @baseline["bl.cblf."+arm_id.to_s+"."+bl_id.to_s+"."+colidx.to_s]
                if !colnames.include?(colname)
                    colnames << colname
                end
            end
        end
        return colnames
    end
    
    def getBaselineColNames(blidx)
        bl_id = getBaselineID(blidx)
        # Iterate through all the arms and compile the list of uniq row names
        # Return array of datapoint names associated with the referenced Baseline
        compnames = Array.new
        @armids.each do |arm_id|
            if isBaselineComplex(arm_id,bl_id)
                ncols = @baseline["bl.cblf."+arm_id.to_s+"."+bl_id.to_s+".size"]
                if !ncols.nil? && (ncols.to_i > 0)
                    for colidx in 0..ncols.to_i - 1
                        colname = @baseline["bl.cblf."+arm_id.to_s+"."+bl_id.to_s+"."+colidx.to_s]
                        if !colname.nil? && !compnames.include?(colname)
                            compnames << colname
                        end
                    end
                end
            end
        end
        return compnames
    end
    
    def isBaselineSingleValue(bl_id)
        nvals = @baseline["bl.blf."+bl_id.to_s+".size"]
        ncvals = @baseline["bl.cblf."+bl_id.to_s+".size"]
        return (!nvals.nil? && !ncvals.nil? && (nvals.to_i == 0) && (ncvals.to_i == 0))
    end
    
    def containsBaselineValue(arm_id,bl_id)
        val = @baseline["bl.dp."+arm_id.to_s+"."+bl_id.to_s]
        return !val.nil?
    end
    
    def getBaselineValue(arm_id,bl_id)
        val = @baseline["bl.dp."+arm_id.to_s+"."+bl_id.to_s]
        if val.nil?
            val = @baseline["bl.dp."+arm_id.to_s+"."+bl_id.to_s+".0.0"]
        end
        if val.nil?
            val = "-"
        end
        return val
    end
    
    def getBaselineValueTOREMOVE(blidx)
        val = @baseline["bl.dp."+blidx.to_s+".0.0"]
        if val.nil?
            val = "-"
        end
        return val
    end
    
    def getBaselineFieldValue(blidx,blfidx)
        val = @baseline["bl.dp."+blidx.to_s+"."+blfidx.to_s+".0"]
        if val.nil?
            val = "-"
        end
        return val
    end
    
    def containsBaselineMatrixValue(arm_id,bl_id,row_idx,col_idx)
        val = @baseline["bl.dp."+arm_id.to_s+"."+bl_id.to_s+"."+row_idx.to_s+"."+col_idx.to_s]
        return !val.nil?
    end
    
    def getBaselineMatrixValue(arm_id,bl_id,row_idx,col_idx)
        val = @baseline["bl.dp."+arm_id.to_s+"."+bl_id.to_s+"."+row_idx.to_s+"."+col_idx.to_s]
        if val.nil?
            val = "-"
        end
        return val
    end
    
    # Arms ----------------------------------------------------------------
    def getNumArms()
        if @armnames.nil? ||
           @armnames.size() == 0
            return 0
        else
            return @armnames.size()
        end    
    end
    
    def containsArm(name)
        return (name == "total") || @armnames.include?(name)
    end
    
    def getArmName(idx)
        return @armnames[idx]
    end
    
    def getNumArmIDs()
        if @armids.nil? ||
           @armids.size() == 0
            return 0
        else
            return @armids.size()
        end    
    end
    
    def containsArmID(id)
        return @armids.include?(id)
    end
    
    def getArmID(idx)
        return @armids[idx]
    end
    
    def getArmIDByName(arm)
        if arm.eql?("total")
            return 0
        end
        
        if @armnames.nil? ||
           @armnames.size() == 0
            return -1
        end
        aidx = @armnames.index(arm)
        if !aidx.nil? &&
            (aidx >= 0)
            return @armids[aidx]
        else
            return -1
        end
    end
    
    def getArmNameByID(arm_id)
        if arm_id == 0
            return "total"
        else
            arm_name = @arms_map[arm_id]
            if arm_name.nil?
                arm_name = "["+arm_id.to_s+"]"
            end
            return arm_name
        end
    end
    
    # Outcomes ----------------------------------------------------------------
    # Outcomes Arms ----------------------------------------------------------------
    def getNumOutcomeArms()
        if @outcomesarms_names.nil? ||
           @outcomesarms_names.size() == 0
            return 0
        else
            return @outcomesarms_names.size()
        end    
    end
    
    def containsOutcomeArmsName(name)
        return @outcomesarms_names.include?(name)
    end
    
    def getOutcomeArm(idx)
        return @outcomesarms_names[idx]
    end
    
    # Outcomes Subgroups ----------------------------------------------------------------
    def getNumDistinctOutcomeSubGroups()
        # Across all outcomes
        if @outcomessubgroup_names.nil? ||
           @outcomessubgroup_names.size() == 0
            return 0
        else
            return @outcomessubgroup_names.size()
        end    
    end
    
    def containsDistinctSubGroup(name)
        return @outcomessubgroup_names.include?(name)
    end
    
    def getDistinctOutcomeSubGroup(idx)
        return @outcomessubgroup_names[idx]
    end
    
    def getDistinctOutcomeSubGroupID(idx)
        return @outcomessubgroup_ids[idx]
    end
    
    def getDistinctOutcomeSubGroupIDByName(name)
        idx = @outcomessubgroup_names.index(name)
        if idx.nil? || (idx < 0)
            return -1
        else
            return @outcomessubgroup_ids[idx]
        end
    end
    
    def getNumOutcomeSubGroups(outidx)
        if @outcomesdata["outcomes_"+outidx.to_s+"_subgroup_ids"].nil? ||
           @outcomesdata["outcomes_"+outidx.to_s+"_subgroup_ids"].size() == 0
            return 0
        else
            return @outcomesdata["outcomes_"+outidx.to_s+"_subgroup_ids"].size()
        end    
    end
    
    def getOutcomeSubGroupIDs(outidx)
        if @outcomesdata["outcomes_"+outidx.to_s+"_subgroup_ids"].nil?
            return Array.new
        else
            return @outcomesdata["outcomes_"+outidx.to_s+"_subgroup_ids"]
        end    
    end
    
    def getOutcomeSubGroupNames(outidx)
        if @outcomesdata["outcomes_"+outidx.to_s+"_subgroup_names"].nil?
            return Array.new
        else
            return @outcomesdata["outcomes_"+outidx.to_s+"_subgroup_names"]
        end    
    end
    
    def containsSubGroup(outidx,name)
        return getOutcomeSubGroupNames(outidx).include?(name)
    end
    
    def getOutcomeSubGroup(outidx,idx)
        return getOutcomeSubGroupNames(outidx)[idx]
    end
    
    def getOutcomeSubGroupID(outidx,idx)
        return getOutcomeSubGroupIDs(outidx)[idx]
    end
    
    def getOutcomeSubGroupIDByName(name)
        idx = getOutcomeSubGroupNames(outidx).index(name)
        if idx.nil? || (idx < 0)
            return -1
        else
            return getOutcomeSubGroupIDs(outidx)[idx]
        end
    end
    
    # Outcomes Time points ----------------------------------------------------------------
    def getNumOutcomeTimePoints()
        if @outcomestimept_names.nil? ||
           @outcomestimept_names.size() == 0
            return 0
        else
            return @outcomestimept_names.size()
        end    
    end
    
    def containsTimePoints(name)
        return @outcomestimept_names.include?(name)
    end
    
    def getOutcomeTimePoint(idx)
        return @outcomestimept_names[idx]
    end
    
    def getOutcomeTimePointID(idx)
        return @outcomestimept_ids[idx]
    end
    
    def getOutcomeTimePointIDByName(name)
        idx = @outcomestimept_names.index(name)
        if idx.nil? || (idx < 0)
            return -1
        else
            return @outcomestimept_ids[idx]
        end
    end
    
    # Outcomes Measures ----------------------------------------------------------------
    def getNumOutcomeMeasures()
        if @outcomesmeas_names.nil? ||
           @outcomesmeas_names.size() == 0
            return 0
        else
            return @outcomesmeas_names.size()
        end    
    end
    
    def containsOutcomeMeasureName(name)
        return @outcomesmeas_names.include?(name)
    end
    
    def getOutcomeMeasure(idx)
        return @outcomesmeas_names[idx]
    end
    
    # Outcome Results ----------------------------------------------------------------
    def getNumOutcomes()
        if @outcomenames.nil? ||
           @outcomenames.size() == 0
            return 0
        else
            return @outcomenames.size()
        end    
    end
    
    def containsOutcomeName(name)
        return @outcomenames.include?(name)
    end
    
    def getOutcomeName(idx)
        return @outcomenames[idx]
    end
    
    def getNumOutcomeResults()
        if @outcomesdata.nil? ||
           @outcomesdata.size() == 0
           return 0
        else
            return @outcomesdata["outcome.size"]
        end    
    end
    
    def containsOutcomeValue(name,subgroup,timept,meas,arm)
        return !@outcomesdata["outcome.value."+name+"."+subgroup+"."+timept+"."+meas+"."+arm].nil?
    end
    
    def getOutcomesValue(name,subgroup,timept,meas,arm)
        return @outcomesdata["outcome.value."+name+"."+subgroup+"."+timept+"."+meas+"."+arm]
    end
    
    # Outcome Details ----------------------------------------------------------------
    def getNumOutcomeDetails()
        if @outcomedetailsnames.nil? ||
           @outcomedetailsnames.size() == 0
            return 0
        else
            return @outcomedetailsnames.size
        end    
    end
    
    def containsOutcomeDetail(name)
        return @outcomedetailsnames.include?(name)
    end
    
    def getOutcomeDetailID(idx)
        return @outcomedetailsids[idx]
    end
    
    def getOutcomeDetailName(idx)
        return @outcomedetailsnames[idx]
    end
    
    def getOutcomeDetailIDByName(name)
        idx = @outcomedetailsnames.index(name)
        if idx.nil? || idx < 0
            return "x"
        else
            return @outcomedetailsids[idx]
        end
    end     
    
    def getOutcomeDetailDataTypeName(outd_id)
        outdtype = @outcomedetailsids["outd.type."+outd_id.to_s]
        if outdtype.nil?
            outdtype = "na"
        end
        return outdtype
    end
    
    def isOutcomeDetailComplex(outd_id)
        nrows = @outcomedetails["outd.outdf."+outd_id.to_s+".size"]
        ncols = @outcomedetails["outd.coutdf."+outd_id.to_s+".size"]
        # matrix_radio type has ncol == 1, but no column names listed - TODO need better way of handling this
        # so need to check for this condition
        firstcolname = @outcomedetails["outd.coutdf."+outd_id.to_s+".0"]
        return (!nrows.nil? && (nrows.to_i > 0) && !ncols.nil? && (ncols.to_i > 0) && !firstcolname.nil?)
    end
    
    def getNumOutcomeDetailRows(outd_id)
        if isOutcomeDetailComplex(outd_id)
            nrows = @designdetails["outd.outdf."+outd_id.to_s+".size"]
            return nrows.to_i
        else
            return 1
        end
    end
    
    def getOutcomeDetailRowNames(outdidx)
        outd_id = getOutcomeDetailID(outdidx)
        # Return array of datapoint names associated with the referenced OutcomeDetail
        compnames = Array.new
        if isOutcomeDetailComplex(outd_id)
            nrows = @outcomedetails["outd.outdf."+outd_id.to_s+".size"]
            if !nrows.nil? && (nrows.to_i > 0)
                for rowidx in 0..nrows.to_i - 1
                    rowname = @outcomedetails["outd.outdf."+outd_id.to_s+"."+rowidx.to_s]
                    if !compnames.include?(rowname)
                        compnames << rowname
                    end
                end
            end
        end
        return compnames
    end
    
    def getOutcomeDetailRowNamesByID(outd_id)
        rownames = Array.new
        nrows = @outcomedetails["outd.outdf."+outd_id.to_s+".size"]
        if !nrows.nil? && (nrows.to_i > 0)
            for rowidx in 0..nrows.to_i - 1
                rowname = @outcomedetails["outd.outdf."+outd_id.to_s+"."+rowidx.to_s]
                if !rownames.include?(rowname)
                    rownames << rowname
                end
            end
        end
        return rownames
    end
    
    def getNumOutcomeDetailCols(outd_id)
        if isOutcomeDetailComplex(outd_id)
            ncols = @outcomedetails["outd.coutdf."+outd_id.to_s+".size"]
            return ncols.to_i + 1       # Compensate for extra column for row labels
        else
            return 1
        end
    end
    
    # Calculates the total columns each Outcome Detail would take up
    def getTotalNumOutcomeDetailCols()
        totalcols = 0;
        @outcomedetailsids.each do |outd_id|
            totalcols = totalcols + getNumOutcomeDetailCols(outd_id)
        end
        return totalcols
    end
    
    def getOutcomeDetailColNamesByID(outd_id)
        colnames = Array.new
        ncols = @outcomedetails["outd.coutdf."+outd_id.to_s+".size"]
        if !ncols.nil? && (ncols.to_i > 0)
            for colidx in 0..ncols.to_i - 1
                colname = @outcomedetails["outd.coutdf."+outd_id.to_s+"."+colidx.to_s]
                if !colnames.include?(colname)
                    colnames << colname
                end
            end
        end
        return colnames
    end
    
    def getOutcomeDetailColNames(outdidx)
        outd_id = getOutcomeDetailID(outdidx)
        # Return array of datapoint names associated with the referenced OutcomeDetail
        compnames = Array.new
        if isOutcomeDetailComplex(outd_id)
            ncols = @outcomedetails["outd.coutdf."+outd_id.to_s+".size"]
            if !ncols.nil? && (ncols.to_i > 0)
                for colidx in 0..ncols.to_i - 1
                    colname = @outcomedetails["outd.coutdf."+outd_id.to_s+"."+colidx.to_s]
                    if !colname.nil? && !compnames.include?(colname)
                        compnames << colname
                    end
                end
            end
        end
        return compnames
    end
    
    def isOutcomeDetailSingleValue(outd_id)
        nvals = @outcomedetails["outd.outdf."+outd_id.to_s+".size"]
        ncvals = @outcomedetails["outd.coutdf."+outd_id.to_s+".size"]
        return (!nvals.nil? && !ncvals.nil? && (nvals.to_i == 0) && (ncvals.to_i == 0))
    end
    
    def containsOutcomeDetailValue(outd_id)
        val = @outcomedetails["outd.dp."+outd_id.to_s]
        return !val.nil?
    end
    
    def getOutcomeDetailValue(outd_id)
        val = @outcomedetails["outd.dp."+outd_id.to_s]
        if val.nil?
            val = @outcomedetails["outd.dp."+outd_id.to_s+".0.0"]
        end
        if val.nil?
            val = "-"
        end
        return val
    end
    
    def getOutcomeDetailFieldValue(outd_id,outdfidx)
        val = @outcomedetails["outd.dp."+outd_id.to_s+"."+outdfidx.to_s+".0"]
        if val.nil?
            val = "-"
        end
        return val
    end
    
    def containsOutcomeDetailMatrixValue(outd_id,row_idx,col_idx)
        val = @outcomedetails["outd.dp."+outd_id.to_s+"."+row_idx.to_s+"."+col_idx.to_s]
        return !val.nil?
    end
    
    def getOutcomeDetailMatrixValue(outd_id,row_idx,col_idx)
        val = @outcomedetails["outd.dp."+outd_id.to_s+"."+row_idx.to_s+"."+col_idx.to_s]
        if val.nil?
            val = "-"
        end
        return val
    end
    
    # Adverse Events ----------------------------------------------------------------
    def getNumAdverseEvents()
        if @adverseevents.nil? ||
           @adverseevents.size() == 0
           return 0
        else
            return @adverseevents["adve.size"]
        end    
    end
    
    def getAdverseEventsID(idx)
        return @adverseevents["adve.ids"][idx]
    end
    
    def getAdverseEventsName(idx)
        return @adverseevents["adve.names"][idx]
    end
    
    def getAdverseEventColumnID(idx)
        return @adverseevents["adve.cid"][idx]
    end
    
    def getAdverseEventColumnName(idx)
        return @adverseevents["adve.cname"][idx]
    end
    
    def getAdverseEventColumnDescription(idx)
        return @adverseevents["adve.cdesc"][idx]
    end
    
    def getAdverseEventResultID(idx)
        return @adverseevents["adve.rid"][idx]
    end
    
    def containsAdverseEventName(name)
        return @adverseevents["adve.names"].include?(name)
    end
    
    def getAdverseEventsValue(name,armid)
        return @adverseevents["adve.value."+armid+"."+name]
    end
    
    def containsAdverseEventValue(name,armid)
        return !@adverseevents["adve.value."+armid+"."+name].nil?
    end
       
    def getAdverseEventsTotalValue(name)
        return getAdverseEventsValue(name,"total")
    end
    
    # Quality Dimensions ----------------------------------------------------------------
    def getNumQualityDim()
        if @quality.nil? ||
           @quality.size() == 0
           return 0
        else
            return @quality["qd.size"]
        end    
    end
    
    def getQualityDimID(idx)
        return @quality_ids[idx]
    end
    
    def getQualityDimIDByName(qd_name)
        idx = @quality_names.index(qd_name)
        if idx.nil? || (idx < 0)
            return -1
        else
            return getQualityDimID(idx)
        end
    end
    
    def getQualityDimNameByIndex(idx)
        return @quality_names[idx]
    end
    
    def getQualityDimName(qd_id)
        idx = @quality_ids.index(qd_id)
        if idx.nil? || (idx.to_i < 0)
            return "na"
        else
            return getQualityDimNameByIndex(idx)
        end
    end
    
    def containsQualityDimValue(qd_id)
        return (@quality_ids.index(qd_id) >= 0)
    end
    
    def getQualityDimValue(qd_id)
        return @quality["qd.value."+qd_id.to_s]
    end
    
    def getQualityDimValueByName(qd_name)
        qd_id = getQualityDimIDByName(qd_name);
        if qd_id.nil? || qd_id < 0
            return "-"
        else
            return @quality["qd.value."+qd_id.to_s]
        end
    end
    
    # Total Quality Rating ----------------------------------------------------------------
    def getTotalQualityValue()
        if @qualityratings.nil?
            if @quality_rating.nil? 
                return nil
            else
                return @quality_rating
            end
        else
            return @qualityratings.current_overall_rating
        end
    end
    
    # Within Arms Comparison ----------------------------------------------------------------
    def getNumWAC()
        # Comparators
        if @wac_ids.nil? ||
           @wac_ids.size() == 0
           return 0
        else
            return @wac_num
        end    
    end
    
    def getWACComparatorName(wac_idx)
        if @wac_names.nil? ||
           @wac_names.size() == 0
           return "-"
        else
            return @wac_names[wac_idx]
        end    
    end
    
    def containsWACComparatorName(wac)
        if @wac_names.nil? ||
           @wac_names.size() == 0
           return false
        else
            return @wac_names.include?(wac)
        end    
    end
    
    def getNumWACMeasures()
        if @wac_comp_measures.nil? ||
           @wac_comp_measures.size() == 0
           return 0
        else
            return @wac_comp_measures.size()
        end    
    end
    
    def containsWACMeasureName(wacm)
        if !@wac_comp_measures.nil? &&
           @wac_comp_measures.size() > 0
            # Iterate through all the WAC measures and see if any ends with "|"+wacm
            @wac_comp_measures.each do |swacm|
                if swacm.split("|").last == wacm
                    return true
                end
            end
        end    
        return false
    end
    
    def getWACMeasureIDByName(wacm)
        if !@wac_comp_measures.nil? &&
           @wac_comp_measures.size() > 0
            # Iterate through all the WAC measures and see if any ends with "|"+wacm
            @wac_comp_measures.each do |swacm|
                if wbacm.split("|").last == wacm
                    return wbacm.split("|").first.to_i
                end
            end
        end    
        return -1
    end
    
    def getWACMeasure(wac_meas_idx)
        if @wac_comp_measures.nil? ||
           @wac_comp_measures.size() == 0
           return "-"
        else
            return @wac_comp_measures[wac_meas_idx].split("|").last     # Array of [Measure ID | Measure Title]
        end    
    end
    
    def getWACItemTitle(outidx,
                        sgid,
                        wac_id,
                        wac_meas_id,
                        armid)
        if @wac_data.nil? ||
           @wac_data["wac."+outidx.to_s+"."+sgid.to_s+"."+wac_id.to_s+"."+wac_meas_id.to_s+"."+armid.to_s+".title"].nil?
           return "-"
        else
            @wac_data["wac."+outidx.to_s+"."+sgid.to_s+"."+wac_id.to_s+"."+wac_meas_id.to_s+"."+armid.to_s+".title"]
        end    
    end
    
    def getWACItemDesc(outidx,
                       sgid,
                       wac_id,
                       wac_meas_id,
                       armid)
        if @wac_data.nil? ||
           @wac_data["wac."+outidx.to_s+"."+sgid.to_s+"."+wac_id.to_s+"."+wac_meas_id.to_s+"."+armid.to_s+".description"].nil?
           return "-"
        else
            @wac_data["wac."+outidx.to_s+"."+sgid.to_s+"."+wac_id.to_s+"."+wac_meas_id.to_s+"."+armid.to_s+".description"]
        end    
    end
    
    def getWACItemUnit(outidx,
                       sgid,
                       wac_id,
                       wac_meas_id,
                       armid)
        if @wac_data.nil? ||
           @wac_data["wac."+outidx.to_s+"."+sgid.to_s+"."+wac_id.to_s+"."+wac_meas_id.to_s+"."+armid.to_s+".unit"].nil?
           return "-"
        else
            @wac_data["wac."+outidx.to_s+"."+sgid.to_s+"."+wac_id.to_s+"."+wac_meas_id.to_s+"."+armid.to_s+".unit"]
        end    
    end
    
    def getWACItemValue(outidx,
                        sgid,
                        wac_id,
                        wac_meas_id,
                        armid)
        if @wac_data.nil? ||
           @wac_data["wac."+outidx.to_s+"."+sgid.to_s+"."+wac_id.to_s+"."+wac_meas_id.to_s+"."+armid.to_s+".data.value"].nil?
           return "-"
        else
            @wac_data["wac."+outidx.to_s+"."+sgid.to_s+"."+wac_id.to_s+"."+wac_meas_id.to_s+"."+armid.to_s+".data.value"]
        end    
    end
    
    def getWACItemFootnote(outidx,
                           sgid,
                           wac_id,
                           wac_meas_id,
                           armid)
        if @wac_data.nil? ||
           @wac_data["wac."+outidx.to_s+"."+sgid.to_s+"."+wac_id.to_s+"."+wac_meas_id.to_s+"."+armid.to_s+".data.footnote"].nil?
           return "-"
        else
            @wac_data["wac."+outidx.to_s+"."+sgid.to_s+"."+wac_id.to_s+"."+wac_meas_id.to_s+"."+armid.to_s+".data.footnote"]
        end    
    end
    
    def getNumWACArms()
        if @wac_arms.nil?
            return 0
        else
            return @wac_arms.size()
        end
    end
    
    def containsWACArmName(waca)
        if !@wac_arms.nil? &&
           @wac_arms.size() > 0
            # Iterate through all the WAC arms and see if any ends with "|"+waca
            @wac_arms.each do |swaca|
                if swaca.split("|").last == waca
                    return true
                end
            end
        end    
        return false
    end
    
    def getWACArmIDByName(waca)
        if !@wac_arms.nil? &&
           @wac_arms.size() > 0
            # Iterate through all the WAC measures and see if any ends with "|"+waca
            @wac_arms.each do |swaca|
                if wbaca.split("|").last == waca
                    return wbaca.split("|").first.to_i
                end
            end
        end    
        return -1
    end
    
    def getWACArm(wac_arm_idx)
        if @wac_arms.nil? ||
           @wac_arms.size() == 0
           return "-"
        else
            return @wac_arms[wac_arm_idx].split("|").last     # Array of [Arm ID | Arm Title]
        end    
    end
    
    def getWACValue(outcomename,
                    sgname,
                    wac,
                    wacm,
                    armname)
        outidx = @outcomenames.index(outcomename);
        sgids = @outcomesdata["outcomes_"+outidx.to_s+"_subgroup_ids"]
        sgnames = @outcomesdata["outcomes_"+outidx.to_s+"_subgroup_names"]
        idx = sgnames.index(sgname)
        sgid = -1
        if idx >= 0
            sgid = sgids[idx]
        end
        wac_arm_id = "-1"
        @wac_arms.each do |waca|
            # waca format [id|name]
            armparts = waca.split("|")
            if (armname == armparts[1]) &&
                (wac_arm_id == "-1")
                wac_arm_id = armparts[0]
            end
        end
        idx = @wac_names.index(wac)            
        wac_id = -1
        if idx >= 0
            wac_id = @wac_ids[idx]
        end
        
        wac_meas_id = getWACMeasureIDByName(wacm)
                    
        if @wac_data.nil? ||
           @wac_data["wac."+outidx.to_s+"."+sgid.to_s+"."+wac_id.to_s+"."+wac_meas_id.to_s+"."+wac_arm_id.to_s+".data.value"].nil?
           return "wac."+outidx.to_s+"."+sgid.to_s+"."+wac_id.to_s+"."+wac_meas_id.to_s+"."+wac_arm_id.to_s+".data.value=nil"
        else
           return @wac_data["wac."+outidx.to_s+"."+sgid.to_s+"."+wac_id.to_s+"."+wac_meas_id.to_s+"."+wac_arm_id.to_s+".data.value"]
        end    
    end
    
    # Between Arms Comparison ----------------------------------------------------------------
    def getNumBAC()
        if @bac_ids.nil? ||
           @bac_ids.size() == 0
           return 0
        else
            return @bac_num
        end    
    end
    
    def getBACComparatorName(bac_idx)
        if @bac_names.nil? ||
           @bac_names.size() == 0
           return "-"
        else
            return @bac_names[bac_idx]
        end    
    end
    
    def containsBACComparatorName(bac)
        if @bac_names.nil? ||
           @bac_names.size() == 0
           return false
        else
            return @bac_names.include?(bac)
        end    
    end
    
    def getNumBACTimePoints()
        if @bac_timepts.nil? ||
           @bac_timepts.size() == 0
           return 0
        else
            return @bac_timepts.size()
        end    
    end
    
    def getNumBACMeasures()
        if @bac_comp_measures.nil? ||
           @bac_comp_measures.size() == 0
           return 0
        else
            return @bac_comp_measures.size()
        end    
    end
    
    def containsBACMeasureName(bacm)
        if !@bac_comp_measures.nil? &&
           @bac_comp_measures.size() > 0
            # Iterate through all the BAC measures and see if any ends with "|"+bacm
            @bac_comp_measures.each do |sbacm|
                if sbacm.split("|").last == bacm
                    return true
                end
            end
        end    
        return false
    end
    
    def getBACMeasureIDByName(bacm)
        if !@bac_comp_measures.nil? &&
           @bac_comp_measures.size() > 0
            # Iterate through all the BAC measures and see if any ends with "|"+bacm
            @bac_comp_measures.each do |sbacm|
                if sbacm.split("|").last == bacm
                    return sbacm.split("|").first.to_i
                end
            end
        end    
        return -1
    end
    
    def getBACMeasure(bac_meas_idx)
        if @bac_comp_measures.nil? ||
           @bac_comp_measures.size() == 0
           return "-"
        else
            return @bac_comp_measures[bac_meas_idx].split("|").last     # Array of [Measure ID | Measure Title]
        end    
    end
    
    def getBACItemTitle(outidx,
                        sgid,
                        bac_tp_id,
                        bac_id,
                        bac_meas_id)
        if @bac_data.nil? ||
           @bac_data["bac."+outidx.to_s+"."+sgid.to_s+"."+bac_tp_id.to_s+"."+bac_id.to_s+"."+bac_meas_id.to_s+".title"].nil?
           return "-"
        else
            @bac_data["bac."+outidx.to_s+"."+sgid.to_s+"."+bac_tp_id.to_s+"."+bac_id.to_s+"."+bac_meas_id.to_s+".title"]
        end    
    end
    
    def getBACItemDesc(outidx,
                       sgid,
                       bac_tp_id,
                       bac_id,
                       bac_meas_id)
        if @bac_data.nil? ||
           @bac_data["bac."+outidx.to_s+"."+sgid.to_s+"."+bac_tp_id.to_s+"."+bac_id.to_s+"."+bac_meas_id.to_s+".description"].nil?
           return "-"
        else
            @bac_data["bac."+outidx.to_s+"."+sgid.to_s+"."+bac_tp_id.to_s+"."+bac_id.to_s+"."+bac_meas_id.to_s+".description"]
        end    
    end
    
    def getBACItemUnit(outidx,
                       sgid,
                       bac_tp_id,
                       bac_id,
                       bac_meas_id)
        if @bac_data.nil? ||
           @bac_data["bac."+outidx.to_s+"."+sgid.to_s+"."+bac_tp_id.to_s+"."+bac_id.to_s+"."+bac_meas_id.to_s+".unit"].nil?
           return "-"
        else
            @bac_data["bac."+outidx.to_s+"."+sgid.to_s+"."+bac_tp_id.to_s+"."+bac_id.to_s+"."+bac_meas_id.to_s+".unit"]
        end    
    end
    
    def getBACItemValue(outidx,
                        sgid,
                        bac_tp_id,
                        bac_id,
                        bac_meas_id)
        if @bac_data.nil? ||
           @bac_data["bac."+outidx.to_s+"."+sgid.to_s+"."+bac_tp_id.to_s+"."+bac_id.to_s+"."+bac_meas_id.to_s+".data.value"].nil?
           return "-"
        else
            @bac_data["bac."+outidx.to_s+"."+sgid.to_s+"."+bac_tp_id.to_s+"."+bac_id.to_s+"."+bac_meas_id.to_s+".data.value"]
        end    
    end
    
    def getBACItemFootnote(outidx,
                           sgid,
                           bac_tp_id,
                           bac_id,
                           bac_meas_id)
        if @bac_data.nil? ||
           @bac_data["bac."+outidx.to_s+"."+sgid.to_s+"."+bac_tp_id.to_s+"."+bac_id.to_s+"."+bac_meas_id.to_s+".data.footnote"].nil?
           return "-"
        else
            @bac_data["bac."+outidx.to_s+"."+sgid.to_s+"."+bac_tp_id.to_s+"."+bac_id.to_s+"."+bac_meas_id.to_s+".data.footnote"]
        end    
    end
    
    def getBACValue(outcomename,
                    sgname,
                    tpname,
                    bac,
                    bacm)
        outidx = @outcomenames.index(outcomename);
        sgids = @outcomesdata["outcomes_"+outidx.to_s+"_subgroup_ids"]
        sgnames = @outcomesdata["outcomes_"+outidx.to_s+"_subgroup_names"]
        idx = sgnames.index(sgname)
        sgid = -1
        if idx >= 0
            sgid = sgids[idx]
        end
        bac_tp_id = "-1"
        @bac_timepts.each do |bactp|
            # bactp format [id|number|units]
            tpparts = bactp.split("|")
            if (tpname == tpparts[1]+" "+tpparts[2]) &&
                (bac_tp_id == "-1")
                bac_tp_id = tpparts[0]
            end
        end
        idx = @bac_names.index(bac)            
        bac_id = -1
        if idx >= 0
            bac_id = @bac_ids[idx]
        end
        
        bac_meas_id = getBACMeasureIDByName(bacm)
                    
        if @bac_data.nil? ||
           @bac_data["bac."+outidx.to_s+"."+sgid.to_s+"."+bac_tp_id.to_s+"."+bac_id.to_s+"."+bac_meas_id.to_s+".data.value"].nil?
           return "bac."+outidx.to_s+"."+sgid.to_s+"."+bac_tp_id.to_s+"."+bac_id.to_s+"."+bac_meas_id.to_s+".data.value=nil"
        else
           return @bac_data["bac."+outidx.to_s+"."+sgid.to_s+"."+bac_tp_id.to_s+"."+bac_id.to_s+"."+bac_meas_id.to_s+".data.value"]
        end    
    end
end
