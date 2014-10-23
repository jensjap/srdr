class SectionData
    # Sectiondata is a container object encapsulating common data structures and information for the main study details and design. This is used
    # to provide generic/common methods or data access. Child classes extend this base class supplying data reference prefix information to
    # properly load and serve data requests
    
    def initialize
        @default_value = "-"        # Use this if no datapoint value is available
        
        @section_name = "Generic"   # This must be set in the initialization() method of the child class
        @section_desc = "Generic"   # This must be set in the initialization() method of the child class
        @section_id = "x"           # This must be set in the initialization() method of the child class - YAML identification
        @section_prefix = "na"      # This must be set in the initialization() method of the child class - ex armd, bl, outd, dd,,,
        
        @question_ids = nil         # list of field ids
        @question_names = nil       # list of field names - index corresponds to the id array
        @question_descs = nil       # list of field descriptions - index corresponds to the id array
        @question_data = nil        # Hash of section data ids - to be replaced by array of Questiondata class
        
        @questions = Hash.new       # Map of question objects - replaces above lists - retain @question_ids as the key and order of questions
    end
   
    def loadYAMLFile(project_id,study_id,extraction_form_id,cachefname)
        cachestudy = YAML.load_file(cachefname)
        loadYAMLQuestionData(cachestudy,project_id,study_id,extraction_form_id)
    end
   
    def loadYAML(project_id,study_id,extraction_form_id,cachestudy)
        loadYAMLQuestionData(cachestudy,project_id,study_id,extraction_form_id)
    end
        
    def loadYAMLQuestionData(cachestudy,project_id,study_id,extraction_form_id)
        puts "section_data::loadYAMLQuestionData - ID "+getSectionID()+" -------------------------------------------------<<"
        # Get meta data - look for section name and prefix
        # meta data defines the section name and prefix used to identify data points and other details of the section
        meta_data = cachestudy["meta_sections"]
        if !meta_data.nil?
            yaml_section_name = meta_data[getSectionID()+"_name"]
            if !yaml_section_name.nil?
                setSectionName(yaml_section_name);
            end
            yaml_section_desc = meta_data[getSectionID()+"_desc"]
            if !yaml_section_desc.nil?
                setSectionDescription(yaml_section_desc);
            end
            yaml_section_prefix = meta_data[getSectionID()+"_prefix"]
            if !yaml_section_prefix.nil?
                setSectionPrefix(yaml_section_prefix);
            end
            puts "section_data::loadYAMLQuestionData - ID "+getSectionID()+"_name = "+getSectionName()+" -------------------------------------<<"
            puts "section_data::loadYAMLQuestionData - ID "+getSectionID()+"_desc = "+getSectionDescription()+" -------------------------------------<<"
            puts "section_data::loadYAMLQuestionData - ID "+getSectionID()+"_prefix = "+getSectionPrefix()+" -------------------------------------<<"
        else
            puts "section_data::loadYAMLQuestionData - ID "+getSectionID()+" Error loading meta section -------------------------------------<<"
        end
        # Create data element reference names -------------------------------------
        data_name = getSectionID()+"_data"
        ids_name = getSectionID()+"_ids"
        names_name = getSectionID()+"_names"
        descs_name = getSectionID()+"_descs"
        # Question details --------------------------------------------------------
        @question_data = cachestudy[data_name]
        if @question_data.nil?
            @question_data = Hash.new
            @question_data[getSectionID()+".size"] = 0
        else
            if @question_data[getSectionID()+".size"].nil?
                @question_data[getSectionID()+".size"] = 0
            else
                # change the data type to int from string
                @question_data[getSectionID()+".size"] = @question_data[getSectionID()+".size"].to_i
            end
        end
        if getSectionID().eql?("arm_details")
            puts "section_data::loadYAMLQuestionData - ID "+getSectionID()+" data = "+@question_data.to_s+" -------------------------------------<<"
        end
        @question_ids = cachestudy[ids_name]
        if @question_ids.nil?
            @question_ids = Array.new
        end
        @question_names = TextUtil.restoreCodedList(cachestudy[names_name])
        if @question_names.nil?
            @question_names = Array.new
        end
        @question_descs = TextUtil.restoreCodedList(cachestudy[descs_name])
        if @question_descs.nil? ||
           (@question_descs.size() < @question_names.size())
            # If description is not provided - use the names as the description
            @question_descs = TextUtil.restoreCodedList(cachestudy[names_name])
        end
        if @question_descs.nil?
            @question_descs = Array.new
        end
        
        buildQuestionMap()
    end
    
    def buildQuestionMap()
        # Convert other size fields from string to int data type - keep it in sync with database load method and results
        if getNumQuestions() > 0
            for qidx in 0..getNumQuestions() - 1
                qid = getQuestionID(qidx)
                if !@question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+qid.to_s+".size"].nil?
                    @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+qid.to_s+".size"] = @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+qid.to_s+".size"].to_i
                end
                if !@question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+qid.to_s+".size"].nil?
                    @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+qid.to_s+".size"] = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+qid.to_s+".size"].to_i
                end
                
                # Build hash map of question objects
                if isQuestionComplex(qid)
                else
                    addQuestion(qid,buildSimpleQuestion(qid,@question_data))
                end
            end
        end
    end
    
    def addQuestion(qid,q)
        @questions[qid.to_s] = q
    end
    
    def buildSimpleQuestion(qid,data)
        q = SimpleQuestion.new
        q.setID(qid)
        q.setPrefix(getSectionPrefix())
        q.setName(getQuestionNameByID(qid))
        q.setDescription(getQuestionDescByID(qid))
        if data[q.getYAMLID()].nil?
            q.setValue(data[q.getYAMLID()])
        end
        return q
    end
    
    def loadDb(project_id,study_id,extraction_form_id)
    end
    
    # Getter/Setter Methods ----------------------------------------------------------------
    def setSectionID(id)
        @section_id = id
    end
    
    def getSectionID()
        return @section_id
    end
    
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
    
    def setDefaultValue(v)
        @default_value = v
    end
    
    def getDefaultValue()
        return @default_value
    end
    
    # Generalized Methods ----------------------------------------------------------------
    # Data access method
    def getNumQuestions()
        if @question_names.nil? ||
           @question_names.size() == 0
            return 0
        else
            return @question_names.size
        end    
    end
    
    def containsQuestion(name)
        return @question_names.include?(name)
    end
    
    def getQuestionID(idx)
        return @question_ids[idx]
    end
    
    def getQuestionName(idx)
        return @question_names[idx]
    end
    
    def getQuestionNameByID(qid)
        idx = @question_ids.index(qid)
        if idx < 0
            return "-"
        end
        return @question_names[idx]
    end
    
    def getQuestionDesc(idx)
        if idx < @question_descs.size()
            return @question_descs[idx]
        else
            return ""
        end
    end
    
    def getQuestionDescByID(qid)
        idx = @question_ids.index(qid)
        if idx < 0
            return "-"
        end
        if idx < @question_descs.size()
            return @question_descs[idx]
        else
            return ""
        end
    end
    
    def getQuestionIDByName(name)
        idx = @question_names.index(name)
        if idx.nil? || idx < 0
            return "x"
        else
            return @question_ids[idx]
        end
    end
    
    def getQuestionDataTypeName(q_id)
        qtype = @question_data[getSectionPrefix()+".type."+q_id.to_s]
        if qtype.nil?
            qtype = "na"
        end
        return qtype
    end
    
    def isQuestionNameComplex(question)
        q_id = getQuestionIDByName(question)
        return isQuestionComplex(q_id)
    end
    
    def isQuestionComplex(q_id)
        nrows = getNumQuestionRows(q_id)
        ncols = getNumQuestionCols(q_id)
        # matrix_radio type has ncol == 1, but no column names listed - TODO need better way of handling this
        # so need to check for this condition
        firstcolname = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+q_id.to_s+".0"]
        return (!nrows.nil? && (nrows.to_i > 0) && !ncols.nil? && (ncols.to_i > 0) && !firstcolname.nil?)
    end
    
    def getNumQuestionRowsByName(question)
        q_id = getQuestionIDByName(question)
        return getNumQuestionRows(q_id)
    end
    
    def getNumQuestionRows(q_id)
        nrows = @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+q_id.to_s+".size"]
        if !nrows.nil?
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
        if isQuestionComplex(q_id)
            nrows = getNumQuestionRows(q_id)
            if !nrows.nil? && (nrows.to_i > 0)
                for rowidx in 0..nrows.to_i - 1
                    rowname = @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+q_id.to_s+"."+rowidx.to_s]
                    if !compnames.include?(rowname)
                        compnames << rowname
                    end
                end
            end
        end
        return compnames
    end
    
    def getQuestionRowNamesByName(question)
        q_id = getQuestionIDByName(question)
        return getQuestionRowNamesByID(q_id)
    end
    
    def getQuestionRowNamesByID(q_id)
        rownames = Array.new
        nrows = getNumQuestionRows(q_id)
        if !nrows.nil? && (nrows.to_i > 0)
            for rowidx in 0..nrows.to_i - 1
                rowname = @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+q_id.to_s+"."+rowidx.to_s]
                if !rownames.include?(rowname)
                    rownames << rowname
                end
            end
        end
        return rownames
    end
    
    def getNumQuestionColsByName(question)
        q_id = getQuestionIDByName(question)
        return getNumQuestionCols(q_id)
    end
    
    def getNumQuestionCols(q_id)
        ncols = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+q_id.to_s+".size"]
        if !ncols.nil?
            return ncols.to_i + 1       # Compensate for extra column for row labels
        else
            return 1
        end
    end
    
    def getTotalNumQuestionCols()
        totalcols = 0;
        @question_ids.each do |q_id|
            totalcols = totalcols + getNumQuestionCols(q_id)
        end
        return totalcols
    end
    
    def getQuestionColNamesByName(question)
        q_id = getQuestionIDByName(question)
        return getQuestionColNamesByID(q_id)
    end
    
    def getQuestionColNamesByID(q_id)
        colnames = Array.new
        ncols = getNumQuestionCols(q_id)
        if !ncols.nil? && (ncols.to_i > 0)
            for colidx in 0..ncols.to_i - 1
                colname = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+q_id.to_s+"."+colidx.to_s]
                if !colname.nil? &&
                    !colnames.include?(colname)
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
        if isQuestionComplex(q_id)
            ncols = getNumQuestionCols(q_id)
            if !ncols.nil? && (ncols.to_i > 0)
                for colidx in 0..ncols.to_i - 1
                    colname = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+q_id.to_s+"."+colidx.to_s]
                    if !colname.nil? && !compnames.include?(colname)
                        compnames << colname
                    end
                end
            end
        end
        return compnames
    end
    
    def isQuestionSingleValue(q_id)
        nvals = getNumQuestionRows(q_id)
        ncvals = getNumQuestionCols(q_id)
        return (!nvals.nil? && !ncvals.nil? && (nvals.to_i == 0) && (ncvals.to_i == 0))
    end
    
    def getQuestionValue(q_id)
        val = @question_data[getSectionPrefix()+".dp."+q_id.to_s]
        if val.nil?
            val = @question_data[getSectionPrefix()+".dp."+q_id.to_s+".0.0"]
        end
        if val.nil?
            val = "-"
        end
        return val
    end
    
    def containsQuestionValue(q_id)
        val = @question_data[getSectionPrefix()+".dp."+q_id.to_s]
        return !val.nil?
    end
    
    def getQuestionFieldValue(q_id)
        val = @question_data[getSectionPrefix()+".dp."+q_id.to_s+".0"]
        if val.nil?
            val = getDefaultValue()
        end
        return val
    end
    
    def containsQuestionMatrixValue(q_id,row_idx,col_idx)
        val = @question_data[getSectionPrefix()+".dp."+q_id.to_s+"."+row_idx.to_s+"."+col_idx.to_s]
        return !val.nil?
    end
    
    def getQuestionMatrixValue(q_id,row_idx,col_idx)
        val = @question_data[getSectionPrefix()+".dp."+q_id.to_s+"."+row_idx.to_s+"."+col_idx.to_s]
        if val.nil?
            val = getDefaultValue()
        end
        return val
    end
    
    # Question HTML Methods -----------------------------------------------------
    def getQuestionHTMLValue(q_name)
        q_id = getQuestionIDByName(q_name)
        if isQuestionComplex(q_id)
            return getQuestionHTMLMatrixValue(q_name)
        else
            return getQuestionValue(q_id)
        end
    end
    
    def getQuestionHTMLComplexValue(q_name,row_idx,col_idx)
        q_id = getQuestionIDByName(q_name)
        return getQuestionMatrixValue(q_id,row_idx,col_idx)
    end
    
    def getQuestionHTMLMatrixValue(q_name)
        q_id = getQuestionIDByName(q_name)
        htmlout = ""
        nrows = getNumQuestionRows(q_id)
        ncols = getNumQuestionCols(q_id)
        htmlout = htmlout + "<table class=\"tc_config_matrix\">\n"
        htmlout = htmlout + "    <tr>\n"
        htmlout = htmlout + "        <td>\n"
        htmlout = htmlout + "        &nbsp\n"   # Upper left corner place holder cell
        htmlout = htmlout + "        </td>\n"
        # Render column labels
        for colidx in 0..ncols.to_i - 1
            colname = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+q_id.to_s+"."+colidx.to_s]
            htmlout = htmlout + "        <td class=\"tc_config_colname\">\n"
            htmlout = htmlout + "        "+colname+"\n"
            htmlout = htmlout + "        </td>\n"
        end
        htmlout = htmlout + "    </tr>\n"
        for rowidx in 0..nrows.to_i - 1
            htmlout = htmlout + "    <tr>\n"
            rowname = @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+q_id.to_s+"."+rowidx.to_s]
            htmlout = htmlout + "        <td class=\"tc_config_rowname\">\n"
            htmlout = htmlout + "        "+rowname+"\n"
            htmlout = htmlout + "        </td>\n"
            for colidx in 0..ncols.to_i - 1
                htmlout = htmlout + "        <td class=\"tc_config_data\">\n"
                htmlout = htmlout + "        "+getQuestionMatrixValue(q_id,rowidx,colidx)+"\n"
                htmlout = htmlout + "        </td>\n"
            end
            htmlout = htmlout + "    </tr>\n"
        end
        htmlout = htmlout + "</table>"
        return htmlout
    end
    
    # Question EXCEL Export Methods -----------------------------------------------------
    # Calculates the total span of columns for a design detail
    def getQuestionColSpan(q_name)
        return getQuestionEXCELLabels(q_name).size()
    end
    
    def getQuestionEXCELLabels(q_name)
        q_id = getQuestionIDByName(q_name)
        qlabels = Array.new
        if isQuestionComplex(q_id)
            nrows = getNumQuestionRows(q_id)
            ncols = getNumQuestionCols(q_id)
            for rowidx in 0..nrows.to_i - 1
                rowname = @question_data[getSectionPrefix()+"."+getSectionPrefix()+"f."+q_id.to_s+"."+rowidx.to_s]
                for colidx in 0..ncols.to_i - 1
                    colname = @question_data[getSectionPrefix()+".c"+getSectionPrefix()+"f."+q_id.to_s+"."+colidx.to_s]
                    qlabels << q_name+" ["+rowname+"/"+colname+"]"
                end
            end
        else
            qlabels << q_name
        end
        return qlabels
    end
    
    def getQuestionEXCELValues(q_name)
        q_id = getQuestionIDByName(q_name)
        qvalues = Array.new
        if isQuestionComplex(q_id)
            nrows = getNumQuestionRows(q_id)
            ncols = getNumQuestionCols(q_id)
            for rowidx in 0..nrows.to_i - 1
                for colidx in 0..ncols.to_i - 1
                    qvalues << getQuestionMatrixValue(q_id,rowidx,colidx)
                end
            end
        else
            qvalues << getQuestionValue(q_id)
        end
        return qvalues
    end
    
    def dumpData()
        puts getSectionID()+" "+getSectionName()+" - question_ids = "+@question_ids.to_s
        puts getSectionID()+" "+getSectionName()+" - question_names = "+@question_names.to_s
        puts getSectionID()+" "+getSectionName()+" - question_descs = "+@question_descs.to_s
        puts getSectionID()+" "+getSectionName()+" - question_data = "+@question_data.to_s
    end
end
