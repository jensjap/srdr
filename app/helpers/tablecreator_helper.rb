module TablecreatorHelper
    # This helper class provides methods to render components in HTML and for EXCEL export. The class is more of a renderer class than a catch-all 
    # utility helper class
    
    # Arm Details Helper methods -----------------------------------------------------------------------------------------------------------------
    
    def self.renderArmDetails(sidx,tc_project)
        prj_id = tc_project["prjid"]
        reportset = tc_project["reportset"] 
        reportconfig = tc_project["reportconfig"] 
        if (reportconfig.getNumArmDetailsItems() > 0) &&
            (reportconfig.getNumArmsItems() > 0)
            for armidx in 0..reportconfig.getNumArmsItems() - 1
                if reportconfig.showArms(armidx)
                    arm_name = reportset.getArmName(armidx)
                    # Each study has a different arm_id and arm detail id even though it is the same name
                    arm_id = reportset.getArmIDByName(sidx,arm_name)
                    if reportset.containsArmName(sidx,reportconfig.getArmsName(armidx))
                        for armdidx in 0..reportconfig.getNumArmDetailsItems() - 1
                            armd_name = reportset.getArmDetailName(sidx,armdidx)
                            armd_id = reportset.getArmDetailIDByName(sidx,armd_name)
                            if reportset.isArmDetailComplex(sidx,arm_id,armd_id)
                                rownames = reportset.getArmDetailRowNamesByID(sidx,arm_id,armd_id)
                                colnames = reportset.getArmDetailColNamesByID(sidx,arm_id,armd_id)
                                puts ">>>>>>>>>>> tablecreator_helper::renderArmDetails("+sidx.to_s+",project) study "+reportset.getStudyID(sidx).to_s+"- arm="+arm_name+" arm detail="+armd_name
                                puts ">>>>>>>>>>> tablecreator_helper::renderArmDetails - rows "+rownames.to_s
                                puts ">>>>>>>>>>> tablecreator_helper::renderArmDetails - cols "+colnames.to_s
                                for ridx in 0..rownames.size() - 1
                                    for cidx in 0..colnames.size() - 1
                                        value = reportset.getArmDetailMatrixValue(sidx,arm_id,armd_id,ridx,cidx);
                                        puts ">>>>>>>>>>> tablecreator_helper::renderArmDetails - value("+arm_id.to_s+","+armd_id.to_s+","+ridx.to_s+","+cidx.to_s+") "+value.to_s
                                    end
                                end
                            else
                                
                            end
                        end
                    end
                end
            end
        end
    end
    
    def self.renderArmDetailsHTMLTableCell(sidx,tc_project,arm_id,arm_name,armd_id,armd_name)
        prj_id = tc_project["prjid"]
        reportset = tc_project["reportset"] 
        reportconfig = tc_project["reportconfig"] 
        if (arm_id < 0) ||
            (armd_id < 0)
            return ""
        end
        # Render an HTML table
        rownames = reportset.getArmDetailRowNamesByID(sidx,arm_id,armd_id)
        colnames = reportset.getArmDetailColNamesByID(sidx,arm_id,armd_id)
        htmltext = ""
        htmltext = htmltext + "<table class=\"tc_config_matrix\">"
        # Render col header row
        htmltext = htmltext + "    <tr>"
        htmltext = htmltext + "        <td class=\"tc_config_armname\">"
        htmltext = htmltext + "        Arm: "+arm_name
        htmltext = htmltext + "        </td>"
        for col_idx in 0..colnames.size() - 1
            htmltext = htmltext + "        <td class=\"tc_config_colname\">"
            htmltext = htmltext + "        "+colnames[col_idx]
            htmltext = htmltext + "        </td>"
        end
        htmltext = htmltext + "    </tr>"
        # Render each row
        for row_idx in 0..rownames.size() - 1
            htmltext = htmltext + "    <tr>"
            htmltext = htmltext + "        <td class=\"tc_config_rowname\">"
            htmltext = htmltext + "        "+rownames[row_idx]
            htmltext = htmltext + "        </td>"
            for col_idx in 0..colnames.size() - 1
                value = reportset.getArmDetailMatrixValue(sidx,arm_id,armd_id,row_idx,col_idx);
                htmltext = htmltext + "        <td class=\"tc_config_data\">"
                htmltext = htmltext + "        "+TextUtil.restoreCodedText(value)
                htmltext = htmltext + "        </td>"
            end
            htmltext = htmltext + "    <tr>"
        end
        htmltext = htmltext + "</table>"
    end
    
    
=begin
    def self.renderArmDetailsHTMLSelection(sidx,tc_project,arm_idx,arm_id,arm_name,armd_idx,armd_id,armd_name)
        prj_id = tc_project["prjid"]
        reportset = tc_project["reportset"] 
        reportconfig = tc_project["reportconfig"] 
        if (arm_id < 0) ||
            (armd_id < 0)
            return ""
        end          
        htmltext = ""
        if reportset.isArmDetailComplex(sidx,arm_id,armd_id)
            # Render an HTML table
            rownames = reportset.getArmDetailRowNamesByID(sidx,arm_id,armd_id)
            colnames = reportset.getArmDetailColNamesByID(sidx,arm_id,armd_id)
            htmltext = htmltext + "<table class=\"tc_config_matrix\">"
            # Render col header row
            htmltext = htmltext + "    <tr>"
            htmltext = htmltext + "        <td class=\"tc_config_armname\">"
            htmltext = htmltext + "        Arm: "+arm_name
            htmltext = htmltext + "        </td>"
            for col_idx in 0..colnames.size() - 1
                htmltext = htmltext + "        <td class=\"tc_config_colname\">"
                htmltext = htmltext + "        "+colnames[col_idx]
                htmltext = htmltext + "        </td>"
            end
            htmltext = htmltext + "    </tr>"
            # Render each row
            for row_idx in 0..rownames.size() - 1
                htmltext = htmltext + "    <tr>"
                htmltext = htmltext + "        <td class=\"tc_config_rowname\">"
                htmltext = htmltext + "        "+rownames[row_idx]
                htmltext = htmltext + "        </td>"
                for col_idx in 0..colnames.size() - 1
                    value = reportset.getArmDetailMatrixValue(sidx,arm_id,armd_id,row_idx,col_idx);
                    htmltext = htmltext + "        <td class=\"tc_config_data\">"
                    htmltext = htmltext + "        <input type=\"radio\" title=\"Select the value "+value+"\" name=\"merge_armds_"+arm_idx.to_s+"_"+armd_idx.to_s+"_"+row_idx.to_s+"_"+col_idx.to_s+"\" value=\""+value+"\" onclick=\"selectArmDetail("+sidx.to_s+","+arm_id.to_s+","+armd_id.to_s+","++","++",\'"+value.to_s+"\')\">"
                    htmltext = htmltext + "        "+TextUtil.restoreCodedText(value)
                    htmltext = htmltext + "        </td>"
                end
                htmltext = htmltext + "    <tr>"
            end
            htmltext = htmltext + "</table>"
        else
            value = reportset.getArmDetailValue(sidx,arm_id,armd_id)
            value = value.gsub( /\r\n/m, " " )
            htmltext = htmltext + "        <td class=\"tc_config_data\">"
            htmltext = htmltext + "        <input type=\"radio\" title=\"Select the value "+value+"\" name=\"merge_armds_"+arm_idx.to_s+"_"+armd_idx.to_s+"_"+row_idx.to_s+"_"+col_idx.to_s+"\" value=\""+value+"\" onclick=\"selectArmDetail("+sidx.to_s+","+arm_id.to_s+","+armd_id.to_s+","++","++",\'"+value.to_s+"\')\">"
            htmltext = htmltext + "        "+value
            htmltext = htmltext + "        </td>"
        end
        return htmltext
    end
    
    def self.renderArmDetailsHTMLConsensus(sidx,tc_project,compareset,isdiffvalues,arm_idx,arm_name,armd_idx,armd_name)
        prj_id = tc_project["prjid"]
        reportset = tc_project["reportset"] 
        if arm_name.nil? || armd_name.nil?
            return ""
        end          
        # Get default arm and arm detail id from the first selected study (ref)
        arm_id = compareset.getArmIDByName(0,arm_name)
        armd_id = compareset.getArmDetailIDByName(0,armd_name)
        htmltext = "consensus data..."
        if compareset.isArmDetailComplex(sidx,arm_id,armd_id)
        else
        end
        return htmltext
    end
=end

    # Design Details Helper methods -----------------------------------------------------------------------------------------------------------------
    def self.renderDesignDetails(sidx,tc_project)
        prj_id = tc_project["prjid"]
        reportset = tc_project["reportset"] 
        reportconfig = tc_project["reportconfig"] 
        if (reportconfig.getNumDesignDetailsItems() > 0) &&
            (reportconfig.getNumDesignsItems() > 0)
            for ddidx in 0..reportconfig.getNumDesignDetailsItems() - 1
                dd_name = reportset.getDesignDetailName(sidx,ddidx)
                dd_id = reportset.getDesignDetailIDByName(sidx,dd_name)
                if reportset.isDesignDetailComplex(sidx,dd_id)
                    rownames = reportset.getDesignDetailRowNamesByID(sidx,dd_id)
                    colnames = reportset.getDesignDetailColNamesByID(sidx,dd_id)
                    for ridx in 0..rownames.size() - 1
                        for cidx in 0..colnames.size() - 1
                            value = reportset.getDesignDetailMatrixValue(sidx,dd_id,ridx,cidx);
                        end
                    end
                else
                    
                end
            end
        end
    end
    
    def self.renderDesignDetailsHTMLTableCell(sidx,tc_project,dd_id,dd_name)
        prj_id = tc_project["prjid"]
        reportset = tc_project["reportset"] 
        reportconfig = tc_project["reportconfig"] 
        if (dd_id < 0)
            return ""
        end
        # Render an HTML table
        rownames = reportset.getDesignDetailRowNamesByID(sidx,dd_id)
        colnames = reportset.getDesignDetailColNamesByID(sidx,dd_id)
        htmltext = ""
        htmltext = htmltext + "<table class=\"tc_config_matrix\">"
        # Render col header row
        htmltext = htmltext + "    <tr>"
        htmltext = htmltext + "        <td class=\"tc_config_armname\">"
        htmltext = htmltext + "        &nbsp;"
        htmltext = htmltext + "        </td>"
        for col_idx in 0..colnames.size() - 1
            htmltext = htmltext + "        <td class=\"tc_config_colname\">"
            htmltext = htmltext + "        "+colnames[col_idx]
            htmltext = htmltext + "        </td>"
        end
        htmltext = htmltext + "    </tr>"
        # Render each row
        for row_idx in 0..rownames.size() - 1
            htmltext = htmltext + "    <tr>"
            htmltext = htmltext + "        <td class=\"tc_config_rowname\">"
            htmltext = htmltext + "        "+rownames[row_idx]
            htmltext = htmltext + "        </td>"
            for col_idx in 0..colnames.size() - 1
                value = reportset.getDesignDetailMatrixValue(sidx,dd_id,row_idx,col_idx);
                htmltext = htmltext + "        <td class=\"tc_config_data\">"
                htmltext = htmltext + "        "+TextUtil.restoreCodedText(value)
                htmltext = htmltext + "        </td>"
            end
            htmltext = htmltext + "    <tr>"
        end
        htmltext = htmltext + "</table>"
    end

    # Outcome Details Helper methods -----------------------------------------------------------------------------------------------------------------
    def self.renderOutcomeDetails(sidx,tc_project)
        prj_id = tc_project["prjid"]
        reportset = tc_project["reportset"] 
        reportconfig = tc_project["reportconfig"] 
        if (reportconfig.getNumOutcomeDetailsItems() > 0) &&
            (reportconfig.getNumOutcomesItems() > 0)
            for outdidx in 0..reportconfig.getNumOutcomeDetailsItems() - 1
                outd_name = reportset.getOutcomeDetailName(sidx,outdidx)
                outd_id = reportset.getOutcomeDetailIDByName(sidx,outd_name)
                if reportset.isOutcomeDetailComplex(sidx,outd_id)
                    rownames = reportset.getOutcomeDetailRowNamesByID(sidx,outd_id)
                    colnames = reportset.getOutcomeDetailColNamesByID(sidx,outd_id)
                    for ridx in 0..rownames.size() - 1
                        for cidx in 0..colnames.size() - 1
                            value = reportset.getOutcomeDetailMatrixValue(sidx,outd_id,ridx,cidx);
                        end
                    end
                else
                    
                end
            end
        end
    end
    
    def self.renderOutcomeDetailsHTMLTableCell(sidx,tc_project,outd_id,outd_name)
        prj_id = tc_project["prjid"]
        reportset = tc_project["reportset"] 
        reportconfig = tc_project["reportconfig"] 
        if (outd_id < 0)
            return ""
        end
        # Render an HTML table
        rownames = reportset.getOutcomeDetailRowNamesByID(sidx,outd_id)
        colnames = reportset.getOutcomeDetailColNamesByID(sidx,outd_id)
        htmltext = ""
        htmltext = htmltext + "<table class=\"tc_config_matrix\">"
        # Render col header row
        htmltext = htmltext + "    <tr>"
        htmltext = htmltext + "        <td class=\"tc_config_armname\">"
        htmltext = htmltext + "        &nbsp;"
        htmltext = htmltext + "        </td>"
        for col_idx in 0..colnames.size() - 1
            htmltext = htmltext + "        <td class=\"tc_config_colname\">"
            htmltext = htmltext + "        "+colnames[col_idx]
            htmltext = htmltext + "        </td>"
        end
        htmltext = htmltext + "    </tr>"
        # Render each row
        for row_idx in 0..rownames.size() - 1
            htmltext = htmltext + "    <tr>"
            htmltext = htmltext + "        <td class=\"tc_config_rowname\">"
            htmltext = htmltext + "        "+rownames[row_idx]
            htmltext = htmltext + "        </td>"
            for col_idx in 0..colnames.size() - 1
                value = reportset.getOutcomeDetailMatrixValue(sidx,outd_id,row_idx,col_idx);
                htmltext = htmltext + "        <td class=\"tc_config_data\">"
                htmltext = htmltext + "        "+TextUtil.restoreCodedText(value)
                htmltext = htmltext + "        </td>"
            end
            htmltext = htmltext + "    <tr>"
        end
        htmltext = htmltext + "</table>"
    end
    
    # Baseline Helper methods -----------------------------------------------------------------------------------------------------------------
    def self.renderBaseline(sidx,tc_project)
        prj_id = tc_project["prjid"]
        reportset = tc_project["reportset"] 
        reportconfig = tc_project["reportconfig"] 
        if (reportconfig.getNumBaselineItems() > 0) &&
            (reportconfig.getNumArmsItems() > 0)
            for armidx in 0..reportconfig.getNumArmsItems() - 1
                if reportconfig.showArms(armidx)
                    arm_name = reportset.getArmName(armidx)
                    # Each study has a different arm_id and arm detail id even though it is the same name
                    arm_id = reportset.getArmIDByName(sidx,arm_name)
                    if reportset.containsArmName(sidx,reportconfig.getArmsName(armidx))
                        for armdidx in 0..reportconfig.getNumBaselineItems() - 1
                            bl_name = reportset.getBaselineName(sidx,armdidx)
                            bl_id = reportset.getBaselineIDByName(sidx,bl_name)
                            if reportset.isBaselineComplex(sidx,arm_id,bl_id)
                                rownames = reportset.getBaselineRowNamesByID(sidx,arm_id,bl_id)
                                colnames = reportset.getBaselineColNamesByID(sidx,arm_id,bl_id)
                                for ridx in 0..rownames.size() - 1
                                    for cidx in 0..colnames.size() - 1
                                        value = reportset.getBaselineMatrixValue(sidx,arm_id,bl_id,ridx,cidx);
                                    end
                                end
                            else
                                
                            end
                        end
                    end
                end
            end
        end
    end
    
    def self.renderBaselineHTMLTableCell(sidx,tc_project,arm_id,arm_name,bl_id,bl_name)
        prj_id = tc_project["prjid"]
        reportset = tc_project["reportset"] 
        reportconfig = tc_project["reportconfig"] 
        if (arm_id < 0) ||
            (bl_id < 0)
            return ""
        end
        # Render an HTML table
        rownames = reportset.getBaselineRowNamesByID(sidx,arm_id,bl_id)
        colnames = reportset.getBaselineColNamesByID(sidx,arm_id,bl_id)
        htmltext = ""
        htmltext = htmltext + "<table class=\"tc_config_matrix\">"
        # Render col header row
        htmltext = htmltext + "    <tr>"
        htmltext = htmltext + "        <td class=\"tc_config_armname\">"
        htmltext = htmltext + "        Arm: "+arm_name
        htmltext = htmltext + "        </td>"
        for col_idx in 0..colnames.size() - 1
            htmltext = htmltext + "        <td class=\"tc_config_colname\">"
            htmltext = htmltext + "        "+colnames[col_idx]
            htmltext = htmltext + "        </td>"
        end
        htmltext = htmltext + "    </tr>"
        # Render each row
        for row_idx in 0..rownames.size() - 1
            htmltext = htmltext + "    <tr>"
            htmltext = htmltext + "        <td class=\"tc_config_rowname\">"
            htmltext = htmltext + "        "+rownames[row_idx]
            htmltext = htmltext + "        </td>"
            for col_idx in 0..colnames.size() - 1
                value = reportset.getBaselineMatrixValue(sidx,arm_id,bl_id,row_idx,col_idx);
                htmltext = htmltext + "        <td class=\"tc_config_data\">"
                htmltext = htmltext + "        "+TextUtil.restoreCodedText(value)
                htmltext = htmltext + "        </td>"
            end
            htmltext = htmltext + "    <tr>"
        end
        htmltext = htmltext + "</table>"
    end
end
