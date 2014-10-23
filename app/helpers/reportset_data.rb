class ReportsetData

    # ReportsetData is a base class that implements the core collection of SectionData objects for a set of studies
    
    def initialize
        puts "*********** ReportsetData::initialize"
        @section_name = "Generic"   # This must be set in the initialization() method of the child class
        @section_desc = "Generic"   # This must be set in the initialization() method of the child class
        @section_prefix = "na"      # This must be set in the initialization() method of the child class
        
        @dataset = Array.new
        @meta_names = Array.new     # Name and Desc list must match in length
        @meta_descs = Array.new     # Name and Desc list must match in length
        @meta_rownames = Hash.new   # Hash[<sectiondata idx>] = Array[names]
        @meta_colnames = Hash.new   # Hash[<sectiondata idx>] = Array[names]
    end
    
    # Getter/Setter Methods ----------------------------------------------------------------
    def setSectionName(name)
        @section_name = name
    end
    
    def getSectionName()
        return @section_name
    end
    
    def setSectionDescription(desc)
        @section_desc = desc
    end
    
    def getSectionDescription()
        return @section_desc
    end
    
    def setSectionPrefix(pref)
        @section_prefix = pref
    end
    
    def getSectionPrefix()
        return @section_prefix
    end
    
    # Data section loader method
    def add(sectiondata)
        # Check if this is the first section data loaded
        if getSectionPrefix().eql?("na")
            setSectionName(sectiondata.getSectionName());
            setSectionDescription(sectiondata.getSectionDescription());
            setSectionPrefix(sectiondata.getSectionPrefix());
        end
        
        if @dataset.nil?
            puts "reportset_data::add - nil @dataset"
        else
            puts "reportset_data::add - ok @dataset"
        end
        if sectiondata.nil?
            puts "reportset_data::add - nil sectiondata"
        else
            puts "reportset_data::add - ok sectiondata"
        end
        @dataset << sectiondata
        
        if sectiondata.getNumQuestions() > 0
            for idx in 0..sectiondata.getNumQuestions() - 1
                name = sectiondata.getQuestionName(idx)
                desc = sectiondata.getQuestionDesc(idx)
                if !@meta_names.include?(name)
                    @meta_names << name
                    @meta_descs << desc
                end
                
                qfrows = sectiondata.getQuestionRowNames(idx)
                if !qfrows.nil? && (qfrows.size() > 0)
                    if @meta_rownames[idx.to_s].nil?
                        @meta_rownames[idx.to_s] = qfrows
                    else
                        qfrows.each do |name|
                            if !@meta_rownames[idx.to_s].include?(name)
                                @meta_rownames[idx.to_s] << name
                            end
                        end
                    end
                end
                
                qfcols = sectiondata.getQuestionColNames(idx)
                if !qfcols.nil? && (qfcols.size() > 0)
                    if @meta_colnames[idx.to_s].nil?
                        @meta_colnames[idx.to_s] = qfcols
                    else
                        qfcols.each do |name|
                            if !@meta_colnames[idx.to_s].include?(name)
                                @meta_colnames[idx.to_s] << name
                            end
                        end
                    end
                end
                
            end
        end
    end
        
    # SectionData access methods ------------------------------------------------------------------------
    def getNumDistinctQuestions()
        return @meta_names.size()
    end
    
    def getDistinctQuestionName(idx)
        return @meta_names[idx]
    end
    
    def getDistinctQuestionDesc(idx)
        return @meta_descs[idx]
    end
    
    def getQuestionName(sidx,qidx)
        return @dataset[sidx].getQuestionName(qidx)
    end
    
    def getQuestionID(sidx,qidx)
        return @dataset[sidx].getQuestionID(qidx)
    end
    
    def getQuestionIDByName(sidx,name)
        return @dataset[sidx].getQuestionIDByName(name)
    end
    
    def isQuestionComplex(sidx,q_id)
        return @dataset[sidx].isQuestionComplexbyArm(q_id)
    end
    
    def getNumQuestionRows(idx)
        rownames = getQuestionRowNames(idx)
        if rownames.nil?
            return 0
        else
            return rownames.size()
        end
    end
    
    def getQuestionRowNames(idx)
        return @meta_rownames[idx.to_s]
    end
    
    def getQuestionRowNamesByID(sidx,q_id)
        return @dataset[sidx].getQuestionRowNamesByID(q_id)
    end
    
    def getNumQuestionCols(idx)
        colnames = getQuestionColNames(idx)
        if colnames.nil?
            return 0
        else
            return colnames.size()
        end
    end
    
    def getQuestionColNames(idx)
        return @meta_colnames[idx.to_s]
    end
    
    def getQuestionColNamesByID(sidx,q_id)
        return @dataset[sidx].getQuestionColNamesByID(q_id)
    end
    
    def getQuestionsTableHeader(show_arm_names)
        header_list = Array.new
        for i in 0..show_arm_names.size() - 1
            header_list << show_arm_names[i]
        end
        return header_list
    end
    
    def getQuestionsTableContent(idx,show_arm_names)
        data_list = Array.new
        for i in 0..show_arm_names.size() - 1
            # TODO - 
        end
        return data_list
    end
    
    def getQuestionValue(idx,q_id)
        return @dataset[idx].getQuestionValue(q_id)
    end
    
    def getQuestionFieldValue(idx,q_id,armdfidx)
        return @dataset[idx].getQuestionFieldValue(q_id,row_idx)
    end
    
    def getQuestionMatrixValue(sidx,q_id,row_idx,col_idx)
        return @dataset[sidx].getQuestionMatrixValue(q_id,row_idx,col_idx)
    end
    
    # Question EXCEL Methods ------------------------------------------------------------------------
    def getQuestionEXCELSpan(q_name)
        col_span = 0
        for sidx in 0..size() - 1
            study_colspan = @dataset[sidx].getQuestionColSpan(q_name)
            if study_colspan > col_span
                col_span = study_colspan
            end
        end
        return col_span
    end
    
    def getQuestionEXCELLabels(q_name)
        # All studies have the same set of Question labels for the same question
        return @dataset[0].getQuestionEXCELLabels(q_name)
    end
    
    def getQuestionEXCELValues(sidx,q_name)
        return @dataset[sidx].getDesignDetailEXCELValues(q_name)
    end
end
