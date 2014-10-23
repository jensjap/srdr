class SectionByArmsData < SectionData
    # SectionByArmData adds Arms and supports references by Arm IDs
    
    def initialize
        super()
        @arms = nil                 # Allows a set of arms names to be defined
        @arm_ids = nil              # Allows a set of arms ids to be defined
    end
   
    # Override base class loadYMLFile
    def loadYAMLFile(project_id,study_id,extraction_form_id,cachefname)
        cachestudy = YAML.load_file(cachefname)
        loadYAML(project_id,study_id,extraction_form_id,cachestudy)
    end
        
    def loadYAML(project_id,study_id,extraction_form_id,cachestudy)
        # This method must be implemented by the child class
        # Study Arms ---------------------------------------------------
        # Load arms data
        setArms(cachestudy["arms_names"])
        setArmIDs(cachestudy["arms_ids"])
        
        loadYAMLQuestionData(cachestudy,project_id,study_id,extraction_form_id)
    end
    
    def loadDb(project_id,study_id,extraction_form_id)
    end
    
    # Override parent buildQuestionMap method to include arm id
    def buildQuestionMap()
        # Convert other size fields from string to int data type - keep it in sync with database load method and results
        if getNumQuestions() > 0
            for qidx in 0..getNumQuestions() - 1
                q_id = getQuestionID(qidx)
                @arm_ids.each do |arm_id|
                    if !@question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+".size"].nil?
                        @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+".size"] = @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+".size"].to_i
                    end
                    if !@question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+".size"].nil?
                        @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+".size"] = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+".size"].to_i
                    end
                
                    # Build hash map of question objects
                    if isQuestionComplex(q_id)
                    else
                        @questions[q_id.to_s] = buildSimpleQuestionByArm(q_id,arm_id,@question_data)
                    end
                end
            end
        end
    end
    
    def buildSimpleQuestionByArm(qid,armid,data)
        q = SimpleQuestionByArm.new
        q.setID(qid)
        q.setArmID(armid)
        q.setPrefix(getSectionPrefix())
        q.setName(getQuestionNameByID(qid))
        q.setDescription(getQuestionDescByID(qid))
        if data[q.getYAMLID()].nil?
            q.setValue(data[q.getYAMLID()])
        end
        return q
    end
    
    # Getter/Setter Methods ----------------------------------------------------------------
    def setArms(arms)
        @arms = arms
    end
    
    def getArms()
        return @arms
    end
    
    def setArmIDs(arm_ids)
        @arm_ids = arm_ids
    end
    
    def getArmIDs()
        return @arm_ids
    end
    
    def getArmName(idx)
        return @arms[idx]
    end
    
    def getArmID(idx)
        return @arm_ids[idx].to_i
    end
    
    # Generalized Methods ----------------------------------------------------------------
    # Data access method
    def getNumQuestionRowsByArm(arm_id,q_id)
        nrows = @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+".size"]
        if !nrows.nil?
            return nrows.to_i
        else
            return 1
        end
    end
    
    def getQuestionRowNamesByNameByArm(arm_id,question)
        q_id = getQuestionIDByName(question)
        return getQuestionRowNamesByIDByArm(arm_id,q_id)
    end
    
    def getQuestionRowNamesByIDByArm(arm_id,q_id)
        rownames = Array.new
        nrows = getNumQuestionRowsByArm(arm_id,q_id)
        if !nrows.nil? && (nrows.to_i > 0)
            for rowidx in 0..nrows.to_i - 1
                rowname = @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+"."+rowidx.to_s]
                if !rownames.include?(rowname)
                    rownames << rowname
                end
            end
        end
        return rownames
    end
    
    def getNumQuestionColsByArm(arm_id,q_id)
        ncols = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+".size"]
        if !ncols.nil?
            return ncols.to_i
        else
            return 1
        end
    end
    
    def getQuestionColNamesByNameByArm(arm_id,question)
        q_id = getQuestionIDByName(question)
        return getQuestionColNamesByIDByArm(arm_id,q_id)
    end
    
    def getQuestionColNamesByIDByArm(arm_id,q_id)
        colnames = Array.new
        ncols = getNumQuestionColsByArm(arm_id,q_id)
        if !ncols.nil? && (ncols.to_i > 0)
            for colidx in 0..ncols.to_i - 1
                colname = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+"."+colidx.to_s]
                if !colname.nil? &&
                    !colnames.include?(colname)
                    colnames << colname
                end
            end
        end
        return colnames
    end
    
    def getQuestionDataTypeNameByArm(arm_id,q_id)
        qtype = @question_data[getSectionPrefix()+".type."+arm_id.to_s+"."+q_id.to_s]
        if qtype.nil?
            qtype = "na"
        end
        return qtype
    end
    
    def isQuestionComplexByArm(arm_id, q_id)
        nrows = @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+".size"]
        ncols = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+".size"]
        # matrix_radio type has ncol == 1, but no column names listed - TODO need better way of handling this
        # so need to check for this condition
        firstcolname = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+".0"]
        return (!nrows.nil? && (nrows.to_i > 0) && !ncols.nil? && (ncols.to_i > 0) && !firstcolname.nil?)
    end
    
    def getNumQuestionRowsByArm(arm_id, q_id)
        if isQuestionComplexByArm(arm_id,q_id)
            nrows = @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+".size"]
            return nrows.to_i
        else
            return 1
        end
    end
    
    def getQuestionRowNames(qidx)
        q_id = getQuestionID(qidx)
        # Iterate through all the questions and compile the list of uniq row names
        # Return array of datapoint names associated with the referenced @question_ids and @question_names
        compnames = Array.new
        arm_ids = getArmIDs()
        if !arm_ids.nil? && (arm_ids.size() > 0)
            arm_ids.each do |arm_id|
                if isQuestionComplexByArm(arm_id,q_id)
                    nrows = @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+".size"]
                    if !nrows.nil? && (nrows.to_i > 0)
                        for rowidx in 0..nrows.to_i - 1
                            rowname = @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+"."+rowidx.to_s]
                            if !compnames.include?(rowname)
                                compnames << rowname
                            end
                        end
                    end
                end
            end
        else
            if isQuestionComplex(q_id)
                nrows = @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+q_id.to_s+".size"]
                if !nrows.nil? && (nrows.to_i > 0)
                    for rowidx in 0..nrows.to_i - 1
                        rowname = @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+q_id.to_s+"."+rowidx.to_s]
                        if !compnames.include?(rowname)
                            compnames << rowname
                        end
                    end
                end
            end
        end
        return compnames
    end
    
    def getQuestionRowNamesByArmByID(arm_id,q_id)
        rownames = Array.new
        nrows = @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+".size"]
        if !nrows.nil? && (nrows.to_i > 0)
            for rowidx in 0..nrows.to_i - 1
                rowname = @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+"."+rowidx.to_s]
                if !rownames.include?(rowname)
                    rownames << rowname
                end
            end
        end
        return rownames
    end
    
    def getNumQuestionColsByArmAdj(arm_id,q_id)
        ncols = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+".size"]
        if !ncols.nil?
            return ncols.to_i + 1       # compensate for row label column
        else
            return 1
        end
    end
    
    # Calculates the total columns each Question would take up
    def getTotalNumQuestionColsByArm(arm_id)
        totalcols = 0;
        @question_ids.each do |q_id|
            totalcols = totalcols + getNumQuestionColsByArmAdj(arm_id,q_id)
        end
        return totalcols
    end
    
    def getQuestionColNamesByArmByID(arm_id,q_id)
        colnames = Array.new
        ncols = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+".size"]
        if !ncols.nil? && (ncols.to_i > 0)
            for colidx in 0..ncols.to_i - 1
                colname = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+"."+colidx.to_s]
                if !colnames.include?(colname)
                    colnames << colname
                end
            end
        end
        return colnames
    end
    
    def getQuestionColNames(qidx)
        q_id = getQuestionID(qidx)
        # Iterate through all the arms and compile the list of uniq row names
        # Return array of datapoint names associated with the referenced Question
        compnames = Array.new
        arm_ids = getArmIDs()
        if !arm_ids.nil? && (arm_ids.size() > 0)
            arm_ids.each do |arm_id|
                if isQuestionComplexByArm(arm_id,q_id)
                    ncols = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+".size"]
                    if !ncols.nil? && (ncols.to_i > 0)
                        for colidx in 0..ncols.to_i - 1
                            colname = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+"."+colidx.to_s]
                            if !colname.nil? && !compnames.include?(colname)
                                compnames << colname
                            end
                        end
                    end
                end
            end
        else
            if isQuestionComplex(q_id)
                ncols = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+q_id.to_s+".size"]
                if !ncols.nil? && (ncols.to_i > 0)
                    for colidx in 0..ncols.to_i - 1
                        colname = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+q_id.to_s+"."+colidx.to_s]
                        if !colname.nil? && !compnames.include?(colname)
                            compnames << colname
                        end
                    end
                end
            end
        end
        return compnames
    end
    
    def getQuestionValueByArm(arm_id,q_id)
        val = @question_data[getSectionPrefix()+".dp."+arm_id.to_s+"."+q_id.to_s]
        if val.nil?
            val = @question_data[getSectionPrefix()+".dp."+arm_id.to_s+"."+q_id.to_s+".0.0"]
        end
        if val.nil?
            val = "-"
        end
        return val
    end
    
    def containsQuestionValueByArm(arm_id,q_id)
        val = @question_data[getSectionPrefix()+".dp."+arm_id.to_s+"."+q_id.to_s]
        return !val.nil?
    end
    
    def getQuestionFieldValueByArm(arm_id,q_id)
        val = @question_data[getSectionPrefix()+".dp."+arm_id.to_s+"."+q_id.to_s+".0"]
        if val.nil?
            val = getDefaultValue()
        end
        return val
    end
    
    def containsQuestionMatrixValueByArm(arm_id,q_id,row_idx,col_idx)
        val = @question_data[getSectionPrefix()+".dp."+arm_id.to_s+"."+q_id.to_s+"."+row_idx.to_s+"."+col_idx.to_s]
        return !val.nil?
    end
    
    def getQuestionMatrixValueByArm(arm_id,q_id,row_idx,col_idx)
        val = @question_data[getSectionPrefix()+".dp."+arm_id.to_s+"."+q_id.to_s+"."+row_idx.to_s+"."+col_idx.to_s]
        if val.nil?
            val = getDefaultValue()
        end
        return val
    end
    
    # Question HTML Methods -----------------------------------------------------
    def getQuestionHTMLValueByArm(arm_id,q_name)
        q_id = getQuestionIDByName(q_name)
        if isQuestionComplexByArm(arm_id,q_id)
            return getQuestionHTMLMatrixValueByArm(arm_id,q_name)
        else
            return getQuestionValueByArm(arm_id,q_id)
        end
    end
    
    def getQuestionHTMLComplexValueByArm(arm_id,q_name,row_idx,col_idx)
        q_id = getQuestionIDByName(q_name)
        return getQuestionMatrixValueByArm(arm_id,q_id,row_idx,col_idx)
    end
    
    def getQuestionHTMLMatrixValueByArm(arm_id,q_name)
        q_id = getQuestionIDByName(q_name)
        htmlout = ""
        nrows = @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+".size"]
        ncols = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+".size"]
        htmlout = htmlout + "<table class=\"tc_config_matrix\">\n"
        htmlout = htmlout + "    <tr>\n"
        htmlout = htmlout + "        <td>\n"
        htmlout = htmlout + "        &nbsp\n"   # Upper left corner place holder cell
        htmlout = htmlout + "        </td>\n"
        # Render column labels
        for colidx in 0..ncols.to_i - 1
            colname = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+"."+colidx.to_s]
            htmlout = htmlout + "        <td class=\"tc_config_colname\">\n"
            htmlout = htmlout + "        "+colname+"\n"
            htmlout = htmlout + "        </td>\n"
        end
        htmlout = htmlout + "    </tr>\n"
        for rowidx in 0..nrows.to_i - 1
            htmlout = htmlout + "    <tr>\n"
            rowname = @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+"."+rowidx.to_s]
            htmlout = htmlout + "        <td class=\"tc_config_rowname\">\n"
            htmlout = htmlout + "        "+rowname+"\n"
            htmlout = htmlout + "        </td>\n"
            for colidx in 0..ncols.to_i - 1
                htmlout = htmlout + "        <td class=\"tc_config_data\">\n"
                htmlout = htmlout + "        "+getQuestionMatrixValueByArm(arm_id,q_id,rowidx,colidx)+"\n"
                htmlout = htmlout + "        </td>\n"
            end
            htmlout = htmlout + "    </tr>\n"
        end
        htmlout = htmlout + "</table>"
        return htmlout
    end
    
    # Question EXCEL Export Methods -----------------------------------------------------
    # Calculates the total span of columns for a design detail
    def getQuestionColSpanByArm(arm_id,q_name)
        return getQuestionEXCELLabelsByArm(arm_id,q_name).size()
    end
    
    def getQuestionEXCELLabelsByArm(arm_id,q_name)
        q_id = getQuestionIDByName(q_name)
        qlabels = Array.new
        if isQuestionComplexByArm(arm_id,q_id)
            nrows = @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+".size"]
            ncols = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+".size"]
            for rowidx in 0..nrows.to_i - 1                                                       
                rowname = @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+"."+rowidx.to_s]
                for colidx in 0..ncols.to_i - 1
                    colname = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+"."+colidx.to_s]
                    qlabels << q_name+" ["+rowname+"/"+colname+"]"
                end
            end
        else
            qlabels << q_name
        end
        return qlabels
    end
    
    def getQuestionEXCELValuesByArm(q_name)
        q_id = getQuestionIDByName(q_name)
        qvalues = Array.new
        if isQuestionComplexByArm(arm_id,q_id)
            nrows = @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+".size"]
            ncols = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+arm_id.to_s+"."+q_id.to_s+".size"]
            for rowidx in 0..nrows.to_i - 1
                for colidx in 0..ncols.to_i - 1
                    qvalues << getQuestionMatrixValueByArm(arm_id,q_id,rowidx,colidx)
                end
            end
        else
            qvalues << getQuestionValueByArm(arm_id,q_id)
        end
        return qvalues
    end
end
