###############################################################################
# This class contains code for exporting various parts of a systematic review #
# to Microsoft Excel format. 												  #
###############################################################################

class TCWordExport
	
	# export all data specified in the table creator configuration for this project
	def self.project_to_word proj_id, efcount, tc_project, tc_options, table_formconfig, user 
		# Pull TC data from the session object
        # efcount = session[:tc_efcount]
        # Load display configuration data
        # tc_project = session[:tc_project]
        # tc_options = session[:tc_options]
        # table_formconfig = session[:tc_formconfig]
        table_config = tc_options["config"]
        
		# Use a MS XML Word Template to construct the report file =================================
        # First load part 1, then fill-in the table creator contents and then load part 2
        # Setup and return the results as a blob
		blob = StringIO.new("")
        tfile = File.open("reports/docments/WordTemplateP1.xml")
        tfile.each {|line|
            blob << line
        }
        #----------------- General line format ---------------------
        #        <w:p w:rsidR="00CC7AAF" w:rsidRDefault="00C67F51">
        #            <w:pPr>
        #                <w:spacing w:after="0"/>
        #            </w:pPr>
        #            <w:r>
        #                <w:t>[Data Text Goes Here]</w:t>
        #            </w:r>
        #        </w:p>
        #----------------- General line format ---------------------
        
	    user_info = user.to_string
        
        # Render top level project information ========================================================================
        prj = tc_project["project"]
        prj_id = prj.id
        prj_title = prj.title
        project_config = table_config["tablecreator-projects"]
        blob << getWordLine("Creator "+user_info)
        blob << getWordLine("Organization "+user.organization)
        blob << getWordLine("Project "+prj_title+" ["+prj_id.to_s+"]")
        if !project_config.nil?
            prj_keys = project_config.keys
            project_formconfig = table_formconfig["tablecreator-projects"];
            if project_formconfig.nil?
                project_formconfig = Hash.new
            end
            prj = tc_project["project"]
            for pk in prj_keys
                datalist = project_config[pk]
                dbtablename = datalist[0]
                dbfieldname = datalist[1]
                tmpa = datalist[2].split("=>")
                title = tmpa[1]
                datavalue = prj[dbfieldname]
                if (!project_formconfig.nil? && !project_formconfig[dbtablename+"_"+pk].nil? && project_formconfig[dbtablename+"_"+pk] == "1")
                    blob << getWordLine(title+" "+datavalue)
                end
            end
        end
        # Now render publications data by EF ========================================================================
        if !project_config.nil?
            # First get which publication fields to display
            pub_config = table_config["tablecreator-pub"]
            pub_keys = Array.new
            if !pub_config.nil?
                pub_keys = pub_config.keys
            end
            pub_formconfig = table_formconfig["tablecreator-pub"];
            if pub_formconfig.nil?
                pub_formconfig = Hash.new
            end
            show_pub_fields = Array.new
            for pk in pub_keys
                datalist = pub_config[pk]
                dbtablename = datalist[0]
                dbfieldname = datalist[1]
                tmpa = datalist[2].split("=>")
                title = tmpa[1]
                if (!pub_formconfig.nil? && !pub_formconfig[dbtablename+"_"+pk].nil? && pub_formconfig[dbtablename+"_"+pk].to_s == "1")
                    show_pub_fields << dbfieldname
                end
            end
            
            armsnames_config = table_config["tablecreator-armsnames"]
            armsnames_keys = Array.new
            if !armsnames_config.nil?
                armsnames_keys = armsnames_config.keys
            end
            armsnames_formconfig = table_formconfig["tablecreator-armsnames"];
            if armsnames_formconfig.nil?
                armsnames_formconfig = Hash.new
            end
            show_armsnames_fields = Array.new
            for pk in armsnames_keys
                datalist = armsnames_config[pk]
                dbtablename = datalist[0]
                if (!armsnames_formconfig.nil? && !armsnames_formconfig[dbtablename+"_"+pk].nil? && armsnames_formconfig[dbtablename+"_"+pk].to_s == "1")
                    show_armsnames_fields << pk
                end
            end
            # Arms details form checkboxes
            arms_config = table_config["tablecreator-arms"]
            arms_keys = Array.new
            if !arms_config.nil?
                arms_keys = arms_config.keys
            end
            arms_formconfig = table_formconfig["tablecreator-arms"];
            if arms_formconfig.nil?
                arms_formconfig = Hash.new
            end
            show_arms_fields = Array.new
            for pk in arms_keys
                datalist = arms_config[pk]
                dbtablename = datalist[0]
                dbfieldname = datalist[1]
                if (!arms_formconfig.nil? && !arms_formconfig[dbtablename+"_"+pk].nil? && arms_formconfig[dbtablename+"_"+pk].to_s == "1")
                    show_arms_fields << dbfieldname
                end
            end
            
            designnames_config = table_config["tablecreator-designnames"]
            design_keys = Array.new
            if !designnames_config.nil?
                design_keys = designnames_config.keys
            end
            # Selected design data element names
            designnames_formconfig = table_formconfig["tablecreator-designnames"]
            show_design_fields = Array.new
            for pk in design_keys
                datalist = designnames_config[pk]
                dbtablename = datalist[0]
                if (!designnames_formconfig.nil? && !designnames_formconfig[dbtablename+"_"+pk].nil? && designnames_formconfig[dbtablename+"_"+pk].to_s == "1")
                    show_design_fields << pk
                end
            end
            
            # In the case of baseline characteristics - there is only a name=value pair
            baseline_config = table_config["tablecreator-baseline"]
            baseline_keys = Array.new
            if !baseline_config.nil?
                baseline_keys = baseline_config.keys
            end
            # Selected baseline data element names
            baseline_formconfig = table_formconfig["tablecreator-baseline"]
            show_baseline_fields = Array.new
            for pk in baseline_keys
                datalist = baseline_config[pk]
                dbtablename = datalist[0]
                if (!baseline_formconfig.nil? && !baseline_formconfig[dbtablename+"_"+pk].nil? && baseline_formconfig[dbtablename+"_"+pk].to_s == "1")
                    show_baseline_fields << pk
                end
            end
            
            # Outcomes data points - name=value pair
            # Selected outcomes data element name list
            outcomes_config = table_config["tablecreator-outcomesnames"]
            outcomes_keys = Array.new
            if !outcomes_config.nil?
                outcomes_keys = outcomes_config.keys
            end
            # Selected list of adverse events checkbox list to find out which names were selected for display
            outcomesnames_formconfig = table_formconfig["tablecreator-outcomesnames"]
            show_outcomes_fields = Array.new
            for pk in outcomes_keys
                datalist = outcomes_config[pk]
                dbtablename = datalist[0]
                if (!outcomesnames_formconfig.nil? && !outcomesnames_formconfig[dbtablename+"_"+pk].nil? && outcomesnames_formconfig[dbtablename+"_"+pk].to_s == "1")
                    show_outcomes_fields << pk
                end
            end
            
            # Adverse events data points - name=value pair
            # Selected adverse events data element name list
            advevents_config = table_config["tablecreator-adveventsnames"]
            advevents_keys = Array.new
            if !advevents_config.nil?
                advevents_keys = advevents_config.keys
            end
            # Selected list of adverse events checkbox list to find out which names were selected for display
            adveventsnames_formconfig = table_formconfig["tablecreator-adveventsnames"]
            show_advevents_fields = Array.new
            for pk in advevents_keys
                datalist = advevents_config[pk]
                dbtablename = datalist[0]
                if (!adveventsnames_formconfig.nil? && !adveventsnames_formconfig[dbtablename+"_"+pk].nil? && adveventsnames_formconfig[dbtablename+"_"+pk].to_s == "1")
                    show_advevents_fields << pk
                end
            end
            
            # Quality dimensions data points - name=value pair and two value attributes - <VALUE>|<NOTES>
            # Selected quality dimensions data element name list
            qualdimfields_config = table_config["tablecreator-qualdimfieldsnames"]
            qualdimfields_keys = Array.new
            if !qualdimfields_config.nil?
                qualdimfields_keys = qualdimfields_config.keys
            end
            # Selected list of quality dimention checkbox list to find out which names were selected for display
            qualdimfieldsnames_formconfig = table_formconfig["tablecreator-qualdimfieldsnames"]
            show_qualdimfields_fields = Array.new
            for pk in qualdimfields_keys
                datalist = qualdimfields_config[pk]
                dbtablename = datalist[0]
                if (!qualdimfieldsnames_formconfig.nil? && !qualdimfieldsnames_formconfig[dbtablename+"_"+pk].nil? && qualdimfieldsnames_formconfig[dbtablename+"_"+pk].to_s == "1")
                    show_qualdimfields_fields << pk
                end
            end
            
            # Iterate through each EF within the project
            # Determine if render table by Arms or Flat
            efcount = 0
            ef = tc_project["ef"+efcount.to_s]
            
            # Render publication data by EF
            while !ef.nil? do
                study_ids = tc_project["ef"+efcount.to_s+"-study_ids"]
                studies = tc_project["ef"+efcount.to_s+"-studies"]
                #worksheet.row(rowidx).concat ["Extraction Form: "+ef.title+" ["+ef.id.to_s+"]"]
                #rowidx = rowidx + 1
                
                arms = tc_project["ef"+efcount.to_s+"-arms"]
                if !arms.nil? &&
                   (arms.size > 1) &&
                   !arms_formconfig.nil? &&
                   !arms_formconfig["format_by_arms"].nil? &&
                   (arms_formconfig["format_by_arms"].to_s == "1")
                    # ================= previewByArms ======================
                    for arm in arms
                        arm_info = ""
                        for apk in show_arms_fields
                            if arm_info.length > 0
                                arm_info << "<br/>"
                            end
                            arm_info << arm[apk].to_s
                        end
                        #worksheet.row(rowidx).concat ["Arm:"+arm_info]
                        #rowidx = rowidx + 1
                        # Title row ----------------------------------------------------
                        #worksheet.row(rowidx).push "Publication"
                        if show_design_fields.size > 0
                            #worksheet.row(rowidx).push "Design Details"
                            if show_design_fields.size > 1
                                for i in 2..show_design_fields.size
                                    #worksheet.row(rowidx).push " "
                                end
                            end
                        end 
                        if show_baseline_fields.size > 0
                            #worksheet.row(rowidx).push "Baseline Characteristics"
                            if show_baseline_fields.size > 1
                                for i in 2..show_baseline_fields.size
                                    #worksheet.row(rowidx).push " "
                                end
                            end
                        end 
                        if show_outcomes_fields.size > 0
                            #worksheet.row(rowidx).push "Outcomes"
                            if show_outcomes_fields.size > 1
                                for i in 2..show_outcomes_fields.size
                                    #worksheet.row(rowidx).push " "
                                end
                            end
                        end 
                        if show_advevents_fields.size > 0
                            #worksheet.row(rowidx).push "Adverse Events"
                            if show_advevents_fields.size > 1
                                for i in 2..show_advevents_fields.size
                                    #worksheet.row(rowidx).push " "
                                end
                            end
                        end 
                        if show_qualdimfields_fields.size > 0
                            #worksheet.row(rowidx).push "Quality Dimentions"
                            if show_qualdimfields_fields.size > 1
                                for i in 2..show_qualdimfields_fields.size
                                    #worksheet.row(rowidx).push " "
                                end
                            end
                        end 
                        rowidx = rowidx + 1
                        # Title sub row ----------------------------------------------------
                        #worksheet.row(rowidx).push " "
                        if show_design_fields.size > 0
                            # Use the previously loaded designnames_config[] Hash to get design detail name for the header
                            for pk in show_design_fields
                                dd = designnames_config[pk]
                                tmpd = dd[2].split("=>")
                                title = tmpd[1]
                                #worksheet.row(rowidx).push title
                            end
                        end
                        if show_baseline_fields.size > 0
                            # Use the previously loaded baseline_config[] Hash to get baseline characteristic name for the header
                            for pk in show_baseline_fields
                                dd = baseline_config[pk]
                                tmpd = dd[2].split("=>")
                                title = tmpd[1]
                                #worksheet.row(rowidx).push title
                            end
                        end
                        if show_outcomes_fields.size > 0
                            # Use the previously loaded outcomes_config[] Hash to get outcomes title for the header
                            for pk in show_outcomes_fields
                                dd = outcomes_config[pk]
                                tmpd = dd[2].split("=>")
                                title = tmpd[1]
                                #worksheet.row(rowidx).push title
                            end
                        end
                        if show_advevents_fields.size > 0
                            # Use the previously loaded advevents_config[] Hash to get adverse events name for the header
                            for pk in show_advevents_fields
                                dd = advevents_config[pk]
                                tmpd = dd[2].split("=>")
                                title = tmpd[1]
                                #worksheet.row(rowidx).push title
                            end
                        end
                        if show_qualdimfields_fields.size > 0
                            # Use the previously loaded qualdimfields_formconfig[] Hash to get quality dimension name for the header
                            for pk in show_qualdimfields_fields
                                dd = qualdimfields_config[pk]
                                tmpd = dd[2].split("=>")
                                title = tmpd[1]
                                puts ".... render titles pk = "+pk+" dd rec "+dd.to_s+" >>> tmpd "+tmpd.to_s
                                #worksheet.row(rowidx).push title
                            end
                        end
                        rowidx = rowidx + 1
                        # Publication data rows ----------------------------------------------------
                        for pub in studies
                            puts "......... pub "+pub.to_s
                            pub_info = ""
                            for pubfield in show_pub_fields
                                if pub_info.length > 0
                                    pub_info << "<br/>"
                                end
                                pub_info << pub[pubfield].to_s
                            end
                            #worksheet.row(rowidx).push "["+efcount.to_s+"] "+pub_info
                            if show_design_fields.size > 0
                                ddsvalues = tc_project["ef"+efcount.to_s+"-designvalues"]
                                for pk in show_design_fields
                                    ddvalue = ddsvalues[pk]
                                    #worksheet.row(rowidx).push ddvalue.gsub("|"," ")
                                end
                            end
                            if show_baseline_fields.size > 0
                                blvalues = tc_project["ef"+efcount.to_s+"-baselinevalues"]
                                for pk in show_baseline_fields
                                    blvalue = blvalues[pk]
                                    #worksheet.row(rowidx).push blvalue.gsub("|"," ")
                                end
                            end
                            if show_outcomes_fields.size > 0
                                outvalues = tc_project["ef"+efcount.to_s+"-outcomesvalues"]
                                for pk in show_outcomes_fields
                                    dd = outcomes_config[pk]
                                    tmpd = dd[2].split("=>")
                                    title = tmpd[1]
                                    outvalue = outvalues[title+"_"+ef.id.to_s+"_"+pub.study_id.to_s]
                                    if outvalue.nil?
                                        outvalue = "-"
                                    end
                                    #worksheet.row(rowidx).push outvalue.gsub("|"," ")
                                end
                            end
                            if show_advevents_fields.size > 0
                                advevalues = tc_project["ef"+efcount.to_s+"-adveventsvalues"]
                                for pk in show_advevents_fields
                                    puts ">>>> show_advevents_fields pk = "+pk.to_s
                                    advevalue = advevalues[pk]
                                    #worksheet.row(rowidx).push advevalue.gsub("|"," ")
                                end
                            end
                            if show_qualdimfields_fields.size > 0
                                qdfvalues = tc_project["ef"+efcount.to_s+"-qualdimfieldsvalues"]
                                for pk in show_qualdimfields_fields
                                    puts ">>>> show_qualdimfields_fields pk = "+pk.to_s
                                    qdfvalue = qdfvalues[pk]
                                    #worksheet.row(rowidx).push qdfvalue.gsub("|"," ")
                                end
                            end
                            rowidx = rowidx + 1
                        end
                    end
                else
                    # ================= previewFlat ======================
                    # Title row ----------------------------------------------------
                    #worksheet.row(rowidx).push "Publication"
                    if show_armsnames_fields.size > 0
                        #worksheet.row(rowidx).push "Arms"
                        if show_baseline_fields.size > 1
                            for i in 2..show_armsnames_fields.size
                                #worksheet.row(rowidx).push " "
                            end
                        end
                    end 
                    if show_design_fields.size > 0
                        #worksheet.row(rowidx).push "Design Details"
                        if show_baseline_fields.size > 1
                            for i in 2..show_design_fields.size
                                #worksheet.row(rowidx).push " "
                            end
                        end
                    end 
                    if show_baseline_fields.size > 0
                        #worksheet.row(rowidx).push "Baseline Characteristics"
                        if show_baseline_fields.size > 1
                            for i in 2..show_design_fields.size
                                #worksheet.row(rowidx).push " "
                            end
                        end
                    end 
                    if show_advevents_fields.size > 0
                        #worksheet.row(rowidx).push "Adverse Events"
                        if show_advevents_fields.size > 1
                            for i in 2..show_design_fields.size
                                #worksheet.row(rowidx).push " "
                            end
                        end
                    end 
                    if show_qualdimfields_fields.size > 0
                        #worksheet.row(rowidx).push "Quality Dimentions"
                        if show_qualdimfields_fields.size > 1
                            for i in 2..show_design_fields.size
                                #worksheet.row(rowidx).push " "
                            end
                        end
                    end
                    rowidx = rowidx + 1
                    # Title sub row ----------------------------------------------------
                    #worksheet.row(rowidx).push " "
                    if show_armsnames_fields.size > 0
                        # Use the previously loaded armsnames_config[] Hash to get Arms name for the header
                        for pk in show_armsnames_fields
                            dd = armsnames_config[pk]
                            tmpd = dd[2].split("=>")
                            arm_name = tmpd[1]
                            arms = tc_project["ef"+efcount.to_s+"-arms"]
                            title = ""
                            for arm in arms
                                # Find the matching arm to show, then build the title
                                if arm.name == arm_name
                                    for apk in show_arms_fields
                                        if title.length > 0
                                            title << "<br/>"
                                        end
                                        title << arm[apk].to_s
                                    end
                                end
                            end
                            #worksheet.row(rowidx).push title
                        end
                    end
                    if show_design_fields.size > 0
                        # Use the previously loaded designnames_config[] Hash to get design detail name for the header
                        for pk in show_design_fields
                            dd = designnames_config[pk]
                            tmpd = dd[2].split("=>")
                            title = tmpd[1]
                            #worksheet.row(rowidx).push title
                        end
                    end
                    if show_baseline_fields.size > 0
                        # Use the previously loaded baseline_config[] Hash to get baseline characteristic name for the header
                        for pk in show_baseline_fields
                            dd = baseline_config[pk]
                            tmpd = dd[2].split("=>")
                            title = tmpd[1]
                            #worksheet.row(rowidx).push title
                        end
                    end
                    if show_outcomes_fields.size > 0
                        # Use the previously loaded outcomes_config[] Hash to get outcomes title for the header
                        for pk in show_outcomes_fields
                            dd = outcomes_config[pk]
                            tmpd = dd[2].split("=>")
                            title = tmpd[1]
                            #worksheet.row(rowidx).push title
                        end
                    end
                    if show_advevents_fields.size > 0
                        # Use the previously loaded advevents_config[] Hash to get adverse events name for the header
                        for pk in show_advevents_fields
                            dd = advevents_config[pk]
                            tmpd = dd[2].split("=>")
                            title = tmpd[1]
                            #worksheet.row(rowidx).push title
                        end
                    end
                    if show_qualdimfields_fields.size > 0
                        # Use the previously loaded qualdimfields_formconfig[] Hash to get quality dimension name for the header
                        for pk in show_qualdimfields_fields
                            dd = qualdimfields_config[pk]
                            tmpd = dd[2].split("=>")
                            title = tmpd[1]
                            #worksheet.row(rowidx).push title
                        end
                    end
                    rowidx = rowidx + 1
                    # Publication data rows ----------------------------------------------------
                    for pub in studies
                        puts "......... rendering pub "+pub.id.to_s
                        pub_info = ""
                        for pubfield in show_pub_fields
                            if pub_info.length > 0
                                pub_info << "<br/>"
                            end
                            pub_info << pub[pubfield].to_s
                        end
                        #worksheet.row(rowidx).push "["+efcount.to_s+"] "+pub_info
                        if show_armsnames_fields.size > 0
                            arms = tc_project["ef"+efcount.to_s+"-arms"]
                            for arm in arms
                                arms_info = ""
                                for armsfield in show_armsnames_fields
                                    if arms_info.length > 0
                                        arms_info << "<br/>"
                                    end
                                    arms_info << arm[armsfield].to_s
                                end
                                #worksheet.row(rowidx).push "X"
                            end
                        end
                        if show_design_fields.size > 0
                            ddsvalues = tc_project["ef"+efcount.to_s+"-designvalues"]
                            for pk in show_design_fields
                                ddvalue = ddsvalues[pk]
                                #worksheet.row(rowidx).push ddvalue.gsub("|"," ")
                            end
                        end
                        if show_baseline_fields.size > 0
                            blvalues = tc_project["ef"+efcount.to_s+"-baselinevalues"]
                            for pk in show_baseline_fields
                                blvalue = blvalues[pk]
                                #worksheet.row(rowidx).push blvalue.gsub("|"," ")
                            end
                        end
                        if show_outcomes_fields.size > 0
                            outvalues = tc_project["ef"+efcount.to_s+"-outcomesvalues"]
                            for pk in show_outcomes_fields
                                dd = outcomes_config[pk]
                                tmpd = dd[2].split("=>")
                                title = tmpd[1]
                                outvalue = outvalues[title+"_"+ef.id.to_s+"_"+pub.study_id.to_s]
                                if outvalue.nil?
                                    outvalue = "-"
                                end
                                #worksheet.row(rowidx).push outvalue.gsub("|"," ")
                            end
                        end
                        if show_advevents_fields.size > 0
                            advevalues = tc_project["ef"+efcount.to_s+"-adveventsvalues"]
                            for pk in show_advevents_fields
                                advevalue = advevalues[pk]
                                #worksheet.row(rowidx).push advevalue.gsub("|"," ")
                            end
                        end
                        if show_qualdimfields_fields.size > 0
                            qdfvalues = tc_project["ef"+efcount.to_s+"-qualdimfieldsvalues"]
                            for pk in show_qualdimfields_fields
                                qdfvalue = qdfvalues[pk]
                                #worksheet.row(rowidx).push qdfvalue.gsub("|"," ")
                            end
                        end
                        rowidx = rowidx + 1
                    end
                   
                end
                
                # Get next EF
                efcount = efcount + 1
                ef = tc_project["ef"+efcount.to_s]
            end
        end
        
        # Now load the second part of the XML Word document
        tfile = File.open("reports/docments/WordTemplateP2.xml")
        tfile.each {|line|
            blob << line
        }
        # Return the blob for download
		return blob.string
	end
    
    def getWordLine(svalue)
        sbob = ""
        sblob << "<w:p w:rsidR=\"00CC7AAF\" w:rsidRDefault=\"00C67F51\">"
        sblob << "    <w:pPr>"
        sblob << "        <w:spacing w:after=\"0\"/>"
        sblob << "    </w:pPr>"
        sblob << "    <w:r>"
        sblob << "        <w:t>"+svalue+"</w:t>"
        sblob << "    </w:r>"
        sblob << "</w:p>"
        return sblob
    end
end