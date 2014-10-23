class Reportset

    # Reportset is implemented as simple Array of Studydata classes. Studydata is a container - Hash map of data associated with a study
    # for a given study id and extraction form id
    
    def initialize
        @project = nil
        # Hold list of project values in String format - in the same order as defined in the reportconfig
        @project_values = Array.new
        @studies = []
        @ef_ids = Array.new
        @ef_map = Hash.new
        @ef_titles = Array.new
        @ef_notes = Array.new
        
        # Instantiate individual section sets, organized by EF in a HashMap ----------------------------------------
        @designdetails_map = Hash.new       # DesignDetailsSet
        @arms_map = Hash.new                # ArmsSet
        @armdetails_map = Hash.new          # ArmDetailsSet
        @baseline_map = Hash.new            # BaselineSet
        @outcomedetails_map = Hash.new      # OutcomeDetailsSet
        @outcomesubgroup_map = Hash.new     # OutcomeSubgroupSet
        @outcometimepoint_map = Hash.new    # OutcomeTimepointSet
        @outcomemeas_map = Hash.new         # OutcomeMeasSet
        @outcomes_map = Hash.new            # OutcomesSet
        @advevents_map = Hash.new           # AdveventsSet
        @qualdims_map = Hash.new            # QualitySet
        # Instantiate individual section sets ----------------------------------------
        
        # Define master list of field names across all studies added and references <name>:<study id>:<field index>
        @armdetails_names = Array.new
        @armdetails_rownames = Hash.new     # Hash[<arm detail idx>] = Array[names]
        @armdetails_colnames = Hash.new     # Hash[<arm detail idx>] = Array[names]
        
        @designdetails_names = Array.new
        @designdetails_rownames = Hash.new     # Hash[<design detail idx>] = Array[names]
        @designdetails_colnames = Hash.new     # Hash[<design detail idx>] = Array[names]
        
        @baseline_names = Array.new
        @baseline_rownames = Hash.new     # Hash[<baseline idx>] = Array[names]
        @baseline_colnames = Hash.new     # Hash[<baseline idx>] = Array[names]
        
        @outcomesdata_names = Array.new     # unique list of outcome result names across all studies in this comparason set
        @outcomesdata_subgroups = Array.new # unique list of outcome result sub groups across all studies in this comparason set
        @outcomesdata_timepts = Array.new   # unique list of outcome result timepoints across all studies in this comparason set
        @outcomesdata_meas = Array.new      # unique list of outcome result measure names across all studies in this comparason set
        @outcomesdata_arms = Array.new      # unique list of outcome result arms across all studies in this comparason set
        
        @outcomedetails_names = Array.new
        @outcomedetails_rownames = Hash.new     # Hash[<outcome detail idx>] = Array[names]
        @outcomedetails_colnames = Hash.new     # Hash[<outcome detail idx>] = Array[names]
        
        @arms_names = Array.new             # unique list of arm names across all studies in this comparason set
        @arms_ids = Array.new               # unique list of corresponding arm ids to the arms_names across all studies in this comparason set
        
        
        @adverseevents_names = Array.new
        
        @quality_names = Array.new
        
        @wac_names = Array.new
        @wac_measure_names = Array.new
        
        @bac_names = Array.new
        @bac_measure_names = Array.new
    end
    
    def add(project_id,study_id,extraction_form_id)
        puts ">>>>>>>>>>>> Reportset - add project_id = "+project_id.to_s+" sid "+study_id.to_s+" efid "+extraction_form_id.to_s
        # Only include those with a primary publication attached to the study_id
        
        if @project.nil?
            puts ">>>>>>>>>>> Reportset - getting project data from database"
            @project = Project.find(project_id)
        end
        # Setup project data list
        if @project.title.nil?
            @project_values << "-"
        else
            @project_values << @project.title
        end
        if @project.description.nil?
            @project_values << "-"
        else
            @project_values << @project.description
        end
        if @project.notes.nil?
            @project_values << "-"
        else
            @project_values << @project.notes
        end
        if @project.funding_source.nil?
            @project_values << "-"
        else
            @project_values << @project.funding_source
        end
        if @project.creator_id.nil?
            @project_values << "-"
        else
            @project_values << User.get_name(@project.creator_id)
        end
        if @project.created_at.nil?
            @project_values << "-"
        else
            @project_values << @project.created_at.to_s
        end
        if @project.updated_at.nil?
            @project_values << "-"
        else
            @project_values << @project.updated_at.to_s
        end
        
        # Track list of study index in ef_map
        ef_list = @ef_map[extraction_form_id]
        if ef_list.nil?
            ef_list = Array.new
        end
        ef_list << @studies.size()
        @ef_map[extraction_form_id] = ef_list
        
        studyrec = Studydata.new
        studyrec.load(project_id,study_id,extraction_form_id)
        
        if  !@ef_ids.include?(extraction_form_id)
            @ef_ids << extraction_form_id
            @ef_titles << studyrec.getExtractionFormTitle()
            @ef_notes << studyrec.getExtractionFormTitle()
        end
        
        # ------------------------ New Container Design -----------------------------------------
        # Add study sections to reportset containers --------------------------------------------
        ddset = @designdetails_map[extraction_form_id.to_s]
        if ddset.nil?
            ddset = DesignDetailsSet.new
            @designdetails_map[extraction_form_id.to_s] = ddset
        end
        ddset.add(studyrec.getDesignDetails())
        
        armsset = @arms_map[extraction_form_id.to_s]
        if armsset.nil?
            armsset = ArmsSet.new
            @arms_map[extraction_form_id.to_s] = armsset
        end
        armsset.add(studyrec.getArms())
        
        armdset = @armdetails_map[extraction_form_id.to_s]
        if armdset.nil?
            armdset = ArmDetailsSet.new
            @armdetails_map[extraction_form_id.to_s] = armdset
        end
        armdset.add(studyrec.getArmDetails())
        
        blset = @baseline_map[extraction_form_id.to_s]
        if blset.nil?
            blset = BaselineSet.new
            @baseline_map[extraction_form_id.to_s] = blset
        end
        blset.add(studyrec.getBaselines())
        
        outdset = @outcomedetails_map[extraction_form_id.to_s]
        if outdset.nil?
            outdset = OutcomeDetailsSet.new
            @outcomedetails_map[extraction_form_id.to_s] = outdset
        end
        outdset.add(studyrec.getOutcomeDetails())
        
        outsgset = @outcomesubgroup_map[extraction_form_id.to_s]
        if outsgset.nil?
            outsgset = OutcomeSubgroupSet.new
            @outcomesubgroup_map[extraction_form_id.to_s] = outsgset
        end
        outsgset.add(studyrec.getOutcomeSubgroups())
        
        outtpset = @outcometimepoint_map[extraction_form_id.to_s]
        if outtpset.nil?
            outtpset = OutcomeTimepointSet.new
            @outcometimepoint_map[extraction_form_id.to_s] = outtpset
        end
        outtpset.add(studyrec.getOutcomeTimepoints())
        
        outmsset = @outcomemeas_map[extraction_form_id.to_s]
        if outmsset.nil?
            outmsset = OutcomeMeasSet.new
            @outcomemeas_map[extraction_form_id.to_s] = outmsset
        end
        outmsset.add(studyrec.getOutcomeMeasures())
        
        outset = @outcomes_map[extraction_form_id.to_s]
        if outset.nil?
            outset = OutcomesSet.new
            @outcomes_map[extraction_form_id.to_s] = outset
        end
        outset.add(studyrec.getOutcomes())
        
        adveset = @advevents_map[extraction_form_id.to_s]
        if adveset.nil?
            adveset = AdveventsSet.new
            @advevents_map[extraction_form_id.to_s] = adveset
        end
        adveset.add(studyrec.getAdvEvents())
        
        qualdimset = @qualdims_map[extraction_form_id.to_s]
        if qualdimset.nil?
            qualdimset = QualitySet.new
            @qualdims_map[extraction_form_id.to_s] = qualdimset
        end
        qualdimset.add(studyrec.getQuality())
        # ------------------------ New Container Design -----------------------------------------
        
        # Arm Details ---------------------------------------------------------------------------
=begin
        if studyrec.getNumArmDetails() > 0
            for idx in 0..studyrec.getNumArmDetails() - 1
                name = studyrec.getArmDetailName(idx)
                if !@armdetails_names.include?(name)
                    @armdetails_names << name
                end
                
                armdfrows = studyrec.getArmDetailRowNames(idx)
                if !armdfrows.nil? && (armdfrows.size() > 0)
                    if @armdetails_rownames[idx.to_s].nil?
                        @armdetails_rownames[idx.to_s] = armdfrows
                    else
                        armdfrows.each do |name|
                            if !@armdetails_rownames[idx.to_s].include?(name)
                                @armdetails_rownames[idx.to_s] << name
                            end
                        end
                    end
                end
                
                armdfcols = studyrec.getArmDetailColNames(idx)
                if !armdfcols.nil? && (armdfcols.size() > 0)
                    if @armdetails_colnames[idx.to_s].nil?
                        @armdetails_colnames[idx.to_s] = armdfcols
                    else
                        armdfcols.each do |name|
                            if !@armdetails_colnames[idx.to_s].include?(name)
                                @armdetails_colnames[idx.to_s] << name
                            end
                        end
                    end
                end
                
            end
        end
=end
        
        # Outcome Details ---------------------------------------------------------------------------
=begin
        if studyrec.getNumDesignDetails() > 0
            for idx in 0..studyrec.getNumDesignDetails() - 1
                name = studyrec.getDesignDetailName(idx)
                if !@designdetails_names.include?(name)
                    @designdetails_names << name
                end
                
                designdfrows = studyrec.getDesignDetailRowNames(idx)
                if !designdfrows.nil? && (designdfrows.size() > 0)
                    if @designdetails_rownames[idx.to_s].nil?
                        @designdetails_rownames[idx.to_s] = designdfrows
                    else
                        designdfrows.each do |name|
                            if !@designdetails_rownames[idx.to_s].include?(name)
                                @designdetails_rownames[idx.to_s] << name
                            end
                        end
                    end
                end
                
                designdfcols = studyrec.getDesignDetailColNames(idx)
                if !designdfcols.nil? && (designdfcols.size() > 0)
                    if @designdetails_colnames[idx.to_s].nil?
                        @designdetails_colnames[idx.to_s] = designdfcols
                    else
                        designdfcols.each do |name|
                            if !@designdetails_colnames[idx.to_s].include?(name)
                                @designdetails_colnames[idx.to_s] << name
                            end
                        end
                    end
                end
                
            end
        end
=end
        
        # Baseline ---------------------------------------------------------------------------
=begin
        if studyrec.getNumBaselines() > 0
            for idx in 0..studyrec.getNumBaselines() - 1
                name = studyrec.getBaselineName(idx)
                if !@baseline_names.include?(name)
                    @baseline_names << name
                end
                
                blfrows = studyrec.getBaselineRowNames(idx)
                if !blfrows.nil? && (blfrows.size() > 0)
                    if @baseline_rownames[idx.to_s].nil?
                        @baseline_rownames[idx.to_s] = blfrows
                    else
                        blfrows.each do |name|
                            if !@baseline_rownames[idx.to_s].include?(name)
                                @baseline_rownames[idx.to_s] << name
                            end
                        end
                    end
                end
                
                blfcols = studyrec.getBaselineColNames(idx)
                if !blfcols.nil? && (blfcols.size() > 0)
                    if @baseline_colnames[idx.to_s].nil?
                        @baseline_colnames[idx.to_s] = blfcols
                    else
                        blfcols.each do |name|
                            if !@baseline_colnames[idx.to_s].include?(name)
                                @baseline_colnames[idx.to_s] << name
                            end
                        end
                    end
                end
                
            end
        end
=end
                  
        # Outcome Results ---------------------------------------------------------------------------
        if studyrec.getNumOutcomes() > 0
            for idx in 0..studyrec.getNumOutcomes() - 1
                name = studyrec.getOutcomeName(idx)
                if !@outcomesdata_names.include?(name)
                    @outcomesdata_names << name
                end
            end
        end
=begin
        if studyrec.getNumDistinctOutcomeSubGroups() > 0
            for idx in 0..studyrec.getNumDistinctOutcomeSubGroups() - 1
                name = studyrec.getDistinctOutcomeSubGroup(idx)
                if !@outcomesdata_subgroups.include?(name)
                    @outcomesdata_subgroups << name
                end
            end
        end
=end
=begin
        if studyrec.getNumOutcomeTimePoints() > 0
            for idx in 0..studyrec.getNumOutcomeTimePoints() - 1
                name = studyrec.getOutcomeTimePoint(idx)
                if !@outcomesdata_timepts.include?(name)
                    @outcomesdata_timepts << name
                end
            end
        end
=end
        if studyrec.getNumOutcomeMeasures() > 0
            for idx in 0..studyrec.getNumOutcomeMeasures() - 1
                name = studyrec.getOutcomeMeasure(idx)
                if !@outcomesdata_meas.include?(name)
                    @outcomesdata_meas << name
                end
            end
        end
        if studyrec.getNumOutcomeArms() > 0
            for idx in 0..studyrec.getNumOutcomeArms() - 1
                name = studyrec.getOutcomeArm(idx)
                if !@outcomesdata_arms.include?(name)
                    @outcomesdata_arms << name
                end
            end
        end
        
=begin
        if studyrec.getNumOutcomeDetails() > 0
            for idx in 0..studyrec.getNumOutcomeDetails() - 1
                name = studyrec.getOutcomeDetailName(idx)
                if !@outcomedetails_names.include?(name)
                    @outcomedetails_names << name
                end
                
                outcomedfrows = studyrec.getOutcomeDetailRowNames(idx)
                if !outcomedfrows.nil? && (outcomedfrows.size() > 0)
                    if @outcomedetails_rownames[idx.to_s].nil?
                        @outcomedetails_rownames[idx.to_s] = outcomedfrows
                    else
                        outcomedfrows.each do |name|
                            if !@outcomedetails_rownames[idx.to_s].include?(name)
                                @outcomedetails_rownames[idx.to_s] << name
                            end
                        end
                    end
                end
                
                outcomedfcols = studyrec.getOutcomeDetailColNames(idx)
                if !outcomedfcols.nil? && (outcomedfcols.size() > 0)
                    if @outcomedetails_colnames[idx.to_s].nil?
                        @outcomedetails_colnames[idx.to_s] = outcomedfcols
                    else
                        outcomedfcols.each do |name|
                            if !@outcomedetails_colnames[idx.to_s].include?(name)
                                @outcomedetails_colnames[idx.to_s] << name
                            end
                        end
                    end
                end
                
            end                  
        end
=end
        
=begin
        if studyrec.getNumArms() > 0
            for idx in 0..studyrec.getNumArms() - 1
                name = studyrec.getArmName(idx)
                id = studyrec.getArmID(idx)
                if !@arms_names.include?(name)
                    @arms_names << name
                    @arms_ids << id
                end
            end
        end
=end
        
=begin
        if studyrec.getNumAdverseEvents() > 0
            for idx in 0..studyrec.getNumAdverseEvents() - 1
                name = studyrec.getAdverseEventsName(idx)
                if !@adverseevents_names.include?(name)
                    @adverseevents_names << name
                end
            end
        end
=end
        
=begin
        if studyrec.getNumQualityDim() > 0
            for idx in 0..studyrec.getNumQualityDim() - 1
                qd_id = studyrec.getQualityDimID(idx)
                qd_name = studyrec.getQualityDimName(qd_id)
                if !@quality_names.include?(qd_name)
                    @quality_names << qd_name
                end
            end
        end
=end
        
        if studyrec.getNumWAC() > 0
            for wac_idx in 0..studyrec.getNumWAC() - 1
                name = studyrec.getWACComparatorName(wac_idx)
                if !@wac_names.include?(name)
                    @wac_names << name
                end
            end
        end
        
        if studyrec.getNumWACMeasures() > 0
            for wac_meas_idx in 0..studyrec.getNumWACMeasures() - 1
                name = studyrec.getWACMeasure(wac_meas_idx)
                if !@wac_measure_names.include?(name)
                    @wac_measure_names << name
                end
            end
        end
        
        if studyrec.getNumBAC() > 0
            for wac_idx in 0..studyrec.getNumBAC() - 1
                name = studyrec.getBACComparatorName(wac_idx)
                if !@bac_names.include?(name)
                    @bac_names << name
                end
            end
        end
        
        if studyrec.getNumBACMeasures() > 0
            for bac_meas_idx in 0..studyrec.getNumBACMeasures() - 1
                name = studyrec.getBACMeasure(bac_meas_idx)
                if !@bac_measure_names.include?(name)
                    @bac_measure_names << name
                end
            end
        end
        
        @studies << studyrec
    end
    
    def remove(study_id,extraction_form_id)
    end
    
    # Add study sections to reportset containers --------------------------------------------
    def getDesignDetails(ef_id)
        return @designdetails_map[ef_id.to_s]
    end
    
    def getArms(ef_id)
        return @arms_map[ef_id.to_s]
    end
    
    def getArmDetails(ef_id)
        return @armdetails_map[ef_id.to_s]
    end
    
    def getBaseline(ef_id)
        return @baseline_map[ef_id.to_s]
    end
    
    def getOutcomeDetails(ef_id)
        return @outcomedetails_map[ef_id.to_s]
    end
    
    def getOutcomeSubgroups(ef_id)
        return @outcomesubgroup_map[ef_id.to_s]
    end
    
    def getOutcomeTimepoints(ef_id)
        return @outcometimepoint_map[ef_id.to_s]
    end
    
    def getOutcomeMeasures(ef_id)
        return @outcomemeas_map[ef_id.to_s]
    end
    
    def getOutcomes(ef_id)
        return @outcomes_map[ef_id.to_s]
    end
    
    def getAdvEvents(ef_id)
        return @advevents_map[ef_id.to_s]
    end
    
    def getQuality(ef_id)
        return @qualdims_map[ef_id.to_s]
    end
    
    # ------------------------------------------------------------------------------------------------------------------
    # Study filter methods - supports searching within a project for studies. Returns a list of study ids that matched
    # Search method is very loose - if target contains the text
    def filterByPMIDs(fpmids)
        study_ids = Array.new
        fpmids.each do |fpmid|
            @studies.each do |studyrec|
                pmid = studyrec.getPMID()
                if pmid.nil?
                    pmid = ""
                else
                    pmid = pmid.upcase
                end
                if !pmid.index(fpmid.upcase).nil? &&
                    (pmid.index(fpmid.upcase) >= 0) &&
                    !study_ids.include?(studyrec.getStudyID().to_s)
                    study_ids << studyrec.getStudyID().to_s
                end
            end 
        end 
        return study_ids
    end
    
    def filterByTitles(ftitles)
        study_ids = Array.new
        ftitles.each do |ftitle|
            @studies.each do |studyrec|
                title = studyrec.getTitle()
                if title.nil?
                    title = ""
                else
                    title = title.upcase
                end
                if !title.index(ftitle.upcase).nil? &&
                    (title.index(ftitle.upcase) >= 0) &&
                    !study_ids.include?(studyrec.getStudyID())
                    study_ids << studyrec.getStudyID().to_s
                end
            end 
        end 
        return study_ids
    end
    
    def filterByAuthors(fauthors)
        study_ids = Array.new
        fauthors.each do |fauthor|
            @studies.each do |studyrec|
                authors = studyrec.getAuthor()
                if authors.nil?
                    authors = ""
                else
                    authors = authors.upcase
                end
                if !authors.index(fauthor.upcase).nil? &&
                    (authors.index(fauthor.upcase) >= 0) &&
                    !study_ids.include?(studyrec.getStudyID())
                    study_ids << studyrec.getStudyID().to_s
                end
            end 
        end 
        return study_ids
    end
    
    # Study access methods ----------------------------------------------------------------------
    def getStudyIDs()
        study_ids = Array.new
        if @studies.size() > 0
            @studies.each do |studyrec|
                study_ids << studyrec.getStudyID()
            end 
        end
        return study_ids
    end
    
    def get(idx)
        return @studies[idx]    
    end
    
    def size
        return @studies.size()    
    end
    
    def studyMemberOfEF(idx, efid)
        if idx >= @studies.size()
            return false
        end
        studyrec = @studies[idx]
        return (studyrec.getExtractionFormID() == efid)    
    end
    
    def getStudyID(sidx)
        studydata = get(sidx)
        if studydata.nil?
            return ""
        else
            return studydata.getStudyID()
        end
    end
    
    def getStudyTitle(sidx)
        studydata = get(sidx)
        if studydata.nil?
            return ""
        else
            return studydata.getTitle()
        end
    end
    
    def getStudyAuthor(sidx)
        studydata = get(sidx)
        if studydata.nil?
            return ""
        else
            return studydata.getAuthor()
        end
    end
    
    def getStudyPMID(sidx)
        studydata = get(sidx)
        if studydata.nil?
            return ""
        else
            return studydata.getPMID()
        end
    end
    
    # Project access methods ----------------------------------------------------------------------
    def getProjectID()
        return @project.id
    end
    
    def getProjectTitle()
        return @project.title
    end
    
    def getProjectValue(idx)
        if idx >= @project_values.size()
            return "-"
        end
        return @project_values[idx]
    end
    
    def getNumPublicationItems(sidx)
        return @studies[sidx].getNumPublicationItems()
    end
    
    def getPublicationData(sidx,idx)
        return @studies[sidx].getPublicationData(idx)
    end
    
    def getAuthor(sidx)
        return @studies[sidx].getAuthor()
    end
    
    def getFirstAuthor(sidx)
        return @studies[sidx].getFirstAuthor(getAuthor(sidx))
    end
    
    def getAlternateNumbers(sidx)
        return @studies[sidx].getAlternateNumbers()
    end
    
    # Arms ----------------------------------------------------------------
    def getNumDistinctArms()
        return @arms_names.size()
    end
    
    def containsArmName(sidx,name)
        return @studies[sidx].containsArm(name)
    end
    
    def getArmName(idx)
        if idx >= getNumDistinctArms()
            return "total"
        else
            return @arms_names[idx]
        end
    end
    
    def getArmID(idx)
        if idx >= getNumDistinctArms()
            return 0
        else
            return @arms_ids[idx]
        end
    end
    
    def getArmIDByName(sidx,arm)
        # Look up arm name from the study
        return @studies[sidx].getArmIDByName(arm)
    end
    
    # Extraction Form access methods ------------------------------------------------------------------------
    def getEFSize()
        return @ef_ids.size()
    end
    
    def getEFID(idx)
        if idx >= @ef_ids.size()
            return nil
        end
        return @ef_ids[idx]
    end
    
    def getEFTitle(idx)
        if idx >= @ef_titles.size()
            return nil
        end
        return @ef_titles[idx]
    end
    
    def getEFTitleByID(ef_id)
        idx = @ef_ids.index(ef_id.to_i)
        if idx.nil? ||
            (idx < 0)
            return nil
        end
        return @ef_titles[idx]
    end
    
    def getEFNote(idx)
        if idx >= @ef_notes.size()
            return nil
        end
        return @ef_notes[idx]
    end
    
    def getStudyIndices(ef_id)
        return @ef_map[ef_id]
    end
    
    # Study access methods ------------------------------------------------------------------------
    def getStudyID(idx)
        if idx >= @studies.size()
            return nil
        end
        return @studies[idx].getStudyID()
    end
    
    def getStudyTitle(idx)
        if idx >= @studies.size()
            return ""
        end
        return @studies[idx].getTitle()
    end
    
    def getStudyYear(idx)
        if idx >= @studies.size()
            return ""
        end
        return @studies[idx].getYear()
    end
    
    def getStudyAuthor(idx)
        if idx >= @studies.size()
            return ""
        end
        return @studies[idx].getAuthor()
    end
    
    def getStudyCountry(idx)
        if idx >= @studies.size()
            return ""
        end
        return @studies[idx].getCountry()
    end
    
    def getStudyPMID(idx)
        if idx >= @studies.size()
            return ""
        end
        return @studies[idx].getPMID()
    end
    
    def getStudyJournal(idx)
        if idx >= @studies.size()
            return ""
        end
        return @studies[idx].getJournal()
    end
    
    def getStudyVolume(idx)
        if idx >= @studies.size()
            return ""
        end
        return @studies[idx].getVolume()
    end
    
    def getStudyIssue(idx)
        if idx >= @studies.size()
            return ""
        end
        return @studies[idx].getIssue()
    end
    
    def getStudyCreatorID(idx)
        if idx >= @studies.size()
            return ""
        end
        return @studies[idx].getCreatorID()
    end
    
    def getPublicationTableHeader(show_pub_fields)
        header_list = Array.new
        header_list << "Publication"
        return header_list
    end
    
    def getPublicationTableContent(idx,show_pub_fields)
        data_list = Array.new
        pub_info = ""
        for pubfield in show_pub_fields
            if pubfield == "authorfirstonly"
                # Ignore this flag
            else
                if pub_info.length > 0
                    pub_info << "<br/>"
                end
                if (pubfield == "author") &&
                    show_pub_fields.include?("authorfirstonly")
                    # Only show the first author - assume comma separated author list
                    pauthors = getStudyAuthor(idx)
                    if pauthors.nil?
                        pauthors = "-"
                    end
                    authorlist = pauthors.split(",");
                    if authorlist.size > 1
                        pub_info << authorlist[0].to_s + ", et al"
                    else
                        # Only one author - show the whole thing
                        pub_info << getStudyAuthor(idx)
                    end
                elsif (pubfield == "id")
                    pub_info << getStudyID(idx).to_s
                elsif (pubfield == "title")
                    pub_info << getStudyTitle(idx)
                elsif (pubfield == "year")
                    pub_info << getStudyYear(idx)
                elsif (pubfield == "country")
                    pub_info << getStudyCountry(idx)
                elsif (pubfield == "pmid")
                    pub_info << getStudyPMID(idx)
                elsif (pubfield == "journal")
                    pub_info << getStudyJournal(idx)
                elsif (pubfield == "volume")
                    pub_info << getStudyVolume(idx)
                elsif (pubfield == "issue")
                    pub_info << getStudyIssue(idx)
                elsif (pubfield == "creatorid")
                    pub_info << getStudyCreatorID(idx)
                end
            end
        end
        
        data_list << pub_info 
        return data_list
    end
    
    # Arm Details access methods ------------------------------------------------------------------------
    def getNumDistinctArmDetails()
        return @armdetails_names.size()
    end
    
    def getArmDetailsName(idx)
        return @armdetails_names[idx]
    end
    
    def getArmDetailName(sidx,armdidx)
        return @studies[sidx].getArmDetailName(armdidx)
    end
    
    def getArmDetailID(sidx,armdidx)
        return @studies[sidx].getArmDetailID(armdidx)
    end
    
    def getArmDetailIDByName(sidx,name)
        return @studies[sidx].getArmDetailIDByName(name)
    end
    
    def isArmDetailComplex(sidx,arm_id,armd_id)
        return @studies[sidx].isArmDetailComplex(arm_id,armd_id)
    end
    
    def getNumArmDetailsRows(idx)
        rownames = getArmDetailsRowNames(idx)
        if rownames.nil?
            return 0
        else
            return rownames.size()
        end
    end
    
    def getArmDetailsRowNames(idx)
        return @armdetails_rownames[idx.to_s]
    end
    
    def getArmDetailRowNamesByID(sidx,arm_id,armd_id)
        return @studies[sidx].getArmDetailRowNamesByID(arm_id,armd_id)
    end
    
    def getNumDistinctArmDetailsCols(idx)
        colnames = getArmDetailsColNames(idx)
        if colnames.nil?
            return 0
        else
            return colnames.size()
        end
    end
    
    def getArmDetailsColNames(idx)
        return @armdetails_colnames[idx.to_s]
    end
    
    def getArmDetailColNamesByID(sidx,arm_id,armd_id)
        return @studies[sidx].getArmDetailColNamesByID(arm_id,armd_id)
    end
    
    def getArmDetailsTableHeader(show_arm_names)
        header_list = Array.new
        for i in 0..show_arm_names.size() - 1
            header_list << show_arm_names[i]
        end
        return header_list
    end
    
    def getArmDetailsTableContent(idx,show_arm_names)
        data_list = Array.new
        for i in 0..show_arm_names.size() - 1
            # TODO - 
        end
        return data_list
    end
    
    def getArmDetailValue(idx,arm_id,armd_id)
        return @studies[idx].getArmDetailValue(arm_id,armd_id)
    end
    
    def getArmDetailFieldValue(idx,armdidx,armdfidx)
        return @studies[idx].getArmDetailFieldValue(armdidx,armdfidx)
    end
    
    def getArmDetailMatrixValue(sidx,arm_id,armd_id,row_idx,col_idx)
        return @studies[sidx].getArmDetailMatrixValue(arm_id,armd_id,row_idx,col_idx)
    end
    
    # Design Details access methods ------------------------------------------------------------------------
    def getNumDistinctDesignDetails()
        return @designdetails_names.size()
    end
    
    def getDesignDetailsName(idx)
        return @designdetails_names[idx]
    end
    
    def getDesignDetailName(sidx,ddidx)
        return @studies[sidx].getDesignDetailName(ddidx)
    end
    
    def getDesignDetailID(sidx,ddidx)
        return @studies[sidx].getDesignDetailID(ddidx)
    end
    
    def getDesignDetailIDByName(sidx,name)
        return @studies[sidx].getDesignDetailIDByName(name)
    end
    
    def isDesignDetailComplex(sidx,dd_id)
        return @studies[sidx].isDesignDetailComplex(dd_id)
    end
    
    def getNumDesignDetailsRows(idx)
        rownames = getDesignDetailsRowNames(idx)
        if rownames.nil?
            return 0
        else
            return rownames.size()
        end
    end
    
    def getDesignDetailsRowNames(idx)
        return @designdetails_rownames[idx.to_s]
    end
    
    def getDesignDetailRowNamesByID(sidx,dd_id)
        return @studies[sidx].getDesignDetailRowNamesByID(dd_id)
    end
    
    def getNumDistinctDesignDetailsCols(idx)
        colnames = getDesignDetailsColNames(idx)
        if colnames.nil?
            return 0
        else
            return colnames.size()
        end
    end
    
    def getDesignDetailsColNames(idx)
        return @designdetails_colnames[idx.to_s]
    end
    
    def getDesignDetailColNamesByID(sidx,dd_id)
        return @studies[sidx].getDesignDetailColNamesByID(dd_id)
    end
    
    def getDesignDetailValue(idx,dd_id)
        return @studies[idx].getDesignDetailValue(dd_id)
    end
    
    def getDesignDetailFieldValue(idx,ddidx,ddfidx)
        return @studies[idx].getDesignDetailFieldValue(ddidx,ddfidx)
    end
    
    def getDesignDetailMatrixValue(sidx,dd_id,row_idx,col_idx)
        return @studies[sidx].getDesignDetailMatrixValue(dd_id,row_idx,col_idx)
    end
    
    # Design Detail EXCEL Methods ------------------------------------------------------------------------
    def getDesignDetailsEXCELSpan(dd_name)
        col_span = 0
        for sidx in 0..size() - 1
            study_colspan = @studies[sidx].getDesignDetailColSpan(dd_name)
            if study_colspan > col_span
                col_span = study_colspan
            end
        end
        return col_span
    end
    
    def getDesignDetailsEXCELLabels(dd_name)
        # All studies have the same set of DD labels for the same question
        return @studies[0].getDesignDetailsEXCELLabels(dd_name)
    end
    
    def getDesignDetailEXCELValues(sidx,dd_name)
        return @studies[sidx].getDesignDetailEXCELValues(dd_name)
    end
    
    # Baseline Characteristics access methods ------------------------------------------------------------------------
    def getNumDistinctBaselines()
        return @baseline_names.size()
    end
    
    def getBaselinesName(idx)
        return @baseline_names[idx]
    end
    
    def getBaselineName(sidx,blidx)
        return @studies[sidx].getBaselineName(blidx)
    end
    
    def getBaselineID(sidx,blidx)
        return @studies[sidx].getBaselineID(blidx)
    end
    
    def getBaselineIDByName(sidx,name)
        return @studies[sidx].getBaselineIDByName(name)
    end
    
    def isBaselineComplex(sidx,arm_id,bl_id)
        return @studies[sidx].isBaselineComplex(arm_id,bl_id)
    end
    
    def getNumBaselineRows(idx)
        rownames = getBaselineRowNames(idx)
        if rownames.nil?
            return 0
        else
            return rownames.size()
        end
    end
    
    def getBaselineRowNames(idx)
        return @baseline_rownames[idx.to_s]
    end
    
    def getBaselineRowNamesByID(sidx,arm_id,bl_id)
        return @studies[sidx].getBaselineRowNamesByID(arm_id,bl_id)
    end
    
    def getNumDistinctBaselineCols(idx)
        colnames = getBaselineColNames(idx)
        if colnames.nil?
            return 0
        else
            return colnames.size()
        end
    end
    
    def getBaselineColNames(idx)
        return @baseline_colnames[idx.to_s]
    end
    
    def getBaselineColNamesByID(sidx,arm_id,bl_id)
        return @studies[sidx].getBaselineColNamesByID(arm_id,bl_id)
    end
    
    def getBaselineTableHeader(show_arm_names)
        header_list = Array.new
        for i in 0..show_arm_names.size() - 1
            header_list << show_arm_names[i]
        end
        return header_list
    end
    
    def getBaselineTableContent(idx,show_arm_names)
        data_list = Array.new
        for i in 0..show_arm_names.size() - 1
            # TODO - 
        end
        return data_list
    end
    
    def getBaselineValue(idx,arm_id,bl_id)
        return @studies[idx].getBaselineValue(arm_id,bl_id)
    end
    
    def getBaselineFieldValue(idx,blidx,blfidx)
        return @studies[idx].getBaselineFieldValue(blidx,blfidx)
    end
    
    def getBaselineMatrixValue(sidx,arm_id,bl_id,row_idx,col_idx)
        return @studies[sidx].getBaselineMatrixValue(arm_id,bl_id,row_idx,col_idx)
    end
    
    # Outcome Results access methods ------------------------------------------------------------------------
    def getNumOutcomes(sidx)
        return @studies[sidx].getNumOutcomes()
    end
    
    # Outcome Arms ------------------------------------------------------------------------
    def getNumDistinctOutcomeArms()
        return @outcomesdata_arms.size()
    end
    
    def containsOutcomeArmsName(sidx,name)
        return @studies[sidx].containsOutcomeArmsName(name)
    end
    
    def getOutcomeResultsArm(idx)
        if idx >= @outcomesdata_arms.size()
            return "total"
        else
            return @outcomesdata_arms[idx]
        end
    end
    
    # Outcome Subgroups ------------------------------------------------------------------------
    def getNumDistinctOutcomeSubGroups()
        return @outcomesdata_subgroups.size()
    end
    
    def getDistinctSubGroupIDByName(sidx,name)
        return @studies[sidx].getOutcomeSubGroupIDByName(name)
    end
    
    def containsDistinctSubGroupsName(sidx,name)
        return @studies[sidx].containsDistinctSubGroup(name)
    end
    
    def getDistinctOutcomeResultsSubGroups(idx)
        return @outcomesdata_subgroups[idx]
    end
    
    # Outcome Time points ------------------------------------------------------------------------
    def getNumDistinctOutcomeTimePoints()
        return @outcomesdata_timepts.size()
    end
    
    def getTimePointIDByName(sidx,name)
        return @studies[sidx].getOutcomeTimePointIDByName(name)
    end
    
    def containsTimePointsName(sidx,name)
        return @studies[sidx].containsTimePoints(name)
    end
    
    def getOutcomeResultsTimePoints(idx)
        return @outcomesdata_timepts[idx]
    end
    
    # Outcome Measures ------------------------------------------------------------------------
    def getNumDistinctOutcomeMeasures()
        return @outcomesdata_meas.size()
    end
    
    def containsOutcomeMeasureName(sidx,name)
        return @studies[sidx].containsOutcomeMeasureName(name)
    end
    
    def getOutcomeResultsMeasure(idx)
        return @outcomesdata_meas[idx]
    end
    
    # Outcomes ------------------------------------------------------------------------
    def getNumDistinctOutcomes()
        return @outcomesdata_names.size()
    end
    
    def containsOutcomeName(sidx,name)
        return @studies[sidx].containsOutcomeName(name)
    end
    
    def getOutcomeName(idx)
        return @outcomesdata_names[idx]
    end
    
    def getOutcomeTableHeader(show_outcomes_names,show_armsnames_names)
        # Outcome results are also organized by arms, timepoint, and measure dimensions
        header_list = Array.new
        for i in 0..show_outcomes_names.size() - 1
            for aidx in 0..getNumDistinctOutcomeArms()
                for tpidx in 0..getNumDistinctOutcomeTimePoints() - 1
                    for midx in 0..getNumDistinctOutcomeMeasures() - 1
                        if show_armsnames_names.include?(getOutcomeResultsArm(aidx))
                            header_list << show_outcomes_names[i]+
                                "<br/>Arm: "+getOutcomeResultsArm(aidx)+
                                "<br/>Timepoint: "+getOutcomeResultsTimePoints(tpidx)+
                                "<br/>Measure: "+getOutcomeResultsMeasure(midx)
                        end
                    end
                end
            end
        end
        return header_list
    end
    
    def getOutcomeTableContent(idx,show_outcomes_names,show_armsnames_names)
        data_list = Array.new
        for i in 0..show_outcomes_names.size() - 1
            for aidx in 0..getNumDistinctOutcomeArms()
                for tpidx in 0..getNumDistinctOutcomeTimePoints() - 1
                    for midx in 0..getNumDistinctOutcomeMeasures() - 1
                        if show_armsnames_names.include?(getOutcomeResultsArm(aidx))
                            dataval = @studies[idx].getOutcomesValue(show_outcomes_names[i],getOutcomeResultsTimePoints(tpidx),getOutcomeResultsMeasure(midx),getOutcomeResultsArm(aidx))
                            if dataval.nil?
                                dataval = "--"
                            end
                            data_list << dataval
                        end
                    end
                end
            end
        end
        return data_list
    end
    
    def containsOutcomeValue(sidx,name,subgroup,timept,meas,arm)
        return @studies[sidx].containsOutcomeValue(name,subgroup,timept,meas,arm)
    end
    
    def getOutcomesValue(sidx,name,subgroup,timept,meas,arm)
        return @studies[sidx].getOutcomesValue(name,subgroup,timept,meas,arm)
    end
    
    # Outcome Details access methods ------------------------------------------------------------------------
    def getNumDistinctOutcomeDetails()
        return @outcomedetails_names.size()
    end
    
    def getOutcomeDetailsName(idx)
        return @outcomedetails_names[idx]
    end
    
    def getOutcomeDetailName(sidx,outdidx)
        return @studies[sidx].getOutcomeDetailName(outdidx)
    end
    
    def getOutcomeDetailID(sidx,outdidx)
        return @studies[sidx].getOutcomeDetailID(outdidx)
    end
    
    def getOutcomeDetailIDByName(sidx,name)
        return @studies[sidx].getOutcomeDetailIDByName(name)
    end
    
    def isOutcomeDetailComplex(sidx,outd_id)
        return @studies[sidx].isOutcomeDetailComplex(outd_id)
    end
    
    def getNumOutcomeDetailsRows(idx)
        rownames = getOutcomeDetailsRowNames(idx)
        if rownames.nil?
            return 0
        else
            return rownames.size()
        end
    end
    
    def getOutcomeDetailsRowNames(idx)
        return @outcomedetails_rownames[idx.to_s]
    end
    
    def getOutcomeDetailRowNamesByID(sidx,outd_id)
        return @studies[sidx].getOutcomeDetailRowNamesByID(outd_id)
    end
    
    def getNumDistinctOutcomeDetailsCols(idx)
        colnames = getOutcomeDetailsColNames(idx)
        if colnames.nil?
            return 0
        else
            return colnames.size()
        end
    end
    
    def getOutcomeDetailsColNames(idx)
        return @outcomedetails_colnames[idx.to_s]
    end
    
    def getOutcomeDetailColNamesByID(sidx,outd_id)
        return @studies[sidx].getOutcomeDetailColNamesByID(outd_id)
    end
    
    def getOutcomeDetailValue(idx,outd_id)
        return @studies[idx].getOutcomeDetailValue(outd_id)
    end
    
    def getOutcomeDetailFieldValue(idx,ddidx,ddfidx)
        return @studies[idx].getOutcomeDetailFieldValue(ddidx,ddfidx)
    end
    
    def getOutcomeDetailMatrixValue(sidx,outd_id,row_idx,col_idx)
        return @studies[sidx].getOutcomeDetailMatrixValue(outd_id,row_idx,col_idx)
    end
    
    # Adverse Events access methods ------------------------------------------------------------------------
    def getNumDistinctAdverseEvents()
        return @adverseevents_names.size()
    end
    
    def getAdverseEventsName(idx)
        return @adverseevents_names[idx]
    end
    
    def getAdverseEventsTableHeader(show_advevents_names,show_armsnames_names)
        # Baseline are also organized by arms as second dimension
        header_list = Array.new
        for i in 0..show_advevents_names.size() - 1
            for aidx in 0..getNumDistinctArms()
                if show_armsnames_names.include?(getArmName(aidx))
                    header_list << show_advevents_names[i]+"<br/>Arm: "+getArmName(aidx)
                end
            end
        end
        return header_list
    end
    
    def getAdverseEventsTableContent(idx,show_advevents_names,show_armsnames_names)
        data_list = Array.new
        for i in 0..show_advevents_names.size() - 1
            for aidx in 0..getNumDistinctArms()
                if show_armsnames_names.include?(getArmName(aidx))
                    dataval = @studies[idx].getAdverseEventsValue(show_advevents_names[i],getArmName(aidx))
                    if dataval.nil?
                        dataval = "--"
                    end
                    data_list << dataval
                end
            end
        end
        return data_list
    end
    
    def containsAdverseEventName(sidx,name)
        return @studies[sidx].containsAdverseEventName(name)
    end
    
    def containsAdverseEventValue(sidx,name,arm)
        return @studies[sidx].containsAdverseEventValue(name,arm)
    end
    
    def getAdverseEventsValue(sidx,name,arm)
        return @studies[sidx].getAdverseEventsValue(name,arm)
    end
    
    # Quality Dimensions access methods ------------------------------------------------------------------------
    def getNumDistinctQualityDim()
        return @quality_names.size()
    end
    
    def getDistinctQualityDimName(idx)
        return @quality_names[idx]
    end
    
    def getQualityDimTableHeader(show_qualdimfields_names)
        header_list = Array.new
        for i in 0..show_qualdimfields_names.size() - 1
            header_list << show_qualdimfields_names[i]
        end
        return header_list
    end
    
    def getQualityDimTableContent(idx,show_qualdimfields_names)
        data_list = Array.new
        for i in 0..show_qualdimfields_names.size() - 1
            dataval = @studies[idx].getQualityDimValue(show_qualdimfields_names[i])
            if dataval.nil?
                dataval = "--"
            end
            data_list << dataval
        end
        return data_list
    end
    
    def containsQualityDimValue(sidx,qd_id)
        return @studies[sidx].containsQualityDimValue(qd_id)
    end
    
    def getQualityDimID(sidx,idx)
        return @studies[sidx].getQualityDimID(idx)
    end
    
    def getQualityDimIDByName(sidx,qd_name)
        return @studies[sidx].getQualityDimIDByName(qd_name)
    end
    
    def getQualityDimValue(sidx,qd_id)
        return @studies[sidx].getQualityDimValue(qd_id)
    end
    
    # Total Quality Ratings ----------------------------------------------------------------
    def getTotalQualityValue(sidx)
        return @studies[sidx].getTotalQualityValue()
    end
    
    # Within Arms Comparison ----------------------------------------------------------------
    def getNumDistinctWACComparators()
        return @wac_names.size()
    end
    
    def getWACComparatorName(idx)
        return @wac_names[idx]
    end
    
    def containsWACComparatorName(sidx,wac)
        return @studies[sidx].containsWACComparatorName(wac)
    end
    
    def getNumDistinctWACMeasures()
        return @wac_measure_names.size()
    end
    
    def getWACMeasureName(idx)
        return @wac_measure_names[idx]
    end
    
    def containsWACArmName(sidx,waca)
        return @studies[sidx].containsWACArmName(waca)
    end
    
    def getWACValue(sidx,outcomename,sgname,wac,wacm,armname)
        return @studies[sidx].getWACValue(outcomename,sgname,wac,wacm,armname)
    end
    
    # Between Arms Comparison ----------------------------------------------------------------
    def getNumDistinctBACComparators()
        return @bac_names.size()
    end
    
    def getBACComparatorName(idx)
        return @bac_names[idx]
    end
    
    def containsBACComparatorName(sidx,bac)
        return @studies[sidx].containsBACComparatorName(bac)
    end
    
    def getNumDistinctBACMeasures()
        return @bac_measure_names.size()
    end
    
    def getBACMeasureName(idx)
        return @bac_measure_names[idx]
    end
    
    def containsBACMeasureName(sidx,bacm)
        return @studies[sidx].containsBACMeasureName(bacm)
    end
    
    def getBACValue(sidx,outcomename,sgname,tpname,bac,bacm)
        return @studies[sidx].getBACValue(outcomename,sgname,tpname,bac,bacm)
    end
    
    # HTML Render methods --------------------------------------------------------------------------------------------
    def renderHTMLPreview(ef_id, reportconfig)
        # Get data sets for this extraction form
        ddset = getDesignDetails(ef_id.to_s)    
        armsset = getArms(ef_id.to_s)    
        armdset = getArmDetails(ef_id.to_s)    
        blset = getBaseline(ef_id.to_s)    
        outdset = getOutcomeDetails(ef_id.to_s)    
        outsgset = getOutcomeSubgroups(ef_id.to_s)    
        outtpset = getOutcomeTimepoints(ef_id.to_s)    
        outmsset = getOutcomeMeasures(ef_id.to_s)    
        outset = getOutcomes(ef_id.to_s)    
        adveset = getAdvEvents(ef_id.to_s)  
        
        # Get display configuration objects
        dd_config = reportconfig.getDesignDetails()
        arms_config = reportconfig.getArms()
        armd_config = reportconfig.getArmDetails()
        bl_config = reportconfig.getBaseline()
        outcomesgs_config = reportconfig.getOutcomeSubgroups()
        outcometpts_config = reportconfig.getOutcomeTimepoints()
        outcomemeas_config = reportconfig.getOutcomeMeasures()
        outd_config = reportconfig.getOutcomeDetails()
        adve_config = reportconfig.getAdvEvents()
        qualdim_config = reportconfig.getQuality()
        
        ef_title = getEFTitleByID(ef_id)
        if ef_title.nil?
            return "<span id=\"tc_preview_table_error\">No report data available for this extraction form ID "+ef_id.to_s+"</span>"
        end   
        htmlout = ""
        
        # Build preview table
        htmlout = htmlout + "<table class=\"tc_preview_table\">\n"
        # Main title row ----------------------------------------------------------------------------------
        htmlout = htmlout + "    <tr class=\"tc_preview_header\">\n"
        htmlout = htmlout + "        <td class=\"tc_preview_title\">\n"
        htmlout = htmlout + "        <strong>Publication</strong>\n"
        htmlout = htmlout + "        </td>\n"
        if dd_config.displayThisSection()
            htmlout = htmlout + renderHTMLPreviewTitle(dd_config)
        end
        if armd_config.displayThisSection() &&
            arms_config.displayThisSection()     # Only if Arm(s) were selected to be visible
            htmlout = htmlout + renderHTMLPreviewTitle(armd_config)
        end
        if bl_config.displayThisSection() &&
            arms_config.displayThisSection()     # Only if Arm(s) were selected to be visible
            htmlout = htmlout + renderHTMLPreviewTitle(bl_config)
        end
        if outcomesgs_config.displayThisSection() &&
            arms_config.displayThisSection()     # Only if Arm(s) were selected to be visible
            htmlout = htmlout + renderHTMLPreviewTitle(outcomesgs_config)
        end
        if outcometpts_config.displayThisSection() &&
            arms_config.displayThisSection()     # Only if Arm(s) were selected to be visible
            htmlout = htmlout + renderHTMLPreviewTitle(outcometpts_config)
        end
        if outcomemeas_config.displayThisSection() &&
            arms_config.displayThisSection()     # Only if Arm(s) were selected to be visible
            htmlout = htmlout + renderHTMLPreviewTitle(outcomemeas_config)
        end
        if outcomesgs_config.displayThisSection() &&
            outcometpts_config.displayThisSection() &&
            outcomemeas_config.displayThisSection() &&
            arms_config.displayThisSection()     # Only if Arm(s) were selected to be visible
            htmlout = htmlout + "        <strong>Outcome Results</strong>\n"
        end
        if outd_config.displayThisSection()
            htmlout = htmlout + renderHTMLPreviewTitle(outd_config)
        end
        if adve_config.displayThisSection()
            htmlout = htmlout + renderHTMLPreviewTitle(adve_config)
        end
        if qualdim_config.displayThisSection()
            htmlout = htmlout + renderHTMLPreviewTitle(qualdim_config)
        end
        htmlout = htmlout + "        <td class=\"tc_preview_title\">\n"
        htmlout = htmlout + "        <strong>Overall Quality</strong>\n"
        htmlout = htmlout + "        </td>\n"
        htmlout = htmlout + "    </tr>\n"
        # Sub title row ----------------------------------------------------------------------------------
        htmlout = htmlout + "    <tr class=\"tc_preview_subtitle\">\n"
        htmlout = htmlout + "        <td class=\"tc_preview_subtitle\">\n"
        htmlout = htmlout + "        &nbsp;\n"
        htmlout = htmlout + "        </td>\n"
        if dd_config.displayThisSection()
            htmlout = htmlout + renderHTMLPreviewSubTitle(dd_config)
        end
        if armd_config.displayThisSection() &&
            arms_config.displayThisSection()     # Only if Arm(s) were selected to be visible
            htmlout = htmlout + renderHTMLPreviewSubTitle(armd_config)
        end
        if bl_config.displayThisSection() &&
            arms_config.displayThisSection()     # Only if Arm(s) were selected to be visible
            htmlout = htmlout + renderHTMLPreviewSubTitle(bl_config)
        end
        if outcomesgs_config.displayThisSection() &&
            arms_config.displayThisSection()     # Only if Arm(s) were selected to be visible
            htmlout = htmlout + renderHTMLPreviewSubTitle(outcomesgs_config)
        end
        if outcometpts_config.displayThisSection() &&
            arms_config.displayThisSection()     # Only if Arm(s) were selected to be visible
            htmlout = htmlout + renderHTMLPreviewSubTitle(outcometpts_config)
        end
        if outcomemeas_config.displayThisSection() &&
            arms_config.displayThisSection()     # Only if Arm(s) were selected to be visible
            htmlout = htmlout + renderHTMLPreviewSubTitle(outcomemeas_config)
        end
        if outcomesgs_config.displayThisSection() &&
            outcometpts_config.displayThisSection() &&
            outcomemeas_config.displayThisSection() &&
            arms_config.displayThisSection()     # Only if Arm(s) were selected to be visible
            htmlout = htmlout + "        <td class=\"tc_preview_subtitle\">\n"
            htmlout = htmlout + "        <strong>Outcome Results</strong>\n"
            htmlout = htmlout + "        </td>\n"
        end
        if outd_config.displayThisSection()
            htmlout = htmlout + renderHTMLPreviewSubTitle(outd_config)
        end
        if adve_config.displayThisSection()
            htmlout = htmlout + renderHTMLPreviewSubTitle(adve_config)
        end
        if qualdim_config.displayThisSection()
            htmlout = htmlout + renderHTMLPreviewSubTitle(qualdim_config)
        end
        htmlout = htmlout + "        <td class=\"tc_preview_subtitle\">\n"
        htmlout = htmlout + "        &nbsp;\n"
        htmlout = htmlout + "        </td>\n"
        htmlout = htmlout + "    </tr>\n"
        # Publication rows ----------------------------------------------------------------------------------
        bgidx = 0
        rcolor = ["#FFFFFF","#EAEAEA"]
        sidx = 0
        @studies.each do |studyrec|
            if reportconfig.showStudy(sidx)
                htmlout = htmlout + "    <tr class=\"tc_preview_study\" bgcolor=\""+rcolor[bgidx % 2]+"\">\n"
                htmlout = htmlout + renderHTMLStudySummary(studyrec,reportconfig)
                if dd_config.displayThisSection()
                    htmlout = htmlout + renderHTMLPreviewValue(studyrec.getDesignDetails(),dd_config)
                end
                if armd_config.displayThisSection() &&
                    arms_config.displayThisSection()     # Only if Arm(s) were selected to be visible
                    htmlout = htmlout + renderHTMLPreviewValueByArms(studyrec.getArms(),studyrec.getArmDetails(),
                                                                     arms_config,armd_config)
                end
                if bl_config.displayThisSection() &&
                    arms_config.displayThisSection()     # Only if Arm(s) were selected to be visible
                    htmlout = htmlout + renderHTMLPreviewValueByArms(studyrec.getArms(),studyrec.getBaselines(),
                                                                     arms_config,bl_config)
                end
                if outcomesgs_config.displayThisSection() &&
                    arms_config.displayThisSection()     # Only if Arm(s) were selected to be visible
                    htmlout = htmlout + renderHTMLPreviewOutcomeValue(studyrec.getArms(),studyrec.getOutcomeSubgroups(),studyrec.getOutcomeTimepoints(),studyrec.getOutcomeMeasures(),
                                                                      arms_config,outcomesgs_config,outcometpts_config,outcomemeas_config)
                end
                if outcomesgs_config.displayThisSection() &&
                    outcometpts_config.displayThisSection() &&
                    outcomemeas_config.displayThisSection() &&
                    arms_config.displayThisSection()     # Only if Arm(s) were selected to be visible
                    htmlout = htmlout + "        <td class=\"tc_preview_study\">\n"
                    htmlout = htmlout + "        <strong>Outcome Results</strong>\n"
                    htmlout = htmlout + "        </td>\n"
                end
                if outd_config.displayThisSection()
                    htmlout = htmlout + renderHTMLPreviewValue(studyrec.getArms(),studyrec.getOutcomeDetails(),
                                                               arms_config,outd_config)
                end
                puts "--------------------- adve_config.displayThisSection()=#{adve_config.displayThisSection()}"
                if adve_config.displayThisSection()
                    htmlout = htmlout + renderHTMLPreviewValueByArms(studyrec.getArms(),studyrec.getAdvEvents(),
                                                                     arms_config,adve_config)
                end
                if qualdim_config.displayThisSection()
                    htmlout = htmlout + renderHTMLPreviewValue(studyrec.getQuality(),qualdim_config)
                end
                htmlout = htmlout + renderHTMLPreviewOverallQuality(studyrec)
                htmlout = htmlout + "    </tr>\n"
                bgidx = bgidx + 1
            end
            sidx = sidx + 1
        end
        
        htmlout = htmlout + "</table>\n"
        
        return htmlout
    end
    
    def renderHTMLPreviewTitle(section_config)
        htmlout = ""
        if section_config.displayThisSection()
            htmlout = htmlout + "        <td class=\"tc_preview_title\" colspan=\""+section_config.getNumQuestionToDisplay().to_s+"\">\n"
            htmlout = htmlout + "        <strong>"+section_config.getSectionLabel()+"</strong>\n"
            htmlout = htmlout + "        </td>\n"
        end
        return htmlout
    end
    
    def renderHTMLPreviewSubTitle(section_config)
        htmlout = ""
        if section_config.displayThisSection()
            subtitles = section_config.getDisplayTitles()
            subtitles.each do |s|
                htmlout = htmlout + "        <td class=\"tc_preview_subtitle\">\n"
                htmlout = htmlout + "        <strong>"+s+"</strong>\n"
                htmlout = htmlout + "        </td>\n"
            end
        end
        return htmlout
    end
    
    def renderHTMLStudySummary(studyrec,reportconfig)
        pub_author = studyrec.getAuthor()
        for ridx in 0..reportconfig.getNumPublicationItems() - 1
            if (reportconfig.getPublicationConfigName(ridx) == "authorfirstonly") &&
                (reportconfig.getPublicationConfigFlag(ridx) == 1)
                pub_author = studyrec.getFirstAuthor(pub_author)
            end
        end
        if pub_author.nil?
            pub_author = "-"
        end
        htmlout = ""
        htmlout = htmlout + "        <td class=\"tc_preview_study\">\n"
        for ridx in 0..reportconfig.getNumPublicationItems() - 1
            val = studyrec.getPublicationData(ridx)
            if val.nil?
                val = "null"
            end
            if reportconfig.getPublicationConfigName(ridx) == "authorfirstonly"
                # Skip
            else
                if reportconfig.showPublication(ridx)
                    if htmlout.size() > 0
                        if ridx > 4
                            htmlout = htmlout + ", "
                        else
                            htmlout = htmlout + "<br/>\n"
                        end
                    end
                    if reportconfig.getPublicationConfigName(ridx) == "author"
                        htmlout = htmlout + pub_author + "<br/>"
                    else
                        htmlout = htmlout + studyrec.getPublicationData(ridx) + "<br/>"
                    end
                end
            end
        end
        htmlout = htmlout + "\n"
        htmlout = htmlout + "        </td>\n"
        return htmlout
    end
    
    def isComplexTitle(title)
        if (title.start_with?("[") &&
            title.end_with?("]") &&
            (title.index("][") > 0))
            return true
        else
            return false
        end
    end
    
    # titles are encoded as <question> (simple single value) | [<question>][<field>] (array value) | [<question>][<row>][<column>] (matrix value)
    def getComplexTitleParts(title)
        # split the title by chars ][
        tparts = title.split("][")
        if tparts.size() > 1
            # need to get rid of the first and last characters
            v = tparts[0]
            tparts[0] = v[1..v.size() - 1]
            v = tparts[tparts.size() - 1]
            tparts[tparts.size() - 1] = v[0..v.size() - 2]
            return tparts
        end
        return tparts
    end
    
    def renderHTMLPreviewValue(section_data,section_config)
        htmlout = ""
        if section_config.displayThisSection()
            questions = section_config.getDisplayTitles()
            questions.each do |question|
                # titles are encoded as <question> (simple single value) | [<question>][<field>] (array value) | [<question>][<row>][<column>] (matrix value)
                question_parts = getComplexTitleParts(question)
                if (section_config.isRenderFlat() &&
                    (question_parts.size() > 1))
                    # This is a complex question - flatten
                    # use the question_parts[1 and 2] to derive the row and col index values
                    rownames = section_data.getQuestionRowNamesByName(question_parts[0])
                    colnames = section_data.getQuestionColNamesByName(question_parts[0])
                    ridx = rownames.index(question_parts[1])
                    if colnames.size() == 0
                        htmlout = htmlout + "        <td class=\"tc_preview_study\">\n"
                        htmlout = htmlout + "        Field value "+question_parts[0]+"/"+question_parts[1]+" ("+ridx.to_s+")"
                        htmlout = htmlout + "        </td>\n"
                    else
                        cidx = colnames.index(question_parts[2])
                        htmlout = htmlout + "        <td class=\"tc_preview_study\">\n"
                        htmlout = htmlout + "        "+section_data.getQuestionHTMLComplexValue(question_parts[0],ridx,cidx)
                        htmlout = htmlout + "        </td>\n"
                    end
                else
                    q_id = section_data.getQuestionIDByName(question_parts[0])
                    htmlout = htmlout + "        <td class=\"tc_preview_study\">\n"
                    htmlout = htmlout + "        "+section_data.getQuestionHTMLValue(question_parts[0])
                    htmlout = htmlout + "        </td>\n"
                end
            end
        end
        return htmlout
    end
    
    def renderHTMLPreviewValueByArms(arms_data,section_data,arms_config,section_config)
        htmlout = ""
        if arms_config.displayThisSection() &&
            section_config.displayThisSection()
            questions = section_config.getDisplayTitles()
            arms = arms_config.getDisplayTitles()
            questions.each do |question|
                # titles are encoded as <question> (simple single value) | [<arm>][<question>][<field>] (array value) | [<arm>][<question>][<row>][<column>] (matrix value)
                question_parts = getComplexTitleParts(question)
                if (section_config.isRenderFlat() &&
                    (question_parts.size() == 4))
                    # This is a complex question - flatten
                    # use the question_parts[1 and 2] to derive the row and col index values
                    arm_id = arms_data.getQuestionIDByName(question_parts[0])
                    rownames = section_data.getQuestionRowNamesByNameByArm(arm_id,question_parts[1])
                    colnames = section_data.getQuestionColNamesByNameByArm(arm_id,question_parts[1])
                    ridx = rownames.index(question_parts[2])
                    if colnames.size() == 0
                        htmlout = htmlout + "        <td class=\"tc_preview_study\">\n"
                        htmlout = htmlout + "        -"
                        htmlout = htmlout + "        </td>\n"
                    else
                        cidx = colnames.index(question_parts[3])
                        htmlout = htmlout + "        <td class=\"tc_preview_study\">\n"
                        htmlout = htmlout + "        "+section_data.getQuestionHTMLComplexValueByArm(arm_id,question_parts[1],ridx,cidx)
                        htmlout = htmlout + "        </td>\n"
                    end
                elsif (section_config.isRenderFlat() &&
                       (question_parts.size() == 3))
                    htmlout = htmlout + "        <td class=\"tc_preview_study\">\n"
                    htmlout = htmlout + "        Field Array #{rownames}"
                    htmlout = htmlout + "        </td>\n"
                elsif (question_parts.size() > 1)
                    arm_id = arms_data.getQuestionIDByName(question_parts[0])
                    htmlout = htmlout + "        <td class=\"tc_preview_study\">\n"
                    htmlout = htmlout + "        "+section_data.getQuestionHTMLValueByArm(arm_id,question_parts[1])
                    htmlout = htmlout + "        </td>\n"
                else
                    htmlout = htmlout + "        <td class=\"tc_preview_study\">\n"
                    htmlout = htmlout + "        <table>\n"
                    htmlout = htmlout + "            <tr>\n"
                    htmlout = htmlout + "                <td>\n"
                    htmlout = htmlout + "                <strong>Arm</strong>\n"
                    htmlout = htmlout + "                </td>\n"
                    htmlout = htmlout + "                <td>\n"
                    htmlout = htmlout + "                <strong>Value</strong>\n"
                    htmlout = htmlout + "                </td>\n"
                    htmlout = htmlout + "            </tr>\n"
                    arms.each do |arm|
                        arm_id = arms_data.getQuestionIDByName(arm)
                        htmlout = htmlout + "            <tr>\n"
                        htmlout = htmlout + "                <td>\n"
                        htmlout = htmlout + "                "+arm+"\n"
                        htmlout = htmlout + "                </td>\n"
                        htmlout = htmlout + "                <td>\n"
                        htmlout = htmlout + "                "+section_data.getQuestionHTMLValueByArm(arm_id,question)+"\n"
                        htmlout = htmlout + "                </td>\n"
                        htmlout = htmlout + "            </tr>\n"
                    end
                    htmlout = htmlout + "        </table>\n"
                    htmlout = htmlout + "        </td>\n"
                end    
                    
            end
        end
        return htmlout
    end
    
    def renderHTMLPreviewOutcomeValue(arms_data,sg_data,tp_data,meas_data,arms_config,outcomesgs_config,outcometpts_config,outcomemeas_config)
        htmlout = ""
        if section_config.displayThisSection()
            subtitles = section_config.getDisplayTitles()
            subtitles.each do |s|
                htmlout = htmlout + s + "<br\>"
            end
        end
        return htmlout
    end
    
    def renderHTMLPreviewOverallQuality(study_data)
        htmlout = ""
        htmlout = htmlout + "        <td class=\"tc_preview_study\">\n"
        htmlout = htmlout + "        "+study_data.getTotalQualityValue()+"<br/>\n"
        htmlout = htmlout + "        </td>\n"
        return htmlout
    end
    
end
