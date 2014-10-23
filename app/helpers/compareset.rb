class Compareset

    # Compareset is implemented as simple Array of Studydata classes. Studydata is a container - Hash map of data associated with a study
    # for a given study id and extraction form id
    def initialize
        @project = nil
        @studies = []
        # Define master list of field names across all studies added and references <name>:<study id>:<field index>
        @armdetails_names = Array.new
        @designdetails_names = Array.new
        @baseline_names = Array.new
        @outcomesdata_names = Array.new     # unique list of outcome result names across all studies in this comparason set
        @outcomesdata_timepts = Array.new   # unique list of outcome result timepoints across all studies in this comparason set
        @outcomesdata_meas = Array.new      # unique list of outcome result measure names across all studies in this comparason set
        @outcomesdata_arms = Array.new      # unique list of outcome result arms across all studies in this comparason set
        @outdetails_names = Array.new
        @arms_names = Array.new             # unique list of arm names across all studies in this comparason set
        @arms_ids = Array.new               # unique list of corresponding arm ids to the arms_names across all studies in this comparason set
        @adverseevents_names = Array.new
        @quality_names = Array.new
    end
    
    def add(project_id,study_id,extraction_form_id)
        puts ">>>>>>>>>>>> Compareset - add sid "+study_id.to_s+" efid "+extraction_form_id.to_s
        if @project.nil?
            @project = Project.find(project_id)
        end
        
        studyrec = Studydata.new
        studyrec.load(project_id,study_id,extraction_form_id)
        
        if (studyrec.getNumArms() > 0) && (studyrec.getNumArmDetails() > 0)
            for idx in 0..studyrec.getNumArmDetails() - 1
                name = studyrec.getArmDetailName(idx)
                if !@armdetails_names.include?(name)
                    @armdetails_names << name
                end
            end
        end
        
        if studyrec.getNumDesignDetails() > 0
            for idx in 0..studyrec.getNumDesignDetails() - 1
                name = studyrec.getDesignDetailName(idx)
                if !@designdetails_names.include?(name)
                    @designdetails_names << name
                end
            end
        end
        
        # Iterate through the arms to get at all unique baseline characteristic names
        if (studyrec.getNumArms() > 0) && (studyrec.getNumBaselines() > 0)
            for idx in 0..studyrec.getNumBaselines() - 1
                name = studyrec.getBaselineName(idx)
                if !@baseline_names.include?(name)
                    @baseline_names << name
                end
            end
        end
        
        # Outcome Results ---------------------------------------------------------------------------
        if studyrec.getNumOutcomes() > 0
            for idx in 0..studyrec.getNumOutcomes() - 1
                name = studyrec.getOutcomeName(idx)
                puts ".............. loading study ("+study_id.to_s+") outcome name ("+idx.to_s+") "+name+" size before "+@outcomesdata_names.size().to_s
                if !@outcomesdata_names.include?(name)
                    @outcomesdata_names << name
                    puts ".............. loading study ("+study_id.to_s+") added outcome name ("+idx.to_s+") "+name+" size "+@outcomesdata_names.size().to_s
                end
            end
        end
        if studyrec.getNumOutcomeTimePoints() > 0
            for idx in 0..studyrec.getNumOutcomeTimePoints() - 1
                name = studyrec.getOutcomeTimePoint(idx)
                if !@outcomesdata_timepts.include?(name)
                    @outcomesdata_timepts << name
                end
            end
        end
        if studyrec.getNumOutcomeMeasures() > 0
            for idx in 0..studyrec.getNumOutcomeMeasures() - 1
                name = studyrec.getOutcomeMeasure(idx)
                if !@outcomesdata_meas.include?(name)
                    @outcomesdata_meas << name
                end
            end
        end
        if studyrec.getNumArms() > 0
            for idx in 0..studyrec.getNumArms() - 1
                name = studyrec.getArmName(idx)
                if !@outcomesdata_arms.include?(name)
                    @outcomesdata_arms << name
                end
            end
        end
        
        if studyrec.getNumOutcomeDetails() > 0
            for idx in 0..studyrec.getNumOutcomeDetails() - 1
                name = studyrec.getOutcomeDetailName(idx)
                if !@outdetails_names.include?(name)
                    @outdetails_names << name
                end
            end
        end
        
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
        
        if studyrec.getNumAdverseEvents() > 0
            for idx in 0..studyrec.getNumAdverseEvents() - 1
                name = studyrec.getAdverseEventsName(idx)
                if !@adverseevents_names.include?(name)
                    @adverseevents_names << name
                end
            end
        end
        if studyrec.getNumQualityDim() > 0
            for idx in 0..studyrec.getNumQualityDim() - 1
                name = studyrec.getQualityDimName(idx)
                if !@quality_names.include?(name)
                    @quality_names << name
                end
            end
        end 
        @studies << studyrec
    end
    
    def remove(study_id,extraction_form_id)
    end
    
    def get(idx)
        return @studies[idx]    
    end
    
    def size
        return @studies.size()    
    end
    
    def getProjectID()
        return @project.id
    end
    
    def getProjectTitle()
        return @project.title
    end
    
    def sameEFIDs()
        # Scan the loaded studies to see if they all reference the same extraction form - consistency flag
        efids = Array.new
        @studies.each do |study|
            if !efids.include?(study.getExtractionFormID().to_s)
                efids << study.getExtractionFormID().to_s
            end
        end
        return (efids.size() == 1)
    end
    
    # Publication ----------------------------------------------------------------
    def getNumStudies()
        return @studies.size()
    end
    
    def getStudyID(sidx)
        return @studies[sidx].getStudyID()
    end
    
    def getStudyTitle(sidx)
        return @studies[sidx].getTitle()
    end
    
    def getExtractionFormID(sidx)
        return @studies[sidx].getExtractionFormID()
    end
    
    def getTitle(sidx)
        return @studies[sidx].getTitle()
    end
    
    def distinctTitle()
        diffvalues = Array.new
        for studyidx in (0.. @studies.size() - 1)
            val = getTitle(studyidx)
            if val.nil?
                val = "pubtitle.nil"
            end
            if !diffvalues.include?(val.to_s)
                diffvalues << val.to_s
            end
        end
        return diffvalues.size()
    end
    
    def getYear(sidx)
        return @studies[sidx].getYear()
    end
    
    def distinctYear()
        diffvalues = Array.new
        for studyidx in (0.. @studies.size() - 1)
            val = getYear(studyidx)
            if val.nil?
                val = "pubyear.nil"
            end
            if !diffvalues.include?(val.to_s)
                diffvalues << val.to_s
            end
        end
        return diffvalues.size()
    end
    
    def getAuthor(sidx)
        return @studies[sidx].getAuthor()
    end
    
    def distinctAuthor()
        diffvalues = Array.new
        for studyidx in (0.. @studies.size() - 1)
            val = getAuthor(studyidx)
            if val.nil?
                val = "pubauthor.nil"
            end
            if !diffvalues.include?(val.to_s)
                diffvalues << val.to_s
            end
        end
        return diffvalues.size()
    end
    
    def getCountry(sidx)
        return @studies[sidx].getCountry()
    end
    
    def distinctCountry()
        diffvalues = Array.new
        for studyidx in (0.. @studies.size() - 1)
            val = getCountry(studyidx)
            if val.nil?
                val = "pubcountry.nil"
            end
            if !diffvalues.include?(val.to_s)
                diffvalues << val.to_s
            end
        end
        return diffvalues.size()
    end
    
    def getPMID(sidx)
        return @studies[sidx].getPMID()
    end
    
    def distinctPMID()
        diffvalues = Array.new
        for studyidx in (0.. @studies.size() - 1)
            val = getPMID(studyidx)
            if val.nil?
                val = "pubpmid.nil"
            end
            if !diffvalues.include?(val.to_s)
                diffvalues << val.to_s
            end
        end
        return diffvalues.size()
    end
    
    def getAlternateNumbers(sidx)
        return @studies[sidx].getAlternateNumbers()
    end
    
    def distinctAlternateNumbers()
        diffvalues = Array.new
        for studyidx in (0.. @studies.size() - 1)
            val = getAlternateNumbers(studyidx)
            if val.nil?
                val = "pubaltid.nil"
            end
            if !diffvalues.include?(val.to_s)
                diffvalues << val.to_s
            end
        end
        return diffvalues.size()
    end
    
    def getJournal(sidx)
        return @studies[sidx].getJournal()
    end
    
    def distinctJournal()
        diffvalues = Array.new
        for studyidx in (0.. @studies.size() - 1)
            val = getJournal(studyidx)
            if val.nil?
                val = "pubjournal.nil"
            end
            if !diffvalues.include?(val.to_s)
                diffvalues << val.to_s
            end
        end
        return diffvalues.size()
    end
    
    def getVolume(sidx)
        return @studies[sidx].getVolume()
    end
    
    def distinctVolume()
        diffvalues = Array.new
        for studyidx in (0.. @studies.size() - 1)
            val = getVolume(studyidx)
            if val.nil?
                val = "pubvolume.nil"
            end
            if !diffvalues.include?(val.to_s)
                diffvalues << val.to_s
            end
        end
        return diffvalues.size()
    end
    
    def getIssue(sidx)
        return @studies[sidx].getIssue()
    end
    
    def distinctIssue()
        diffvalues = Array.new
        for studyidx in (0.. @studies.size() - 1)
            val = getIssue(studyidx)
            if val.nil?
                val = "pubissue.nil"
            end
            if !diffvalues.include?(val.to_s)
                diffvalues << val.to_s
            end
        end
        return diffvalues.size()
    end
    
    def getCreatorID(sidx)
        return @studies[sidx].getCreatorID()
    end
    
    # Generalized Methods ----------------------------------------------------------------
    # section name and code identifies the section to be rendered by Arm
    # the section code is passed to the other generalized methods in compareset used to invoke the associated methods
    # section name/code are
    # Baseline/BL
    # ArmDetail/armd
    def isComplexByArm(section_name, sidx, arm_id, f_id)
        if section_name == "Baseline"
            return @studies[sidx].isBaselineComplex(arm_id,f_id)
        elsif section_name == "ArmDetail"
            return @studies[sidx].isArmDetailComplex(arm_id,f_id)
        else
            return false
        end
    end
    
    def isComplex(section_name, sidx, f_id)
        if section_name == "DesignDetail"
            return @studies[sidx].isDesignDetailComplex(f_id)
        elsif section_name == "OutcomeDetail"
            return @studies[sidx].isOutcomeDetailComplex(f_id)
        else
            return false
        end
    end
    
    # Arm Details ----------------------------------------------------------------
    def getNumDistinctArmDetails()
        return @armdetails_names.size()
    end
    
    def getNumArmDetails(sidx)
        return @studies[sidx].getNumArmDetails()
    end
    
    def containsArmDetail(sidx,name)
        return @studies[sidx].containsArmDetail(name)
    end
    
    def getArmDetailName(idx)
        return @armdetails_names[idx]
    end
    
    def getArmDetailIDByStudy(sidx,idx)
        return @studies[sidx].getArmDetailID(idx)
    end
    
    def getArmDetailIDByName(sidx,name)
        return @studies[sidx].getArmDetailIDByName(name)
    end
    
    def getArmDetailNameByStudy(sidx,idx)
        return @studies[sidx].getArmDetailName(idx)
    end
    
    def getArmDetailValue(sidx,arm_id,armd_id)
        return @studies[sidx].getArmDetailValue(arm_id,armd_id)
    end
    
    def isArmDetailComplex(sidx, arm_id, armd_id)
        return @studies[sidx].isArmDetailComplex(arm_id,armd_id)
    end
    
    def getArmDetailRowNamesByID(sidx,arm_id,armd_id)
        return @studies[sidx].getArmDetailRowNamesByID(arm_id,armd_id)
    end
    
    def getArmDetailColNamesByID(sidx,arm_id,armd_id)
        return @studies[sidx].getArmDetailColNamesByID(arm_id,armd_id)
    end
    
    def getArmDetailMatrixValue(sidx,arm_id,armd_id,row_idx,col_idx)
        return @studies[sidx].getArmDetailMatrixValue(arm_id,armd_id,row_idx,col_idx)
    end
    
    def distinctArmDetail(name)
        diffvalues = Array.new
        for studyidx in (0.. @studies.size() - 1)
            val = getArmDetailValue(studyidx,name)
            if val.nil?
                val = "ddvalue.nil"
            end
            if !diffvalues.include?(val.to_s)
                diffvalues << val.to_s
            end
        end
        return diffvalues.size()
    end
    
    def differentArmDetails(arm_name,armd_name)
        diffvalues = Array.new
        for sidx in 0.. @studies.size() - 1
            if containsArmName(sidx,arm_name) && 
                containsArmDetail(sidx,armd_name)
                arm_id = getArmIDByName(sidx,arm_name)
                armd_id = getArmDetailIDByName(sidx,armd_name)
                # Load reference set of values - code S-<value> for single data types or M-<row>-<col>-<value> for matrix data types
                if isArmDetailComplex(sidx,arm_id,armd_id)
                    rownames = getArmDetailRowNamesByID(sidx,arm_id,armd_id)
                    colnames = getArmDetailColNamesByID(sidx,arm_id,armd_id)
                    for row_idx in 0..rownames.size() - 1
                        for col_idx in 0..colnames.size() - 1
                            val = getArmDetailMatrixValue(sidx,arm_id,armd_id,row_idx,col_idx);
                            if !val.nil? && !diffvalues.include?("M-"+row_idx.to_s+"-"+col_idx.to_s+"-"+val.to_s)
                                diffvalues << "M-"+row_idx.to_s+"-"+col_idx.to_s+"-"+val.to_s
                            end
                        end
                    end
                else
                    val = getArmDetailValue(sidx,arm_id,armd_id)
                    if !val.nil? && !diffvalues.include?("S-"+val.to_s)
                        diffvalues << "S-"+val.to_s
                    end
                end    
            end    
        end
        return diffvalues.size() > 1
    end
    
    # Design Details ----------------------------------------------------------------
    def getNumDistinctDesignDetails()
        return @designdetails_names.size()
    end
    
    def getNumDesignDetails(sidx)
        return @studies[sidx].getNumDesignDetails()
    end
    
    def getDesignDetailName(idx)
        return @designdetails_names[idx]
    end
    
    def getDesignDetailIDByStudy(sidx,idx)
        return @studies[sidx].getDesignDetailID(idx)
    end
    
    def getDesignDetailNameByStudy(sidx,idx)
        return @studies[sidx].getDesignDetailName(idx)
    end
    
    def getDesignDetailValue(sidx,name)
        return @studies[sidx].getDesignDetailValue(name)
    end
    
    def distinctDesignDetail(name)
        diffvalues = Array.new
        for studyidx in (0.. @studies.size() - 1)
            val = getDesignDetailValue(studyidx,name)
            if val.nil?
                val = "ddvalue.nil"
            end
            if !diffvalues.include?(val.to_s)
                diffvalues << val.to_s
            end
        end
        return diffvalues.size()
    end
    
    # Baseline Characteristics ----------------------------------------------------------------
    def getNumDistinctBaseline()
        return @baseline_names.size()
    end
    
    def getNumBaseline(sidx)
        return @studies[sidx].getNumBaseline()
    end
    
    def containsBaseline(sidx,name)
        return @studies[sidx].containsBaseline(name)
    end
    
    def getBaselineName(idx)
        return @baseline_names[idx]
    end
    
    def getBaselineIDByName(sidx,bl)
        return @studies[sidx].getBaselineIDByName(bl)
    end
    
    def getBaselineNameByStudy(sidx,idx)
        return @studies[sidx].getBaselineName(idx)
    end
    
    def getNumBaselineCols(sidx,arm_id,bl_id)
        return @studies[sidx].getNumBaselineCols(arm_id,bl_id)
    end
    
    def getBaselineColName(sidx,arm_id,bl_id,cfidx)
        return @studies[sidx].getBaselineColName(arm_id,bl_id,cfidx)
    end
    
    def getBaselineColNamesByID(sidx,arm_id,bl_id)
        return @studies[sidx].getBaselineColNamesByID(arm_id,bl_id)
    end
    
    def getNumBaselineRows(sidx,arm_id,bl_id)
        return @studies[sidx].getNumBaselineRows(arm_id,bl_id)
    end
    
    def getBaselineRowName(sidx,arm_id,bl_id,rfidx)
        return @studies[sidx].getBaselineRowName(arm_id,bl_id,rfidx)
    end
    
    def getBaselineRowNamesByID(sidx,arm_id,bl_id)
        return @studies[sidx].getBaselineRowNamesByID(arm_id,bl_id)
    end
    
    def getBaselineValue(sidx,arm_id,bl_id)
        return @studies[sidx].getBaselineValue(arm_id,bl_id)
    end
    
    def getBaselineTotalValue(sidx,name)
        return @studies[sidx].getBaselineValue(name,"total")
    end
    
    def isBaselineComplex(sidx, arm_id, bl_id)
        return @studies[sidx].isBaselineComplex(arm_id,bl_id)
    end
    
    def distinctBaseline(name,armid)
        diffvalues = Array.new
        for studyidx in (0.. @studies.size() - 1)
            val = getBaselineValue(studyidx,name,armid)
            if val.nil?
                val = "blvalue.nil"
            end
            if !diffvalues.include?(val.to_s)
                diffvalues << val.to_s
            end
        end
        return diffvalues.size()
    end
    
    def distinctBaselineTotal(name)
        diffvalues = Array.new
        for studyidx in (0.. @studies.size() - 1)
            val = getBaselineTotalValue(studyidx,name)
            if val.nil?
                val = "bltotal.nil"
            end
            if !diffvalues.include?(val.to_s)
                diffvalues << val.to_s
            end
        end
        return diffvalues.size()
    end
    
    def isBaselineComplexValue(sidx,arm,bl)
        # Look up both baseline and arm IDs based on its name
        arm_id = getArmIDByName(sidx,arm)
        bl_id = getBaselineIDByName(sidx,bl)
        return @studies[sidx].isBaselineComplex(arm_id,bl_id)
    end
    
    def containsBaselineValue(sidx,arm,bl)
        # Look up both baseline and arm IDs based on its name
        arm_id = getArmIDByName(sidx,arm)
        bl_id = getBaselineIDByName(sidx,bl)
        if isBaselineComplexValue(sidx,arm,bl)
            # Count number of cells in the matrix with a valid value
            n_values_count = 0
            for rfidx in 0..@studies[sidx].getNumBaselineRows(arm_id,bl_id) - 1
                for cfidx in 0..@studies[sidx].getNumBaselineCols(arm_id,bl_id) - 1
                    if containsBaselineMatrixValue(sidx,arm_id,bl_id,rfidx,cfidx)
                        n_values_count = n_values_count + 1
                    end
                end
            end
            return (n_values_count > 0)
        else
            return @studies[sidx].containsBaselineValue(arm_id,bl_id)
        end
    end
    
    def containsBaselineMatrixValue(sidx,arm_id,bl_id,rfidx,cfidx)
        return @studies[sidx].containsBaselineMatrixValue(arm_id,bl_id,rfidx,cfidx)
    end
    
    def sameBaselineType(arm,bl)
        # Check to see if the referenced baseline characteristic is the same data type across all studies being compared
        # Count how many different data types and see if it is 1 (same) > 1 (different data types)
        datatypes = Array.new
        for sidx in 0..@studies.size - 1
            arm_id = getArmIDByName(sidx,arm)
            bl_id = getBaselineIDByName(sidx,bl)
            sdatatype = @studies[sidx].getBaselineDataTypeName(arm_id,bl_id)
            if datatypes.include?(sdatatype)
                datatypes << sdatatype
            end
            if datatypes.size > 1
                return false
            end
        end
        return true
    end
    
    def getBaselineValue(sidx,arm,bl)
        arm_id = getArmIDByName(sidx,arm)
        bl_id = getBaselineIDByName(sidx,bl)
        return @studies[sidx].getBaselineValue(arm_id,bl_id)
    end
    
    def getBaselineMatrixValue(sidx,arm,bl,rfidx,cfidx)
        arm_id = getArmIDByName(sidx,arm)
        bl_id = getBaselineIDByName(sidx,bl)
        return @studies[sidx].getBaselineMatrixValue(arm_id,bl_id,rfidx,cfidx)
    end
    
    def differentBaselines(arm_name,bl_name)
        diffvalues = Array.new
        for sidx in 0.. @studies.size() - 1
            if containsArmName(sidx,arm_name) && 
                containsBaseline(sidx,bl_name)
                arm_id = getArmIDByName(sidx,arm_name)
                bl_id = getBaselineIDByName(sidx,bl_name)
                # Load reference set of values - code S-<value> for single data types or M-<row>-<col>-<value> for matrix data types
                if isBaselineComplex(sidx,arm_id,bl_id)
                    rownames = getBaselineRowNamesByID(sidx,arm_id,bl_id)
                    colnames = getBaselineColNamesByID(sidx,arm_id,bl_id)
                    for row_idx in 0..rownames.size() - 1
                        for col_idx in 0..colnames.size() - 1
                            val = getBaselineMatrixValue(sidx,arm_id,bl_id,row_idx,col_idx);
                            if !val.nil? && !diffvalues.include?("M-"+row_idx.to_s+"-"+col_idx.to_s+"-"+val.to_s)
                                diffvalues << "M-"+row_idx.to_s+"-"+col_idx.to_s+"-"+val.to_s
                            end
                        end
                    end
                else
                    val = getBaselineValue(sidx,arm_id,bl_id)
                    if !val.nil? && !diffvalues.include?("S-"+val.to_s)
                        diffvalues << "S-"+val.to_s
                    end
                end    
            end    
        end
        return diffvalues.size() > 1
    end
    
    # Arms ----------------------------------------------------------------
    def getNumDistinctArms()
        return @arms_names.size()
    end
    
    def containsArmName(sidx,name)
        return @studies[sidx].containsArm(name)
    end
    
    def containsSameArm(name)
        ncontains = 0
        for i in 0..@studies.size() - 1
            if containsArmName(i,name)
                ncontains = ncontains + 1
            end
        end
        return (ncontains == @studies.size())
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
    
    # Outcomes ----------------------------------------------------------------
    def getNumDistinctOutcomes()
        return @outcomesdata_names.size()
    end
    
    def getNumDistinctOutcomeTimePoints()
        return @outcomesdata_timepts.size()
    end
    
    def getNumDistinctOutcomeMeasures()
        return @outcomesdata_meas.size()
    end
    
    def getNumDistinctOutcomeArms()
        return @outcomesdata_arms.size()
    end
    
    def getNumOutcomes(sidx)
        return @studies[sidx].getNumOutcomes()
    end
    
    def getNumOutcomeTimePoints(sidx)
        return @studies[sidx].getNumOutcomeTimePoints()
    end
    
    def getNumOutcomeMeasures(sidx)
        return @studies[sidx].getNumOutcomeMeasures()
    end
    
    def getNumOutcomeArms(sidx)
        return @studies[sidx].getNumOutcomeArms()
    end
    
    def getOutcomeName(sidx,idx)
        return @studies[sidx].getOutcomeName(idx)
    end
    
    def getOutcomeTimePoint(sidx,idx)
        return @studies[sidx].getOutcomeTimePoint(idx)
    end
    
    def getOutcomeMeasure(sidx,idx)
        return @studies[sidx].getOutcomeMeasure(idx)
    end
    
    def getOutcomeArm(sidx,idx)
        return @studies[sidx].getOutcomeArm(idx)
    end
    
    def distinctOutcomes(name,timept,meas,arm)
        diffvalues = Array.new
        for studyidx in (0.. @studies.size() - 1)
            val = getOutcomesValue(studyidx,name,timept,meas,arm)
            if val.nil?
                val = "outcomesval.nil"
            end
            if !diffvalues.include?(val.to_s)
                diffvalues << val.to_s
            end
        end
        return diffvalues.size()
    end
    
    def hasOutcomeValues(name,timept,meas,arm)
        nvalues = 0
        for studyidx in (0.. @studies.size() - 1)
            val = getOutcomesValue(studyidx,name,timept,meas,arm)
            if !val.nil?
                nvalues = nvalues + 1
            end
        end
        return (nvalues > 0)
    end
    
    def getOutcomesValue(sidx,name,timept,meas,arm)
        return @studies[sidx].getOutcomesValue(name,"needs sg",timept,meas,arm)
    end
    
    def getOutcomeName(idx)
        return @outcomesdata_names[idx]
    end
    
    def getOutcomeResultsTimePoints(idx)
        return @outcomesdata_timepts[idx]
    end
    
    def getOutcomeResultsMeasure(idx)
        return @outcomesdata_meas[idx]
    end
    
    def getOutcomeResultsArm(idx)
        if idx >= @outcomesdata_arms.size()
            return "total"
        else
            return @outcomesdata_arms[idx]
        end
    end
    
    # Outcomes ----------------------------------------------------------------------
    def containsOutcomeName(sidx,name)
        return @studies[sidx].containsOutcomeName(name)
    end
    
    def containsSameOutcome(name)
        ncontains = 0
        for i in 0..@studies.size() - 1
            if containsOutcomeName(i,name)
                ncontains = ncontains + 1
            end
        end
        return (ncontains == @studies.size())
    end
    
    # Outcome Details ----------------------------------------------------------------
    def getNumDistinctOutcomeDetails()
        return @outdetails_names.size()
    end
    
    def getNumOutcomeDetails(sidx)
        return @studies[sidx].getNumOutcomeDetails()
    end
    
    def getOutcomeDetailName(idx)
        return @outdetails_names[idx]
    end
    
    def getOutcomeDetailIDByStudy(sidx,idx)
        return @studies[sidx].getOutcomeDetailID(idx)
    end
    
    def getOutcomeDetailNameByStudy(sidx,idx)
        return @studies[sidx].getOutcomeDetailName(idx)
    end
    
    def getOutcomeDetailValue(sidx,name)
        return @studies[sidx].getOutcomeDetailValue(name)
    end
    
    def distinctOutcomeDetail(name)
        diffvalues = Array.new
        for studyidx in (0.. @studies.size() - 1)
            val = getOutcomeDetailValue(studyidx,name)
            if val.nil?
                val = "ddvalue.nil"
            end
            if !diffvalues.include?(val.to_s)
                diffvalues << val.to_s
            end
        end
        return diffvalues.size()
    end
    
    # Adverse Events ----------------------------------------------------------------
    def getNumDistinctAdverseEvents()
        return @adverseevents_names.size()
    end
    
    def getNumAdverseEvents(sidx)
        return @studies[sidx].getNumAdverseEvents()
    end
    
    def getAdverseEventsName(idx)
        return @adverseevents_names[idx]
    end
    
    def getAdverseEventsIDByStudy(sidx,idx)
        return @studies[sidx].getAdverseEventsID(idx)
    end
    
    def getAdverseEventsNameByStudy(sidx,idx)
        return @studies[sidx].getAdverseEventsName(idx)
    end
    
    def getAdverseEventColumnIDByStudy(sidx,idx)
        return @studies[sidx].getAdverseEventColumnID(idx)
    end
    
    def getAdverseEventColumnNameByStudy(sidx,idx)
        return @studies[sidx].getAdverseEventColumnName(idx)
    end
    
    def getAdverseEventColumnDescriptionByStudy(sidx,idx)
        return @studies[sidx].getAdverseEventColumnDescription(idx)
    end
    
    def getAdverseEventResultIDByStudy(sidx,idx)
        return @studies[sidx].getAdverseEventResultID(idx)
    end
    
    def getAdverseEventsValue(sidx,name,armid)
        return @studies[sidx].getAdverseEventsValue(name,armid)
    end
    
    def getAdverseEventsTotalValue(sidx,name)
        return @studies[sidx].getAdverseEventsValue(name,"total")
    end
    
    def distinctAdverseEvents(name,armid)
        diffvalues = Array.new
        for studyidx in (0.. @studies.size() - 1)
            val = getAdverseEventsValue(studyidx,name,armid)
            if val.nil?
                val = "advevalue.nil"
            end
            if !diffvalues.include?(val.to_s)
                diffvalues << val.to_s
            end
        end
        return diffvalues.size()
    end
    
    def distinctAdverseEventsTotal(name)
        diffvalues = Array.new
        for studyidx in (0.. @studies.size() - 1)
            val = getAdverseEventsTotalValue(studyidx,name)
            if val.nil?
                val = "advetotal.nil"
            end
            if !diffvalues.include?(val.to_s)
                diffvalues << val.to_s
            end
        end
        return diffvalues.size()
    end
    
    # Quality Dimensions ----------------------------------------------------------------
    def getNumDistinctQualityDim()
        return @quality_names.size()
    end
    
    def getNumQualityDim(sidx)
        return @studies[sidx].getNumQualityDim()
    end
    
    def getQualityDimName(idx)
        return @quality_names[idx]
    end
    
    def getQualityDimIDByStudy(sidx,idx)
        return @studies[sidx].getQualityDimID(idx)
    end
    
    def getQualityDimNameByStudy(sidx,idx)
        return @studies[sidx].getQualityDimName(idx)
    end
    
    def getQualityDimValue(sidx,name)
        return @studies[sidx].getQualityDimValue(name)
    end
    
    def distinctQualityDim(name)
        diffvalues = Array.new
        for studyidx in (0.. @studies.size() - 1)
            val = getQualityDimValue(studyidx,name)
            if val.nil?
                val = "qualdimvalue.nil"
            end
            if !diffvalues.include?(val.to_s)
                diffvalues << val.to_s
            end
        end
        return diffvalues.size()
    end
    
    # Total Quality Ratings ----------------------------------------------------------------
    def getTotalQualityValue(sidx)
        return @studies[sidx].getTotalQualityValue()
    end
    
    def distinctTotalQuality()
        diffvalues = Array.new
        for studyidx in (0.. @studies.size() - 1)
            val = getTotalQualityValue(studyidx)
            if val.nil?
                val = "qualdimtotal.nil"
            end
            if !diffvalues.include?(val.to_s)
                diffvalues << val.to_s
            end
        end
        return diffvalues.size()
    end
end
