class ReportconfigByArmsData < ReportconfigData
    # ReportconfigByArmsData privide additional methods to support by arms.
    
    def initialize
        super()
        @arms_config = nil      # this is a handle to arms configuration data
    end
    
    # Getter/Setter Methods ----------------------------------------------------------------
    def setArmsConfig(arms_cfg)
        @arms_config = arms_cfg
    end
    
    def getArmsConfig()
        return @arms_config
    end
    
    # Generalized loader methods -----------------------------------------------------------------------------
    def setConfig(reportsetdata)
        # Set the name, description, and prefix to the report set data
        setSectionName(reportsetdata.getSectionName());
        setSectionLabel(reportsetdata.getSectionDescription());
        setSectionPrefix(reportsetdata.getSectionPrefix());
        
        if @rec_config.size() == 0
            @rec_config[getSectionPrefix()+"rec_0"] = ["instruction", "Instruction", 0]
        end
        
        nsize = reportsetdata.getNumDistinctQuestions()
        if nsize > 0
            for idx in 0..nsize - 1
                @section_config[getSectionPrefix()+"_"+idx.to_s] = [reportsetdata.getDistinctQuestionName(idx), reportsetdata.getDistinctQuestionName(idx), 0]
                if (reportsetdata.getNumQuestionRows(idx) == 0) &&
                    (reportsetdata.getNumQuestionCols(idx) == 0)
                    # Single value 
                elsif reportsetdata.getNumQuestionCols(idx) == 0
                    # Row only
                    qrnames = reportsetdat
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
    
    # Generalized data access methods ------------------------------------------------------------------------------
    
    # Render Methods ------------------------------------------------------------------------------
    def getNumArmsToDisplay()
        # Arms must be defined for display
        arms_config = getArmsConfig()
        if (arms_config.nil? ||
            (arms_config.getNumQuestionItems() == 0))
            return 0
        end
        # if render flat - find out how many arms were selected to display, otherwise set to 1 for single cell rendering
        arms_2_show = 0
        if isRenderFlat()
            for aidx in 0..arms_config.getNumQuestionItems() - 1
                if arms_config.showQuestion(aidx)
                    arms_2_show = arms_2_show + 1
                end
            end
        else
            arms_2_show = 1
        end
        return arms_2_show
    end
    
    def getNumQuestionToDisplay()
        q_ncols = 0;
        arms_2_show = getNumArmsToDisplay()
        # Now count how many questions to show - adjusting for complex questions
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
        return (arms_2_show * q_ncols) 
    end
    
    def getNumQuestionToDisplayFlat(ridx)
        n_cols = 0
        arms_2_show = getNumArmsToDisplay()
        for ridx in 0..getNumQuestionItems() - 1
            if showQuestion(ridx)
                nc = getQuestionMatrixNCols(ridx)
                nr = getQuestionMatrixNRows(ridx)
                n_cols = n_cols + (nr * nc)
            end
        end
        return (arms_2_show * n_cols)
    end
    
    def getDisplayTitles()
        disp_list = Array.new;
        # Arms must be defined for display
        arms_config = getArmsConfig()
        if (arms_config.nil? ||
            (arms_config.getNumQuestionItems() == 0))
            return disp_list
        end
        for armidx in 0..arms_config.getNumQuestionItems() - 1
            if arms_config.showQuestion(armidx)
                arm = arms_config.getQuestionName(armidx)
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
                                disp_list << "["+arm+"]["+qname+"]"
                            elsif (cnames.size() == 0)
                                rnames.each do |rn|
                                    qfidx = qrnames.index(rn)
                                    if getQuestionFieldFlag(ridx,qfidx) == 1
                                        disp_list << "["+arm+"]["+qname+"]["+rn+"]"
                                    end
                                end
                            else
                                rnames.each do |rn|
                                    qfidx = qrnames.index(rn)
                                    cnames.each do |cn|
                                        cqfidx = qcnames.index(cn)
                                        if getQuestionMatrixFlag(ridx,qfidx,cqfidx) == 1
                                            disp_list << "["+arm+"]["+qname+"]["+rn+"]["+cn+"]"
                                        end
                                    end
                                end
                            end
                        else
                            disp_list << qname
                        end
                    end
                end
            end
        end
        return disp_list 
    end
    
    # EXCEL Export Methods ------------------------------------------------------------------------------
    def getTotalQuestionEXCELSpanByArm(arm_id,reportsetdata)
        q_ncols = 0
        for qidx in 0..getNumQuestionItems() - 1
            if showQuestions(qidx)
                # For each questions to show - get the total number columns to support the export of this questions
                q_ncols = q_ncols + getQuestionEXCELSpanByArm(arm_id,qidx,reportsetdata)
            end
        end
        return q_ncols
    end
    
    def getQuestionEXCELSpanByArm(arm_id,qidx,reportsetdata)
        q_name = getQuestionNameByArm(arm_id,qidx)
        return reportsetdata.getQuestionEXCELSpanByArm(arm_id,q_name)
    end
    
    def getQuestionEXCELLabelsByArm(arm_id,qidx,reportsetdata)
        q_name = getQuestionName(arm_id,qidx)
        return reportsetdata.getQuestionEXCELLabelsByArm(arm_id,q_name) 
    end
    
    def getQuestionEXCELValuesByArm(sidx,arm_id,qidx,reportsetdata)
        q_name = getQuestionNameByArm(arm_id,qidx)
        q_values = reportsetdata.getQuestionEXCELValuesByArm(sidx,arm_id,q_name);
        return q_values
    end
end
