class ReportconfigData
    # ReportconfigData mirrors ReportsetData collecting distinct data elements across studies within a project. Its primary purpose is to track which
    # data item was selected to for display and export.
    
    def initialize
        @section_name = "Generic"   # This must be set in the initialization() method of the child class
        @section_label = "Generic"  # This must be set in the initialization() method of the child class
        @section_prefix = "na"      # This must be set in the initialization() method of the child class
        
        @rec_config = Hash.new
        @default_config = Hash.new
        
        # Section Details list ---------------------------------------------------------------------------------------------------
        @section_config = Hash.new
        @sectionrec_config = Hash.new
        @sectionfield_config = Hash.new         # Hash[<question idx>.<field row idx>.0] = 0 | 1 to indicate show
        @sectionmatrix_config = Hash.new        # Hash[<question idx>.<field row idx>.<field col idx>] = 0 | 1 to indicate show
        
        # Renderer properties ---------------------------------------------------------------------------------------------------
        @display_flat = true
    end
    
    # Getter/Setter Methods ----------------------------------------------------------------
    
    def setSectionName(name)
        @section_name = name
    end
    
    def getSectionName()
        return @section_name
    end
    
    def setSectionLabel(label)
        @section_label = label
    end
    
    def getSectionLabel()
        return @section_label
    end
    
    def setSectionPrefix(pref)
        @section_prefix = pref
    end
    
    def getSectionPrefix()
        return @section_prefix
    end
    
    def setIsDefault(defid,defv)
        @default_config[defid] = defv
    end
    
    def renderFlat()
        @display_flat = true
    end
    
    def renderVertical()
        @display_flat = false
    end
    
    def isRenderFlat()
        return @display_flat
    end
    
    # Generalized loader methods -----------------------------------------------------------------------------
    def setConfig(reportsetdata)       
        # Set the name, description, and prefix to the report set data
        setSectionName(reportsetdata.getSectionName());
        setSectionLabel(reportsetdata.getSectionDescription());
        setSectionPrefix(reportsetdata.getSectionPrefix());
        
        nsize = reportsetdata.getNumDistinctQuestions()
        if nsize > 0
            for idx in 0..nsize - 1
                @section_config[getSectionPrefix()+"_"+idx.to_s] = [reportsetdata.getDistinctQuestionName(idx), reportsetdata.getDistinctQuestionDesc(idx), 0]
                if (reportsetdata.getNumQuestionRows(idx) == 0) &&
                    (reportsetdata.getNumQuestionCols(idx) == 0)
                    # Single value 
                elsif reportsetdata.getNumQuestionCols(idx) == 0
                    # Row only
                    qrnames = reportsetdata.getQuestionRowNames(idx)
                    qfidx = 0
                    fieldnames = Hash.new 
                    qrnames.each do |name|
                        fieldnames[getSectionPrefix()+"_"+idx.to_s+"."+qfidx.to_s+".0"] = [name, name, 0]
                        qfidx = qfidx + 1
                    end
                    @sectionfield_config[getSectionPrefix()+"_"+idx.to_s] = fieldnames
                else
                    # Table format
                    qrnames = reportsetdata.getQuestionRowNames(idx)
                    qcnames = reportsetdata.getQuestionColNames(idx)
                    qfidx = 0
                    matrixnames = Hash.new 
                    qrnames.each do |name|
                        matrixnames[getSectionPrefix()+"_"+idx.to_s+"."+qfidx.to_s+".x"] = [name, name, 0]
                        cqfidx = 0
                        qcnames.each do |cname|
                            matrixnames[getSectionPrefix()+"_"+idx.to_s+".x."+cqfidx.to_s] = [cname, cname, 0]
                            matrixnames[getSectionPrefix()+"_"+idx.to_s+"."+qfidx.to_s+"."+cqfidx.to_s] = [name+"|"+cname, name+"|"+cname, 0]
                            cqfidx = cqfidx + 1
                        end
                        qfidx = qfidx + 1
                    end
                    @sectionmatrix_config[getSectionPrefix()+"_"+idx.to_s+".rows"] = qrnames
                    @sectionmatrix_config[getSectionPrefix()+"_"+idx.to_s+".cols"] = qcnames
                    @sectionmatrix_config[getSectionPrefix()+"_"+idx.to_s] = matrixnames
                end
            end
        end   
    end
    
    def loadConfig(configdata)
        # First load detail record data ----------------------------------------------------------------------------------------
        cfgdata = config["tablecreator-"+getSectionPrefix()+"rec"]
        if !cfgdata.nil?
            numitems = cfgdata["n"].to_i
            if !numitems.nil? &&
               (numitems.to_i > 0)
                for idx in 0..numitems - 1
                   cfg = cfgdata[getSectionPrefix()+"rec_"+idx.to_s]
                   name = cfg["name"]
                   desc = cfg["description"]
                   showflag = cfg["show"]
                   @sectionrec_config[getSectionPrefix()+"rec_"+idx.to_s] = [name,desc,showflag.to_i]
                end
            end
        end
        # Load question data ----------------------------------------------------------------------------------------
        cfgdata = config["tablecreator-"+getSectionPrefix()]
        if !cfgdata.nil?
            numitems = cfgdata["n"].to_i
            if !numitems.nil? &&
               (numitems.to_i > 0)
                for idx in 0..numitems - 1
                   cfg = cfgdata[getSectionPrefix()+"_"+idx.to_s]
                   name = cfg["name"]
                   desc = cfg["description"]
                   showflag = cfg["show"]
                   @section_config[getSectionPrefix()+"_"+idx.to_s] = [name,desc,showflag.to_i]
                end
            end
        end
        # Load field question data ----------------------------------------------------------------------------------------
        cfgdata = config["tablecreator-"+getSectionPrefix()+"f"]
        if !cfgdata.nil?
            numitems = cfgdata["n"].to_i
            if !numitems.nil? &&
               (numitems.to_i > 0)
                for idx in 0..numitems - 1
                    rowcfg = cfgdata[getSectionPrefix()+"_"+idx.to_s]
                    numrows = rowcfg["rows"]
                    if numrows.to_i > 0
                        fieldnames = Hash.new 
                        for ridx in 0..numrows.to_i - 1
                            cfg = rowcfg[getSectionPrefix()+"_"+idx.to_s+"_"+ridx.to_s+"_0"]
                            name = cfg["name"]
                            desc = cfg["description"]
                            showflag = cfg["show"]
                            fieldnames[getSectionPrefix()+"_"+idx.to_s+"."+ridx.to_s+".0"] = [name,desc,showflag.to_i]
                        end
                    end
                    @sectionfield_config[getSectionPrefix()+"_"+idx.to_s] = fieldnames
                end
            end
        end
        # Load matrix question data ----------------------------------------------------------------------------------------
        cfgdata = config["tablecreator-"+getSectionPrefix()+"m"]
        if !cfgdata.nil?
             numitems = cfgdata["n"].to_i
             if !numitems.nil? &&
                (numitems.to_i > 0)
                for idx in 0..numitems - 1
                   qrnames = cfgdata["rows"]
                   qcnames = cfgdata["cols"]
                   matrixnames = Hash.new 
                   for ridx in 0..qrnames.size() - 1
                      for cidx in 0..qcnames.size() - 1
                         cfg = cfgdata[getSectionPrefix()+"_"+idx.to_s+"_"+ridx.to_s+"_"+cidx.to_s]
                         name = cfg["name"]
                         desc = cfg["description"]
                         showflag = cfg["show"]
                         matrixnames[getSectionPrefix()+"_"+idx.to_s+"."+ridx.to_s+"."+cidx.to_s] = [name,desc,showflag.to_i]
                      end
                   end
                   @sectionmatrix_config[getSectionPrefix()+"_"+idx.to_s+".rows"] = qrnames
                   @sectionmatrix_config[getSectionPrefix()+"_"+idx.to_s+".cols"] = qcnames
                   @sectionmatrix_config[getSectionPrefix()+"_"+idx.to_s] = matrixnames
                end
            end
        end
    end
    
    def saveConfig(configfile)
        # First write out the question details configuration
        f.puts "tablecreator-"+getSectionPrefix()+"rec"
        f.puts "  n: "+@sectionrec_config.size().to_s
        if (@sectionrec_config.size() > 0)
            for idx in 0..@sectionrec_config.size() - 1
                cfg = @sectionrec_config[getSectionPrefix()+"rec_"+idx.to_s]
                f.puts "  "+getSectionPrefix()+"rec_"+idx.to_s
                f.puts "    name: "+cfg[0].to_s
                f.puts "    description: "+cfg[0].to_s
                f.puts "    show: "+cfg[0].to_s
            end
        end
        # Write out the question configuration
        f.puts "tablecreator-"+getSectionPrefix()
        f.puts "  n: "+@section_config.size().to_s
        if (@section_config.size() > 0)
            for idx in 0..@section_config.size() - 1
                cfg = @section_config[getSectionPrefix()+"_"+idx.to_s]
                f.puts "  "+getSectionPrefix()+"_"+idx.to_s
                f.puts "    name: "+cfg[0].to_s
                f.puts "    description: "+cfg[0].to_s
                f.puts "    show: "+cfg[0].to_s
            end
        end
        # Write out field (1-dimension row) question configuration
        f.puts "tablecreator-"+getSectionPrefix()+"f"
        f.puts "  n: "+@sectionfield_config.size().to_s
        if (@sectionfield_config.size() > 0)
            for idx in 0..@sectionfield_config.size() - 1
                fieldnames = @sectionfield_config[getSectionPrefix()+"_"+idx.to_s]
                if !fieldnames.nil? &&
                   (fieldnames.size() > 0)
                end
                cfg = @section_config[getSectionPrefix()+"_"+idx.to_s]
                f.puts "  "+getSectionPrefix()+"_"+idx.to_s
                f.puts "    name: "+cfg[0].to_s
                f.puts "    description: "+cfg[0].to_s
                f.puts "    show: "+cfg[0].to_s
            end
        end
    end
    
    # Generalized data access methods ------------------------------------------------------------------------------
    # Record field access methods ------------------------------------------------------------------------------
    def getNumQuestionDetailItems()
        return @sectionrec_config.size()
    end
    
    def getQuestionDetailConfig(idx)
        return @sectionrec_config[getSectionPrefix()+"rec_"+idx.to_s]
    end
    
    def showQuestionDetailItem(idx,v)
        if @sectionrec_config[getSectionPrefix()+"rec_"+idx.to_s][2] != v
            setIsDefault(getSectionPrefix()+"rec_"+idx.to_s,0)
        end
        @sectionrec_config[getSectionPrefix()+"rec_"+idx.to_s][2] = v
    end
    
    def addQuestionDetail(name,desc)
        @sectionrec_config[getSectionPrefix()+"rec_"+@sectionrec_config.size().to_s] = [name, desc, 0]
    end
    
    # Section access methods ------------------------------------------------------------------------------
    def getNumQuestionItems()
        return @section_config.size()
    end
    
    def getQuestionConfig(idx)
        return @section_config[getSectionPrefix()+"_"+idx.to_s]
    end
    
    def getQuestionName(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @section_config[getSectionPrefix()+"_"+idx.to_s][0]
    end
    
    def getQuestionDesc(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @section_config[getSectionPrefix()+"_"+idx.to_s][1]
    end
    
    def getQuestionFlag(idx)
        # config format [<name>, <desc>, <0 | 1>]
        return @section_config[getSectionPrefix()+"_"+idx.to_s][2]
    end
    
    def showQuestionItem(idx,v)
        if @section_config[getSectionPrefix()+"_"+idx.to_s][2] != v
            setIsDefault(getSectionPrefix()+"_"+idx.to_s,0)
        end
        @section_config[getSectionPrefix()+"_"+idx.to_s][2] = v
    end
    
    def showQuestion(idx)
        return getQuestionFlag(idx) == 1
    end
    
    def getNumQuestionCols()
        n_cols = 0
        for ridx in 0..getNumQuestionItems() - 1
            if showQuestion(ridx)
                n = getQuestionMatrixNCols(ridx)
                n_cols = n_cols + n
                if (isQuestionMatrix(ridx))
                    # Adjust 1 for row titles
                    n_cols = n_cols + 1
                end
            end
        end
        return n_cols
    end
    
    def showQuestionItem(idx,v)
        if @section_config[getSectionPrefix()+"_"+idx.to_s][2] != v
            setIsDefault(getSectionPrefix()+"_"+idx.to_s,0)
        end
        @section_config[getSectionPrefix()+"_"+idx.to_s][2] = v
    end
    
    def getNumShowQuestion()
        nshow = 0
        for ridx in 0..getNumQuestionItems() - 1
            if showQuestion(ridx)
                nshow = nshow + 1
            end
        end
        return nshow
    end
    
    # Fields (rows) -------------------------------------------------------------
    def getQuestionFieldConfig(idx)
        return @sectionfield_config[getSectionPrefix()+"_"+idx.to_s]
    end
    
    def getNumQuestionFieldConfig(idx)
        fields = @sectionfield_config[getSectionPrefix()+"_"+idx.to_s]
        if fields.nil?
            return 0
        else
            return fields.size
        end
    end
    
    def getQuestionFieldName(idx,qfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @sectionfield_config[getSectionPrefix()+"_"+idx.to_s][getSectionPrefix()+"_"+idx.to_s+"."+qfidx.to_s+".0"][0]
    end
    
    def getQuestionFieldDesc(idx,qfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @sectionfield_config[getSectionPrefix()+"_"+idx.to_s][getSectionPrefix()+"_"+idx.to_s+"."+qfidx.to_s+".0"][1]
    end
    
    def getQuestionFieldFlag(idx,qfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @sectionfield_config[getSectionPrefix()+"_"+idx.to_s][getSectionPrefix()+"_"+idx.to_s+"."+qfidx.to_s+".0"][2]
    end
    
    def showQuestionField(idx,qfidx,v)
        if @sectionfield_config[getSectionPrefix()+"_"+idx.to_s][getSectionPrefix()+"_"+idx.to_s+"."+qfidx.to_s+".0"][2] != v
            setIsDefault(getSectionPrefix()+"_"+idx.to_s+"."+qfidx.to_s+".0",0)
        end
        @sectionfield_config[getSectionPrefix()+"_"+idx.to_s][getSectionPrefix()+"_"+idx.to_s+"."+qfidx.to_s+".0"][2] = v
    end
    
    # Matrix --------------------------------------------------------------------
    def isQuestionMatrix(ridx)
        return (getNumQuestionMatrixConfig(ridx) > 0)
    end
    
    def getQuestionMatrixConfig(idx)
        return @sectionmatrix_config[getSectionPrefix()+"_"+idx.to_s]
    end
    
    def getQuestionMatrixRowsConfig(idx)
        return @sectionmatrix_config[getSectionPrefix()+"_"+idx.to_s+".rows"]
    end
    
    def getNumQuestionMatrixRowsConfig(idx)
        qrnames = @sectionmatrix_config[getSectionPrefix()+"_"+idx.to_s+".rows"]
        if qrnames.nil?
            return 0
        else
            return qrnames.size
        end
    end
    
    def getQuestionMatrixColsConfig(idx)
        return @sectionmatrix_config[getSectionPrefix()+"_"+idx.to_s+".cols"]
    end
    
    def getNumQuestionMatrixColsConfig(idx)
        qcnames = @sectionmatrix_config[getSectionPrefix()+"_"+idx.to_s+".cols"]
        if qcnames.nil?
            return 0
        else
            return qcnames.size
        end
    end
    
    def getNumQuestionMatrixConfig(idx)
        matrix = @sectionmatrix_config[getSectionPrefix()+"_"+idx.to_s]
        if matrix.nil?
            return 0
        else
            return matrix.size
        end
    end
    
    def getQuestionMatrixName(idx,qfidx,cqfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @sectionmatrix_config[getSectionPrefix()+"_"+idx.to_s][getSectionPrefix()+"_"+idx.to_s+"."+qfidx.to_s+"."+cqfidx.to_s][0]
    end
    
    def getQuestionMatrixDesc(idx,qfidx,cqfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @sectionmatrix_config[getSectionPrefix()+"_"+idx.to_s][getSectionPrefix()+"_"+idx.to_s+"."+qfidx.to_s+"."+cqfidx.to_s][1]
    end
    
    def getQuestionMatrixFlag(idx,qfidx,cqfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @sectionmatrix_config[getSectionPrefix()+"_"+idx.to_s][getSectionPrefix()+"_"+idx.to_s+"."+qfidx.to_s+"."+cqfidx.to_s][2]
    end
    
    def getQuestionMatrixRowFlag(idx,qfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @sectionmatrix_config[getSectionPrefix()+"_"+idx.to_s][getSectionPrefix()+"_"+idx.to_s+"."+qfidx.to_s+".x"][2]
    end
    
    def getQuestionMatrixColFlag(idx,cqfidx)
        # config format [<name>, <desc>, <0 | 1>]
        return @sectionmatrix_config[getSectionPrefix()+"_"+idx.to_s][getSectionPrefix()+"_"+idx.to_s+".x."+cqfidx.to_s][2]
    end
    
    def showQuestionMatrix(idx,qfidx,cqfidx,v)
        if @sectionmatrix_config[getSectionPrefix()+"_"+idx.to_s][getSectionPrefix()+"_"+idx.to_s+"."+qfidx.to_s+"."+cqfidx.to_s][2] != v
            setIsDefault(getSectionPrefix()+"_"+idx.to_s+"."+qfidx.to_s+"."+cqfidx.to_s,0)
        end
        @sectionmatrix_config[getSectionPrefix()+"_"+idx.to_s][getSectionPrefix()+"_"+idx.to_s+"."+qfidx.to_s+"."+cqfidx.to_s][2] = v
    end
    
    def showQuestionMatrixRow(idx,qfidx,v)
        if @sectionmatrix_config[getSectionPrefix()+"_"+idx.to_s][getSectionPrefix()+"_"+idx.to_s+"."+qfidx.to_s+".x"][2] != v
            setIsDefault(getSectionPrefix()+"_"+idx.to_s+"."+qfidx.to_s+".x",0)
        end
        @sectionmatrix_config[getSectionPrefix()+"_"+idx.to_s][getSectionPrefix()+"_"+idx.to_s+"."+qfidx.to_s+".x"][2] = v
    end
    
    def showQuestionMatrixCol(idx,cqfidx,v)
        if @sectionmatrix_config[getSectionPrefix()+"_"+idx.to_s][getSectionPrefix()+"_"+idx.to_s+".x."+cqfidx.to_s][2] != v
            setIsDefault(getSectionPrefix()+"_"+idx.to_s+".x."+cqfidx.to_s,0)
        end
        @sectionmatrix_config[getSectionPrefix()+"_"+idx.to_s][getSectionPrefix()+"_"+idx.to_s+".x."+cqfidx.to_s][2] = v
    end
    
    # These two methods are used by the EXCEL export to calculate how many rows and cols cells are involved
    def getQuestionMatrixNCols(ridx)
        nmatrix = getNumQuestionMatrixConfig(ridx)
        nfields = getNumQuestionFieldConfig(ridx)
        ncols = 0
        if nmatrix > 0
            qrnames = getQuestionMatrixRowsConfig(ridx)
            qcnames = getQuestionMatrixColsConfig(ridx)
            cqfidx = 0
            qcnames.each do |colname|
                showcol = getQuestionMatrixColFlag(ridx,cqfidx)
                if showcol.to_s == "1"
                    ncols = ncols + 1 
                end
                cqfidx = cqfidx + 1
            end
        else
            ncols = 1
        end
        return ncols
    end
    
    def getQuestionMatrixNRows(ridx)
        nmatrix = getNumQuestionMatrixConfig(ridx)
        nfields = getNumQuestionFieldConfig(ridx)
        nrows = 0
        if nmatrix > 0
            qrnames = getQuestionMatrixRowsConfig(ridx)
            qcnames = getQuestionMatrixColsConfig(ridx)
            for qfidx in 0..qrnames.size - 1
                showcol = getQuestionMatrixRowFlag(ridx,qfidx)
                if showcol.to_s == "1" 
                    nrows = nrows + 1 
                end
            end
        else
            nrows = 1
        end
        return nrows
    end
    
    # If question is a matrix - returns list of column names marked for display, otherwise returns empty Array
    def getQuestionMatrixColNames(ridx)
        nmatrix = getNumQuestionMatrixConfig(ridx)
        nfields = getNumQuestionFieldConfig(ridx)
        colnames = Array.new
        if nmatrix > 0
            qrnames = getQuestionMatrixRowsConfig(ridx)
            qcnames = getQuestionMatrixColsConfig(ridx)
            cqfidx = 0
            qcnames.each do |colname|
                showcol = getQuestionMatrixColFlag(ridx,cqfidx)
                if showcol.to_s == "1"
                    colnames << colname 
                end
                cqfidx = cqfidx + 1
            end
        end
        return colnames
    end
    
    # If question is a matrix - returns list of row names marked for display, otherwise returns empty Array
    def getQuestionMatrixRowNames(ridx)
        nmatrix = getNumQuestionMatrixConfig(ridx)
        nfields = getNumQuestionFieldConfig(ridx)
        rownames = Array.new
        if nmatrix > 0
            qrnames = getQuestionMatrixRowsConfig(ridx)
            qcnames = getQuestionMatrixColsConfig(ridx)
            for qfidx in 0..qrnames.size - 1
                showcol = getQuestionMatrixRowFlag(ridx,qfidx)
                if showcol.to_s == "1" 
                    rownames << qrnames[qfidx] 
                end
            end
        end
        return rownames
    end
    
    # Render Methods ------------------------------------------------------------------------------
    def getNumQuestionToDisplay()
        q_ncols = 0;
        for ridx in 0..getNumQuestionItems() - 1
            if showQuestion(ridx)
                if isRenderFlat()
                    # if single value, nc and nr equals 1 anyway
                    nc = getQuestionMatrixNCols(ridx)
                    nr = getQuestionMatrixNRows(ridx)
                    q_ncols = q_ncols + (nr * nc)
                else
                    # Render single cell per question or single value question
                    q_ncols = q_ncols + 1
                end
            end
        end
        return q_ncols 
    end
    
    def getNumQuestionToDisplayFlat(ridx)
        n_cols = 0
        for ridx in 0..getNumQuestionItems() - 1
            if showQuestion(ridx)
                nc = getQuestionMatrixNCols(ridx)
                nr = getQuestionMatrixNRows(ridx)
                n_cols = n_cols + (nr * nc)
            end
        end
        return n_cols
    end
    
    def getQuestionIndex(question)
        for ridx in 0..getNumQuestionItems() - 1
            if getQuestionName(ridx).eql?(question)
                return ridx
            end
        end
        return -1
    end
    
    def displayThisSection()
        return getNumQuestionToDisplay() > 0 
    end
    
    def displayQuestionArrayCell(question,qfidx)
        ridx = getQuestionIndex(question)
        return getQuestionFieldFlag(ridx,qfidx) == 1
    end
    
    def displayQuestionMatrixCell(question,qfidx,cqfidx)
        ridx = getQuestionIndex(question)
        return getQuestionMatrixFlag(ridx,qfidx,cqfidx) == 1
    end
    
    def getDisplayTitles()
        disp_list = Array.new;
        for ridx in 0..getNumQuestionItems() - 1
            if showQuestion(ridx)
                qname = getQuestionName(ridx)
                if isRenderFlat()
                    # qrnames and qcnames is the complete list of rows and col names
                    qrnames = getQuestionMatrixRowsConfig(ridx)
                    qcnames = getQuestionMatrixColsConfig(ridx)
                    
                    # rnames and cnames is the list of rows and cols to be displayed - use qrnames and qcnames to get the actual ridx and cidx index reference
                    rnames = getQuestionMatrixRowNames(ridx)
                    cnames = getQuestionMatrixColNames(ridx)
                    if ((rnames.size() == 0) &&
                        (cnames.size() == 0))
                        disp_list << qname
                    elsif (cnames.size() == 0)
                        rnames.each do |rn|
                            qfidx = qrnames.index(rn)
                            if getQuestionFieldFlag(ridx,qfidx) == 1
                                disp_list << "["+qname+"]["+rn+"]"
                            end
                        end
                    else
                        rnames.each do |rn|
                            qfidx = qrnames.index(rn)
                            cnames.each do |cn|
                                cqfidx = qcnames.index(cn)
                                if getQuestionMatrixFlag(ridx,qfidx,cqfidx) == 1
                                    disp_list << "["+qname+"]["+rn+"]["+cn+"]"
                                end
                            end
                        end
                    end
                else
                    disp_list << qname
                end
            end
        end
        return disp_list 
    end
    
    # EXCEL Export Methods ------------------------------------------------------------------------------
    def getTotalQuestionEXCELSpan(reportsetdata)
        q_ncols = 0
        for qidx in 0..getNumQuestionItems() - 1
            if showQuestions(qidx)
                # For each questions to show - get the total number columns to support the export of this questions
                q_ncols = q_ncols + getQuestionEXCELSpan(qidx,reportsetdata)
            end
        end
        return q_ncols
    end
    
    def getQuestionEXCELSpan(qidx,reportsetdata)
        q_name = getQuestionName(qidx)
        return reportsetdata.getQuestionEXCELSpan(q_name)
    end
    
    def getQuestionEXCELLabels(qidx,reportsetdata)
        q_name = getQuestionName(qidx)
        return reportsetdata.getQuestionEXCELLabels(q_name) 
    end
    
    def getDesignDetailEXCELValues(sidx,qidx,reportsetdata)
        q_name = getDesignDetailsName(qidx)
        q_values = reportsetdata.getDesignDetailEXCELValues(sidx,q_name);
        return q_values
    end
    
    # JavaScript Renderer Methods ------------------------------------------------------------------------------
    def renderJavaScript()
        js = ""
        js = js + "function "+getSectionName()+"SelectAll() {\n" 
        js = js + "    var itemval = 0;\n"
        js = js + "    if (document.tablecreator."+getSectionPrefix()+"rec_all.checked) {\n"
        js = js + "       itemval = 1;\n"
        js = js + "    };      // end if\n"   
        for ridx in 0..getNumQuestionDetailItems()-1
            js = js + "    document.tablecreator."+getSectionPrefix()+"rec_"+ridx.to_s+".checked = itemval;\n"
        end
        js = js + "}\n"
        js = js + "\n"
        js = js + "function "+getSectionName()+"ItemChecked() {\n" 
        js = js + "    document.tablecreator."+getSectionPrefix()+"rec_all.checked = false;\n"
        js = js + "}\n"
        js = js + "\n"
        js = js + "function "+getSectionName()+"NamesSelectAll() {\n" 
        js = js + "    var itemval = 0;\n"
        js = js + "    if (document.tablecreator."+getSectionPrefix()+"names_all.checked) {\n"
        js = js + "       itemval = 1;\n"
        js = js + "    };      // end if\n"   
        for ridx in 0..getNumQuestionItems() - 1
            js = js + "    document.tablecreator."+getSectionPrefix()+"_"+ridx.to_s+".checked = itemval;\n"
        end
        js = js + "}\n"
        js = js + "\n"
        js = js + "function "+getSectionName()+"NamesItemChecked(idx) {\n"
        js = js + "    document.tablecreator."+getSectionPrefix()+"names_all.checked = false;\n"
        js = js + "    eval(\"var cf = document.tablecreator."+getSectionPrefix()+"_\"+idx+\".checked;\");\n"
        js = js + "    var status = \"false\";\n"
        js = js + "    if (cf) {\n"
        js = js + "        status = \"true\";\n"
        js = js + "    };  // end if\n"
        js = js + "    // Now check to see if this is a matrix type\n"
        js = js + "    var nrows;\n"
        js = js + "    var ncols;\n"
        js = js + "    eval(\"nrows = document.tablecreator."+getSectionPrefix()+"mv_\"+idx+\"_nrows.value\");\n"
        js = js + "    eval(\"ncols = document.tablecreator."+getSectionPrefix()+"mv_\"+idx+\"_ncols.value\");\n"
        js = js + "    setDetailsAll(\""+getSectionPrefix()+"mv\",idx,nrows,ncols,status);\n"
        js = js + "}\n"
        js = js + "\n"
        js = js + "function "+getSectionName()+"MatrixValueNamesRowChecked(idx,"+getSectionPrefix()+"fidx,c"+getSectionPrefix()+"fidx,nrows,ncols) {\n"
        js = js + "    eval(\"var cf = document.tablecreator."+getSectionPrefix()+"mv_\"+idx+\"_\"+"+getSectionPrefix()+"fidx+\"_x.checked;\");\n"
        js = js + "    var status = \"false\";\n"
        js = js + "    if (cf) {\n"
        js = js + "        status = \"true\";\n"
        js = js + "    };  // end if\n"
        js = js + "    setDetailsAllCols(\""+getSectionPrefix()+"mv\",idx,"+getSectionPrefix()+"fidx,nrows,ncols,status);\n"
        js = js + "    nrchecked = getDetailsNRowsChecked(\""+getSectionPrefix()+"mv\",idx,c"+getSectionPrefix()+"fidx,nrows);\n"
        js = js + "    ncchecked = getDetailsNColsChecked(\""+getSectionPrefix()+"mv\",idx,"+getSectionPrefix()+"fidx,ncols);\n"
        js = js + "    if (nrchecked + ncchecked == 0) {\n"
        js = js + "        eval(\"document.tablecreator."+getSectionPrefix()+"_\"+idx+\".checked = false;\");\n"
        js = js + "    } else {\n"
        js = js + "        eval(\"document.tablecreator."+getSectionPrefix()+"_\"+idx+\".checked = true;\");\n"
        js = js + "    };  // end if\n"
        js = js + "}\n"
        js = js + "\n"
        js = js + "function "+getSectionName()+"MatrixValueNamesColChecked(idx,"+getSectionPrefix()+"fidx,c"+getSectionPrefix()+"fidx,nrows,ncols) {\n" 
        js = js + "    eval(\"var cf = document.tablecreator."+getSectionPrefix()+"mv_\"+idx+\"_x_\"+c"+getSectionPrefix()+"fidx+\".checked;\");\n"
        js = js + "    var status = \"false\";\n"
        js = js + "    if (cf) {\n"
        js = js + "        status = \"true\";\n"
        js = js + "    };  // end if\n"
        js = js + "    setDetailsAllRows(\""+getSectionPrefix()+"mv\",idx,c"+getSectionPrefix()+"fidx,nrows,ncols,status);\n"
        js = js + "    nrchecked = getDetailsNRowsChecked(\""+getSectionPrefix()+"mv\",idx,c"+getSectionPrefix()+"fidx,nrows);\n"
        js = js + "    ncchecked = getDetailsNColsChecked(\""+getSectionPrefix()+"mv\",idx,"+getSectionPrefix()+"fidx,ncols);\n"
        js = js + "    if (nrchecked + ncchecked == 0) {\n"
        js = js + "        eval(\"document.tablecreator."+getSectionPrefix()+"_\"+idx+\".checked = false;\");\n"
        js = js + "    } else {\n"
        js = js + "        eval(\"document.tablecreator."+getSectionPrefix()+"_\"+idx+\".checked = true;\");\n"
        js = js + "    };  // end if\n"
        js = js + "}\n"
        js = js + "\n"
        js = js + "function "+getSectionName()+"MatrixValueNamesItemChecked(idx,"+getSectionPrefix()+"fidx,c"+getSectionPrefix()+"fidx,nrows,ncols) {\n" 
        js = js + "    eval(\"var cf = document.tablecreator.ddmv_\"+idx+\"_\"+ddfidx+\"_\"+cddfidx+\".checked;\");\n"
        js = js + "    var status = \"false\";\n"
        js = js + "    if (cf) {\n"
        js = js + "        status = \"true\";\n"
        js = js + "    };  // end if\n"
        js = js + "    setDetails(\""+getSectionPrefix()+"mv\",idx,"+getSectionPrefix()+"fidx,c"+getSectionPrefix()+"fidx,nrows,ncols,status);\n"
        js = js + "    nrchecked = get"+getSectionName()+"NRowsChecked(\""+getSectionPrefix()+"mv\",idx,c"+getSectionPrefix()+"fidx,nrows);\n"
        js = js + "    ncchecked = get"+getSectionName()+"NColsChecked(\""+getSectionPrefix()+"mv\",idx,"+getSectionPrefix()+"fidx,ncols);\n"
        js = js + "    if (nrchecked + ncchecked == 0) {\n"
        js = js + "        eval(\"document.tablecreator."+getSectionPrefix()+"_\"+idx+\".checked = false;\");\n"
        js = js + "    } else {\n"
        js = js + "        eval(\"document.tablecreator."+getSectionPrefix()+"_\"+idx+\".checked = true;\");\n"
        js = js + "    };  // end if\n"
        js = js + "}\n"
        js = js + "\n"
        js = js + "function "+getSectionName()+"FieldValueNamesItemChecked(idx,"+getSectionPrefix()+"fidx,nrows) {\n" 
        js = js + "}\n"
        return js
    end
    
    # Tab Renderer Methods ------------------------------------------------------------------------------
    def renderCheckBoxTag(name,value,checked_flag,onclick_call)
        htmltxt = "<input type=\"checkbox\" name=\""+name+"\" value=\""+value.to_s+"\""
        if checked_flag
            htmltxt = htmltxt + " checked"
        end
        if onclick_call.nil?
            htmltxt = htmltxt + ">"
        else
            htmltxt = htmltxt + " onclick=\""+onclick_call+"\">"
        end
        return htmltxt
    end
    
    def renderTabControls()
        js = ""
        # If no question items defined - just indicate it
        if getNumQuestionItems() == 0
            js = js + "<p/>&nbsp;<br/>"
            js = js + "<p/>&nbsp;<br/>"
            js = js + "<p/>&nbsp;<br/>"
            js = js + "<label for=\"header\">No "+getSectionLabel()+" data defined for this project</label>"
            js = js + "<p/>"
            return js
        end
        
        # Build HTML table
        js = js + "<table class=\"tc_options_table\">\n"
        js = js + "    <tr bgcolor=\"#e0e0e0\">\n"
        js = js + "        <td class=\"tc_options_checkbox\">\n"
        js = js + "        "+renderCheckBoxTag(getSectionPrefix()+"names_all",1,false,getSectionName()+"NamesSelectAll()")+"\n"
        js = js + "        </td>\n"
        js = js + "        <td class=\"tc_options_title\">\n"
        js = js + "        <label for=\""+getSectionPrefix()+"names_all\">Select All Available "+getSectionLabel()+" Data:</label>\n"
        js = js + "        </td>\n"
        js = js + "    </tr>\n"
        rcolor = ["#FFFFFF","#EAEAEA"]
        for ridx in 0..getNumQuestionItems() - 1
            # This should be an object
            datalist = getQuestionConfig(ridx)
            itemname = datalist[0]
            itemdesc = datalist[1]
            itemshow = datalist[2]
            nmatrix = getNumQuestionMatrixConfig(ridx)
            nfields = getNumQuestionFieldConfig(ridx)
            fieldconfig = getQuestionFieldConfig(ridx)
            checked_flag = (itemshow.to_s == "1")
        js = js + "    <tr bgcolor=\""+rcolor[ridx % 2]+"\">\n"
        js = js + "        <td class=\"tc_options_checkbox\">\n"
        js = js + "        "+renderCheckBoxTag(getSectionPrefix()+"_"+ridx.to_s,1,checked_flag,getSectionName()+"NamesItemChecked("+ridx.to_s+")")+"\n"
        js = js + "        </td>\n"
        js = js + "        <td class=\"tc_options_data\">\n"
        js = js + "        ["+ridx.to_s+"] <label for=\""+itemname+"\">"+itemdesc+":</label><br/>\n"
            if nmatrix > 0
                qrnames = getQuestionMatrixRowsConfig(ridx)
                qcnames = getQuestionMatrixColsConfig(ridx)
        js = js + "        <input type=\"hidden\" name=\""+getSectionPrefix()+"mv_"+ridx.to_s+"_nrows\" value=\""+qrnames.size.to_s+"\">\n"
        js = js + "        <input type=\"hidden\" name=\""+getSectionPrefix()+"mv_"+ridx.to_s+"_ncols\" value=\""+qcnames.size.to_s+"\">\n"
        js = js + "        <table class=\"tc_config_matrix\">\n"
        js = js + "            <tr>\n"
        js = js + "                <td>&nbsp;</td>\n"
                cqfidx = 0
                qcnames.each do |colname|
                    checked_flag = (getQuestionMatrixColFlag(ridx,cqfidx).to_s == "1")
        js = js + "                <td class=\"tc_config_colname\">\n"
        js = js + "                "+renderCheckBoxTag(getSectionPrefix()+"mv_"+ridx.to_s+"_x_"+cqfidx.to_s,1,checked_flag,getSectionName()+"MatrixValueNamesColChecked("+ridx.to_s+",0,"+cqfidx.to_s+","+qrnames.size.to_s+","+qcnames.size.to_s+")")+" "+colname+"\n"
        js = js + "                </td>\n"
                    cqfidx = cqfidx + 1
                end
        js = js + "            </tr>\n"
                for qfidx in 0..qrnames.size - 1
                    checked_flag = (getQuestionMatrixRowFlag(ridx,qfidx).to_s == "1")
        js = js + "            <tr>\n"
        js = js + "                <td class=\"tc_config_rowname\">\n"
        js = js + "                "+renderCheckBoxTag(getSectionPrefix()+"mv_"+ridx.to_s+"_"+qfidx.to_s+"_x",1,checked_flag,getSectionName()+"MatrixValueNamesRowChecked("+ridx.to_s+","+qfidx.to_s+",0,"+qrnames.size.to_s+","+qcnames.size.to_s+")")+" "+qrnames[qfidx]+"\n"
        js = js + "                </td>\n"
                    for cqfidx in 0..qcnames.size - 1
                        checked_flag = (getQuestionMatrixFlag(ridx,qfidx,cqfidx).to_s == "1")
        js = js + "                <td class=\"tc_config_data\">\n"
        js = js + "                "+renderCheckBoxTag(getSectionPrefix()+"mv_"+ridx.to_s+"_"+qfidx.to_s+"_"+cqfidx.to_s,1,checked_flag,getSectionName()+"MatrixValueNamesItemChecked("+ridx.to_s+","+qfidx.to_s+","+cqfidx.to_s+","+qrnames.size.to_s+","+qcnames.size.to_s+")")+"\n"
        js = js + "                </td>\n"
                    end
        js = js + "            </tr>\n"
                end
        js = js + "        </table>\n"
            elsif nfields > 0
                # Chris says this scenario is not used - but leave code here for future
                for qfidx in 0..nfields - 1
                    cn = getQuestionFieldName(ridx,qfidx)
                    itemshow = getQuestionFieldFlag(ridx,qfidx)
                    checked_flag = (itemshow.to_s == "1")
        js = js + "        <li>"+renderCheckBoxTag(getSectionPrefix()+"v_"+ridx.to_s+"."+qfidx.to_s+".0",1,checked_flag,getSectionName()+"FieldValueNamesItemChecked("+ridx.to_s+","+qfidx.to_s+","+qrnames.size.to_s+")")+" "+cn+"\n"
                end
            end
        js = js + "        </td>\n"
        js = js + "    </tr>\n"
        end
        js = js + "    <tr bgcolor=\"#ffffff\">\n"
        js = js + "        <td colspan=\"2\">\n"
        js = js + "        <label for=\""+getSectionPrefix()+"rec_all\"><i>Optional:</i></label>\n"
        js = js + "        </td>\n"
        js = js + "    </tr>\n"
        js = js + "    <tr bgcolor=\"#e0e0e0\">\n"
        js = js + "        <td class=\"tc_options_checkbox\">\n"
        js = js + "        "+renderCheckBoxTag(getSectionPrefix()+"rec_all",1,false,getSectionName()+"SelectAll()")+"\n"
        js = js + "        </td>\n"
        js = js + "        <td class=\"tc_options_title\">\n"
        js = js + "        <label for=\""+getSectionPrefix()+"rec_all\">Select All "+getSectionLabel()+" Data:</label>\n"
        js = js + "        </td>\n"
        js = js + "    </tr>\n"
        for ridx in 0..getNumQuestionDetailItems() - 1
            datalist = getQuestionDetailConfig(ridx)
            itemname = datalist[0]
            itemdesc = datalist[1]
            itemshow = datalist[2]
            checked_flag = (itemshow.to_s == "1")
        js = js + "    <tr bgcolor=\""+rcolor[ridx % 2]+"\">\n"
        js = js + "        <td class=\"tc_options_checkbox\">\n"
        js = js + "        "+renderCheckBoxTag(getSectionPrefix()+"rec_"+ridx.to_s,1,checked_flag,getSectionName()+"ItemChecked()")+"\n"
        js = js + "        </td>\n"
        js = js + "        <td class=\"tc_options_data\">\n"
        js = js + "        <label for=\""+itemname+"\">"+itemdesc+"</label>\n"
        js = js + "        </td>\n"
        js = js + "    </tr>\n"
        end
        js = js + "</table>\n"
        return js
    end
    
    # HTML Post Parameters Methods ------------------------------------------------------------------------------
    # This method used to load user selections in params to determine which question/fields to render
    def setSelections(params)
        setRecordDetailSelections(params)
        
        setFieldSelections(params)
    end
    
    def setRecordDetailSelections(params)
        # Record level parameters
        for ridx in 0..getNumQuestionDetailItems() - 1
            param_name = getSectionPrefix().downcase+"rec_"+ridx.to_s
            cfgval = params[param_name]
            if !cfgval.nil?
                showQuestionDetailItem(ridx,cfgval.to_i)
            else
                showQuestionDetailItem(ridx,0)
            end
        end
    end
    
    def setFieldSelections(params)
        # Get Field level parameters -----------------------------------------------------------------------
        for ridx in 0..getNumQuestionItems() - 1
            param_name = getSectionPrefix().downcase+"_"+ridx.to_s
            cfgval = params[param_name]
            if !cfgval.nil?
                showQuestionItem(ridx,cfgval.to_i)
            else
                showQuestionItem(ridx,0)
            end
            setComplexFieldSelections(params,ridx)
        end
        
    end
    
    def setComplexFieldSelections(params,ridx)
        # More complex sections - those including matrices will need to override this method
        nmatrix = getNumQuestionMatrixConfig(ridx)  # Number of matrix questions
        nfields = getNumQuestionFieldConfig(ridx)   # Number of row-only questions
        # First test if this is a matrix question
        if nmatrix > 0
            rnames = getQuestionMatrixRowsConfig(ridx)
            cnames = getQuestionMatrixColsConfig(ridx)
            for rowidx in 0..rnames.size - 1
                param_name = getSectionPrefix().downcase+"mv_"+ridx.to_s+"_"+rowidx.to_s+"_x"
                cfgval = params[param_name]
                if !cfgval.nil?
                    showQuestionMatrixRow(ridx,rowidx,cfgval.to_i)
                else
                    showQuestionMatrixRow(ridx,rowidx,0)
                end
                for colidx in 0..cnames.size - 1
                    if (rowidx == 0)
                        param_name = getSectionPrefix().downcase+"mv_"+ridx.to_s+"_x_"+colidx.to_s
                        cfgval = params[param_name]
                        if !cfgval.nil?
                            showQuestionMatrixCol(ridx,colidx,cfgval.to_i)
                        else
                            showQuestionMatrixCol(ridx,colidx,0)
                        end
                    end
                    param_name = getSectionPrefix().downcase+"mv_"+ridx.to_s+"_"+rowidx.to_s+"_"+colidx.to_s
                    cfgval = params[param_name]
                    if !cfgval.nil?
                        showQuestionMatrix(ridx,rowidx,colidx,cfgval.to_i)
                    else
                        showQuestionMatrix(ridx,rowidx,colidx,0)
                    end
                end
            end
        elsif nfields > 0
            for rowidx in 0..nfields - 1
                param_name = getSectionPrefix().downcase+"v_"+ridx.to_s+"."+rowidx.to_s+".0"
                cfgval = params[param_name]
                if !cfgval.nil?
                    showQuestionField(ridx,rowidx,cfgval.to_i)
                else
                    showQuestionField(ridx,rowidx,0)
                end
            end
        end
    end
    
    def dumpData()
        puts getSectionName()+" @sectionrec_config "+@sectionrec_config.to_s
        puts getSectionName()+" @section_config "+@section_config.to_s
        puts getSectionName()+" @sectionfield_config "+@sectionfield_config.to_s
        puts getSectionName()+" @sectionmatrix_config "+@sectionmatrix_config.to_s
    end
end
