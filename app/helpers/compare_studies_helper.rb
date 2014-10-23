module CompareStudiesHelper
    # This base helper class provides methods to render components in HTML and for EXCEL export. The class is more of a renderer class than a catch-all 
    # utility helper class
    
    # Generalized Renderer Methods with Arm ----------------------------------------------------------------------------------------                                              
    
    # section name and code identifies the section to be rendered by Arm
    # the section code is passed to the other generalized methods in compareset used to invoke the associated methods
    # section name/code are
    # Baseline/BL
    # ArmDetail/armd
    def self.renderHTMLbyArmSelection(section_name,section_code,sidx,compareset,isdiffvalues,arm_idx,arm_id,arm_name,bl_idx,bl_id,armd_name)
        if (arm_id < 0) ||
            (bl_id < 0)
            return ""                                                        
        end          
        htmltext = ""
        if compareset.isComplexByArm(section_name,sidx,arm_id,bl_id)
            # Render an HTML table
            rownames = compareset.getRowNamesByArmByID(section_name,sidx,arm_id,bl_id)
            colnames = compareset.getColNamesByArmByID(section_name,sidx,arm_id,bl_id)
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
                    value = compareset.getMatrixValueByArm(section_name,sidx,arm_id,bl_id,row_idx,col_idx);
                    htmltext = htmltext + "        <td class=\"tc_config_data\">"
                    if isdiffvalues
                        htmltext = htmltext + "        <input type=\"radio\" title=\"Select the value "+value+"\" name=\"merge_"+section_code.downcase+"s_"+arm_idx.to_s+"_"+bl_idx.to_s+"_"+row_idx.to_s+"_"+col_idx.to_s+"\" value=\""+value+"\" onclick=\"select"+section_name+"("+sidx.to_s+","+arm_id.to_s+","+bl_id.to_s+","+row_idx.to_s+","+col_idx.to_s+",\'"+value.to_s+"\')\">"
                    end
                    htmltext = htmltext + "        "+value
                    htmltext = htmltext + "        </td>"
                end                                                    
                htmltext = htmltext + "    <tr>"
            end
            htmltext = htmltext + "</table>"
        else
            value = compareset.getValueByArm(section_name,sidx,arm_id,bl_id)
            value = value.gsub( /\r\n/m, " " )
            htmltext = htmltext + "        <td class=\"tc_config_data\">"
            if isdiffvalues
                htmltext = htmltext + "        <input type=\"radio\" title=\"Select the value "+value+"\" name=\"merge_"+section_code.downcase+"s_"+arm_idx.to_s+"_"+bl_idx.to_s+"_"+row_idx.to_s+"_"+col_idx.to_s+"\" value=\""+value+"\" onclick=\"select"+section_name+"("+sidx.to_s+","+arm_id.to_s+","+bl_id.to_s+",0,0,\'"+value.to_s+"\')\">"
            end
            htmltext = htmltext + "        "+value
            htmltext = htmltext + "        </td>"
        end
        return htmltext
    end
    
    def self.renderHTMLConsensusbyArm(section_name,section_code,sidx,compareset,isdiffvalues,arm_idx,arm_name,bl_idx,bl_name)
        if arm_name.nil? || bl_name.nil?
            return ""
        end          
        # Get default arm and arm detail id from the first selected study (ref)
        sidx = 0
        arm_id = compareset.getArmIDByName(sidx,arm_name)
        bl_id = compareset.getIDByName(section_name,sidx,bl_name)
        htmltext = "consensus data..."
        if compareset.isBaselineComplex(sidx,arm_id,bl_id)
            # Render an HTML table
            rownames = compareset.getRowNamesByArmByID(section_name,sidx,arm_id,bl_id)
            colnames = compareset.getColNamesByArmByID(section_name,sidx,arm_id,bl_id)
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
                    value = "ENTER CONCENSUS VALUE"
                    htmltext = htmltext + "        <td class=\"tc_config_data\">"
                    htmltext = htmltext + "        <input type=\"text\" name=\"merge_"+section_code.tolower+"s_"+arm_idx.to_s+"_"+bl_idx.to_s+"_"+row_idx.to_s+"_"+col_idx.to_s+"\" value=\""+value+"\">"
                    htmltext = htmltext + "        </td>"
                end
                htmltext = htmltext + "    <tr>"
            end
            htmltext = htmltext + "</table>"
        else
            value = "ENTER CONCENSUS VALUE"
            htmltext = htmltext + "        <td class=\"tc_config_data\">"
            htmltext = htmltext + "        <input type=\"text\" name=\"merge_"+section_code.tolower+"s_"+arm_idx.to_s+"_"+bl_idx.to_s+"\" value=\""+value+"\">"
            htmltext = htmltext + "        </td>"
        end
        return htmltext
    end
    
    # Baseline Characteristics Renderer Methods -----------------------------------------------------------------------------------------------                                              
    
    def self.renderBaselineHTMLSelection(sidx,compareset,isdiffvalues,arm_idx,arm_id,arm_name,bl_idx,bl_id,bl_name)
        if (arm_id < 0) ||
            (bl_id < 0)
            return ""
        end          
        htmltext = ""
        if compareset.isBaselineComplex(sidx,arm_id,bl_id)
            # Render an HTML table
            rownames = compareset.getBaselineRowNamesByID(sidx,arm_id,bl_id)
            colnames = compareset.getBaselineColNamesByID(sidx,arm_id,bl_id)
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
                    value = compareset.getBaselineMatrixValue(sidx,arm_id,bl_id,row_idx,col_idx);
                    htmltext = htmltext + "        <td class=\"tc_config_data\">"
                    if isdiffvalues
                        htmltext = htmltext + "        <input type=\"radio\" title=\"Select the value "+value+"\" name=\"merge_bls_"+arm_idx.to_s+"_"+bl_idx.to_s+"_"+row_idx.to_s+"_"+col_idx.to_s+"\" value=\""+value+"\" onclick=\"selectBaseline("+sidx.to_s+","+arm_id.to_s+","+bl_id.to_s+","+row_idx.to_s+","+col_idx.to_s+",\'"+value.to_s+"\')\">"
                    end
                    htmltext = htmltext + "        "+value
                    htmltext = htmltext + "        </td>"
                end
                htmltext = htmltext + "    <tr>"
            end
            htmltext = htmltext + "</table>"
        else
            value = compareset.getBaselineValue(sidx,arm_id,bl_id)
            value = value.gsub( /\r\n/m, " " )
            htmltext = htmltext + "        <td class=\"tc_config_data\">"
            if isdiffvalues
                htmltext = htmltext + "        <input type=\"radio\" title=\"Select the value "+value+"\" name=\"merge_bls_"+arm_idx.to_s+"_"+bl_idx.to_s+"_"+row_idx.to_s+"_"+col_idx.to_s+"\" value=\""+value+"\" onclick=\"selectBaseline("+sidx.to_s+","+arm_id.to_s+","+bl_id.to_s+",0,0,\'"+value.to_s+"\')\">"
            end
            htmltext = htmltext + "        "+value
            htmltext = htmltext + "        </td>"
        end
        return htmltext
    end
    
    def self.renderBaselineHTMLConsensus(sidx,compareset,isdiffvalues,arm_idx,arm_name,bl_idx,bl_name)
        if arm_name.nil? || bl_name.nil?
            return ""
        end          
        # Get default arm and arm detail id from the first selected study (ref)
        sidx = 0
        arm_id = compareset.getArmIDByName(sidx,arm_name)
        bl_id = compareset.getBaselineIDByName(sidx,bl_name)
        htmltext = "consensus data..."
        if compareset.isBaselineComplex(sidx,arm_id,bl_id)
            # Render an HTML table
            rownames = compareset.getBaselineRowNamesByID(sidx,arm_id,bl_id)
            colnames = compareset.getBaselineColNamesByID(sidx,arm_id,bl_id)
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
                    value = "ENTER CONCENSUS VALUE"
                    htmltext = htmltext + "        <td class=\"tc_config_data\">"
                    htmltext = htmltext + "        <input type=\"text\" name=\"merge_bls_"+arm_idx.to_s+"_"+bl_idx.to_s+"_"+row_idx.to_s+"_"+col_idx.to_s+"\" value=\""+value+"\">"
                    htmltext = htmltext + "        </td>"
                end
                htmltext = htmltext + "    <tr>"
            end
            htmltext = htmltext + "</table>"
        else
            value = "ENTER CONCENSUS VALUE"
            htmltext = htmltext + "        <td class=\"tc_config_data\">"
            htmltext = htmltext + "        <input type=\"text\" name=\"merge_bls_"+arm_idx.to_s+"_"+bl_idx.to_s+"\" value=\""+value+"\">"
            htmltext = htmltext + "        </td>"
        end
        return htmltext
    end
    
    # Arm Details Renderer Methods -----------------------------------------------------------------------------------------------                                              
    def self.renderArmDetailsHTMLSelection(sidx,compareset,isdiffvalues,arm_idx,arm_id,arm_name,armd_idx,armd_id,armd_name)
        if (arm_id < 0) ||
            (armd_id < 0)
            return ""
        end          
        htmltext = ""
        if compareset.isArmDetailComplex(sidx,arm_id,armd_id)
            # Render an HTML table
            rownames = compareset.getArmDetailRowNamesByID(sidx,arm_id,armd_id)
            colnames = compareset.getArmDetailColNamesByID(sidx,arm_id,armd_id)
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
                    value = compareset.getArmDetailMatrixValue(sidx,arm_id,armd_id,row_idx,col_idx);
                    htmltext = htmltext + "        <td class=\"tc_config_data\">"
                    if isdiffvalues
                        htmltext = htmltext + "        <input type=\"radio\" title=\"Select the value "+value+"\" name=\"merge_armds_"+arm_idx.to_s+"_"+armd_idx.to_s+"_"+row_idx.to_s+"_"+col_idx.to_s+"\" value=\""+value+"\" onclick=\"selectArmDetail("+sidx.to_s+","+arm_id.to_s+","+armd_id.to_s+","+row_idx.to_s+","+col_idx.to_s+",\'"+value.to_s+"\')\">"
                    end
                    htmltext = htmltext + "        "+value
                    htmltext = htmltext + "        </td>"
                end
                htmltext = htmltext + "    <tr>"
            end
            htmltext = htmltext + "</table>"
        else
            value = compareset.getArmDetailValue(sidx,arm_id,armd_id)
            value = value.gsub( /\r\n/m, " " )
            htmltext = htmltext + "        <td class=\"tc_config_data\">"
            if isdiffvalues
                htmltext = htmltext + "        <input type=\"radio\" title=\"Select the value "+value+"\" name=\"merge_armds_"+arm_idx.to_s+"_"+armd_idx.to_s+"_"+row_idx.to_s+"_"+col_idx.to_s+"\" value=\""+value+"\" onclick=\"selectArmDetail("+sidx.to_s+","+arm_id.to_s+","+armd_id.to_s+",0,0,\'"+value.to_s+"\')\">"
            end
            htmltext = htmltext + "        "+value
            htmltext = htmltext + "        </td>"
        end
        return htmltext
    end
    
    def self.renderArmDetailsHTMLConsensus(sidx,compareset,isdiffvalues,arm_idx,arm_name,armd_idx,armd_name)
        if arm_name.nil? || armd_name.nil?
            return ""
        end          
        # Get default arm and arm detail id from the first selected study (ref)
        sidx = 0
        arm_id = compareset.getArmIDByName(sidx,arm_name)
        armd_id = compareset.getArmDetailIDByName(sidx,armd_name)
        htmltext = "consensus data..."
        if compareset.isArmDetailComplex(sidx,arm_id,armd_id)
            # Render an HTML table
            rownames = compareset.getArmDetailRowNamesByID(sidx,arm_id,armd_id)
            colnames = compareset.getArmDetailColNamesByID(sidx,arm_id,armd_id)
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
                    value = "ENTER CONCENSUS VALUE"
                    htmltext = htmltext + "        <td class=\"tc_config_data\">"
                    htmltext = htmltext + "        <input type=\"text\" name=\"merge_armds_"+arm_idx.to_s+"_"+armd_idx.to_s+"_"+row_idx.to_s+"_"+col_idx.to_s+"\" value=\""+value+"\">"
                    htmltext = htmltext + "        </td>"
                end
                htmltext = htmltext + "    <tr>"
            end
            htmltext = htmltext + "</table>"
        else
            value = "ENTER CONCENSUS VALUE"
            htmltext = htmltext + "        <td class=\"tc_config_data\">"
            htmltext = htmltext + "        <input type=\"text\" name=\"merge_armds_"+arm_idx.to_s+"_"+armd_idx.to_s+"\" value=\""+value+"\">"
            htmltext = htmltext + "        </td>"
        end
        return htmltext
    end
end
