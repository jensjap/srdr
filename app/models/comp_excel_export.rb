###############################################################################
# This class contains code for exporting various parts of a systematic review #
# to Microsoft Excel format. 												  #
###############################################################################

class CompExcelExport
	
	# export all data specified in the study comparator configuration for this project
	def self.project_to_xls consensus_params, user 
		# EXCEL FORMATTING ========================================================================
		doc = Spreadsheet::Workbook.new # create the workbook
		section_title = Spreadsheet::Format.new(:weight => :bold, :size => 14) 
		bold = Spreadsheet::Format.new(:weight=>:bold,:align=>'center',:vertical_align=>'top')
		bold_centered = Spreadsheet::Format.new(:weight => :bold, :align=>"center", :text_wrap=>true) 
		normal_wrap = Spreadsheet::Format.new(:text_wrap => true,:vertical_align=>"top")
		row_data = Spreadsheet::Format.new(:text_wrap => true,:align=>"center",:vertical_align=>"top")
		formats = {'section_title'=>section_title,'bold'=>bold,'bold_centered'=>bold_centered,
		          'normal_wrap'=>normal_wrap,'row_data'=>row_data}
		doc.add_format(section_title)
		doc.add_format(bold)
		doc.add_format(bold_centered)
		doc.add_format(normal_wrap)
		doc.add_format(row_data)
		# EXCEL FORMATTING ========================================================================
		h1_left = Spreadsheet::Format.new(:weight=>:bold,:size=>12,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		h2_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		prj_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>false,:color=>:blue)
		ef_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>false,:color=>:blue)
		arms_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>false,:color=>:blue)
		seg_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		subseg_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>10,:align=>'center',:vertical_align=>'top',:text_wrap=>true)
		pub_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>10,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		pub_data_left = Spreadsheet::Format.new(:size=>10,:align=>'center',:vertical_align=>'top',:text_wrap=>true)
		fmt_title = Spreadsheet::Format.new(:weight=>:bold,:size=>14,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		fmt_study_title = Spreadsheet::Format.new(:weight=>:bold,:size=>13,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		fmt_data_title = Spreadsheet::Format.new(:weight=>:bold,:size=>12,:align=>'left',:vertical_align=>'top',:text_wrap=>true,:color=>:black)
		fmt_data_title_total = Spreadsheet::Format.new(:weight=>:bold,:size=>12,:align=>'left',:vertical_align=>'top',:text_wrap=>true,:color=>:green)
		fmt_data_value = Spreadsheet::Format.new(:weight=>:normal,:size=>11,:align=>'center',:vertical_align=>'top',:text_wrap=>true,:color=>:black)
		fmt_data_selected = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'center',:vertical_align=>'top',:text_wrap=>true,:color=>:red)
		fmt_data_merged = Spreadsheet::Format.new(:weight=>:bold,:size=>12,:align=>'center',:vertical_align=>'top',:text_wrap=>true,:color=>:blue)
        datacolwidth = 20
		# EXCEL FORMATTING ========================================================================
        
        # First get list of arms
        n_arms = consensus_params["merge_bls_n_arms"].to_i
        arms = Array.new
        for armidx in 0..n_arms - 1
            arms << consensus_params["arms_"+armidx.to_s]
        end
        
	    user_info = user.to_string
	    worksheet = doc.create_worksheet :name => "Meta"
        rowidx = 0
        colidx = 0
        prj_id = consensus_params["prj_id"]
        worksheet.row(rowidx).concat ["Project", "[" + prj_id.to_s + "] " + consensus_params["prj_title"]]
		worksheet.row(rowidx).set_format(0,h1_left)
        rowidx = rowidx + 1
        worksheet.row(rowidx).concat ["Creator", user_info]
		worksheet.row(rowidx).set_format(0,h1_left)
        
	    worksheet = doc.create_worksheet :name => "Publication"
        colidx = 0
        rowidx = 1
        n_studies = consensus_params["n_studies"].to_i
        row_data = Array.new     
        row_data << "Studies Compared"
        # Can't seem to pass the compare set through the session object - rebuild it here
        @compareset = Compareset.new
        for sidx in 0..(n_studies - 1)
            study_id = consensus_params["study_id_"+sidx.to_s].to_i
            row_data << "["+study_id.to_s+"] "+consensus_params["study_title_"+sidx.to_s]
            study_efs = StudyExtractionForm.find(:all,:conditions=>["study_id = ?", study_id])
            study_ef = study_efs[0]
            ef_id = study_ef.extraction_form_id
            @compareset.add(prj_id,study_id,ef_id)
        end
        row_data << "Consensus Value"
        worksheet.row(rowidx).concat row_data
        worksheet.row(rowidx).set_format(0,pub_title_left)
        worksheet.row(rowidx).set_format(n_studies + 1,pub_title_left)
        rowidx = rowidx + 1
        colidx = 0
        row_data = Array.new     
        row_data << "Title"     
        worksheet.column(0).width = 20
        for sidx in 0..(n_studies - 1)
            dispvalue = @compareset.getTitle(sidx)
            # remove any line feeds, convert to simple space
            dispvalue = dispvalue.gsub( /\r\n/m, " " )
            row_data << dispvalue     
            worksheet.row(rowidx).set_format(sidx + 1,fmt_study_title)
            worksheet.column(sidx + 1).width = 20
        end
        row_data << getValidValue(consensus_params["merge_title_text"])     
        worksheet.row(rowidx).concat row_data
        worksheet.row(rowidx).set_format(n_studies + 1,fmt_title)
        worksheet.column(n_studies + 1).width = 20
        rowidx = rowidx + 1
        
        row_data = Array.new     
        row_data << "Year"     
        for sidx in 0..(n_studies - 1)
            dispvalue = @compareset.getYear(sidx)
            # remove any line feeds, convert to simple space
            dispvalue = dispvalue.gsub( /\r\n/m, " " )
            row_data << dispvalue     
            worksheet.row(rowidx).set_format(sidx + 1,fmt_study_title)
        end
        row_data << getValidValue(consensus_params["merge_year_text"])     
        worksheet.row(rowidx).concat row_data
        worksheet.row(rowidx).set_format(n_studies + 1,fmt_title)
        rowidx = rowidx + 1
        
        row_data = Array.new     
        row_data << "Author"     
        for sidx in 0..(n_studies - 1)
            dispvalue = @compareset.getAuthor(sidx)
            # remove any line feeds, convert to simple space
            dispvalue = dispvalue.gsub( /\r\n/m, " " )
            row_data << dispvalue     
            worksheet.row(rowidx).set_format(sidx + 1,fmt_study_title)
        end
        row_data << getValidValue(consensus_params["merge_author_text"])     
        worksheet.row(rowidx).concat row_data
        worksheet.row(rowidx).set_format(n_studies + 1,fmt_title)
        rowidx = rowidx + 1
        
        row_data = Array.new     
        row_data << "Country"     
        for sidx in 0..(n_studies - 1)
            dispvalue = @compareset.getCountry(sidx)
            # remove any line feeds, convert to simple space
            dispvalue = dispvalue.gsub( /\r\n/m, " " )
            row_data << dispvalue     
            worksheet.row(rowidx).set_format(sidx + 1,fmt_study_title)
        end
        row_data << getValidValue(consensus_params["merge_country_text"])     
        worksheet.row(rowidx).concat row_data
        worksheet.row(rowidx).set_format(n_studies + 1,fmt_title)
        rowidx = rowidx + 1
        
        row_data = Array.new     
        row_data << "PubMed ID"     
        for sidx in 0..(n_studies - 1)
            dispvalue = @compareset.getPMID(sidx)
            # remove any line feeds, convert to simple space
            dispvalue = dispvalue.gsub( /\r\n/m, " " )
            row_data << dispvalue     
            worksheet.row(rowidx).set_format(sidx + 1,fmt_study_title)
        end
        row_data << getValidValue(consensus_params["merge_pmid_text"])     
        worksheet.row(rowidx).concat row_data
        worksheet.row(rowidx).set_format(n_studies + 1,fmt_title)
        rowidx = rowidx + 1
        
        row_data = Array.new     
        row_data << "Alternate ID"     
        for sidx in 0..(n_studies - 1)
            dispvalue = @compareset.getAlternateNumbers(sidx)
            # remove any line feeds, convert to simple space
            dispvalue = dispvalue.gsub( /\r\n/m, " " )
            row_data << dispvalue     
            worksheet.row(rowidx).set_format(sidx + 1,fmt_study_title)
        end
        row_data << getValidValue(consensus_params["merge_altid_text"])     
        worksheet.row(rowidx).concat row_data
        worksheet.row(rowidx).set_format(n_studies + 1,fmt_title)
        rowidx = rowidx + 1
        
        row_data = Array.new     
        row_data << "Journal"     
        for sidx in 0..(n_studies - 1)
            dispvalue = @compareset.getJournal(sidx)
            # remove any line feeds, convert to simple space
            dispvalue = dispvalue.gsub( /\r\n/m, " " )
            row_data << dispvalue     
            worksheet.row(rowidx).set_format(sidx + 1,fmt_study_title)
        end
        row_data << getValidValue(consensus_params["merge_journal_text"])     
        worksheet.row(rowidx).concat row_data
        worksheet.row(rowidx).set_format(n_studies + 1,fmt_title)
        rowidx = rowidx + 1
        
        row_data = Array.new     
        row_data << "Volume"     
        for sidx in 0..(n_studies - 1)
            dispvalue = @compareset.getVolume(sidx)
            # remove any line feeds, convert to simple space
            dispvalue = dispvalue.gsub( /\r\n/m, " " )
            row_data << dispvalue     
            worksheet.row(rowidx).set_format(sidx + 1,fmt_study_title)
        end
        row_data << getValidValue(consensus_params["merge_volume_text"])     
        worksheet.row(rowidx).concat row_data
        worksheet.row(rowidx).set_format(n_studies + 1,fmt_title)
        rowidx = rowidx + 1
        
        row_data = Array.new     
        row_data << "Issue"     
        for sidx in 0..(n_studies - 1)
            dispvalue = @compareset.getIssue(sidx)
            # remove any line feeds, convert to simple space
            dispvalue = dispvalue.gsub( /\r\n/m, " " )
            row_data << getValidValue(dispvalue)     
            worksheet.row(rowidx).set_format(sidx + 1,fmt_study_title)
        end
        row_data << getValidValue(consensus_params["merge_issue_text"])     
        worksheet.row(rowidx).concat row_data
        worksheet.row(rowidx).set_format(n_studies + 1,fmt_title)
        rowidx = rowidx + 1
                        
        # Study Arms sheet -----------------------------------------------------------
	    worksheet = doc.create_worksheet :name => "Study Arms"
        colidx = 0
        rowidx = 1
        n_items = consensus_params["merge_arm_n_items"].to_i
        row_data = Array.new
        row_data << "Study Arms"
        worksheet.column(0).width = 40
        worksheet.row(rowidx).set_format(0,fmt_title)
        for sidx in 0..(n_studies - 1)
            study_id = consensus_params["study_id_"+sidx.to_s].to_i
            study_title = consensus_params["study_title_"+sidx.to_s]
            row_data << "["+study_id.to_s+"] "+study_title
            worksheet.column(sidx + 1).width = 20
            worksheet.row(rowidx).set_format(sidx + 1,fmt_study_title)
        end
        worksheet.column(n_studies + 1).width = 20
        row_data << "Consensus Value"
        worksheet.row(rowidx).concat row_data
        worksheet.row(rowidx).set_format(n_studies + 1,fmt_title)
        # Render individual arms data
        rowidx = rowidx + 1
        for idx in 0..(n_items - 1)
            dispid = consensus_params["merge_arm_"+idx.to_s+"_id"]
            dispname = consensus_params["merge_arm_"+idx.to_s+"_name"]
            merged_value = consensus_params["merge_arm_"+idx.to_s+"_text"]
            row_data = Array.new
            row_data << dispname 
            worksheet.row(rowidx).set_format(0,fmt_data_title)
            for sidx in 0..(n_studies - 1)
                study_id = consensus_params["study_id_"+sidx.to_s].to_i
                study_title = consensus_params["study_title_"+sidx.to_s]
                if @compareset.containsArmName(sidx,dispname)
                    dispvalue = "[REMOVE] "+dispname
                    dispvalue_txt = "Contains this, remove from consensus"
                else
                    dispvalue = "[ADD] "+dispname
                    dispvalue_txt = "Add to consensus"
                end
                
                row_data << dispvalue_txt
                if dispvalue.to_s == merged_value
                    worksheet.row(rowidx).set_format(sidx + 1,fmt_data_selected)
                else
                    worksheet.row(rowidx).set_format(sidx + 1,fmt_data_value)
                end
            end
            row_data << getValidValue(merged_value)
            worksheet.row(rowidx).concat row_data
            worksheet.row(rowidx).set_format(n_studies + 1,fmt_data_merged)
            rowidx = rowidx + 1
        end
                        
        # Arm Details sheet -----------------------------------------------------------
	    worksheet = doc.create_worksheet :name => "Arm Details"
        colidx = 0
        rowidx = 1
        n_items = consensus_params["merge_armds_n_items"].to_i
        row_data = Array.new
        row_data << "Arm Details"
        worksheet.column(0).width = 40
        worksheet.row(rowidx).set_format(0,fmt_title)
        for sidx in 0..(n_studies - 1)
            study_id = consensus_params["study_id_"+sidx.to_s].to_i
            study_title = consensus_params["study_title_"+sidx.to_s]
            row_data << "["+study_id.to_s+"] "+study_title
            worksheet.column(sidx + 1).width = 20
            worksheet.row(rowidx).set_format(sidx + 1,fmt_study_title)
        end
        worksheet.column(n_studies + 1).width = 20
        row_data << "Consensus Value"
        worksheet.row(rowidx).concat row_data
        worksheet.row(rowidx).set_format(n_studies + 1,fmt_title)
        # Render individual arm details data
        rowidx = rowidx + 1
        for idx in 0..(n_items - 1)
            dispid = consensus_params["merge_armds_"+idx.to_s+"_id"]
            dispname = consensus_params["merge_armds_"+idx.to_s+"_name"]
            merged_value = consensus_params["merge_armds_"+idx.to_s+"_text"]
            row_data = Array.new
            row_data << dispname 
            worksheet.row(rowidx).set_format(0,fmt_data_title)
            for sidx in 0..(n_studies - 1)
                study_id = consensus_params["study_id_"+sidx.to_s].to_i
                study_title = consensus_params["study_title_"+sidx.to_s]
                dispvalue = @compareset.getArmDetailValue(sidx,dispname)
                if dispvalue.nil?
                    dispvalue = "-"
                end
                
                row_data << dispvalue
                if dispvalue.to_s == merged_value
                    worksheet.row(rowidx).set_format(sidx + 1,fmt_data_selected)
                else
                    worksheet.row(rowidx).set_format(sidx + 1,fmt_data_value)
                end
            end
            row_data << getValidValue(merged_value)
            worksheet.row(rowidx).concat row_data
            worksheet.row(rowidx).set_format(n_studies + 1,fmt_data_merged)
            rowidx = rowidx + 1
        end
                        
        # Design Details sheet -----------------------------------------------------------
	    worksheet = doc.create_worksheet :name => "Design Details"
        colidx = 0
        rowidx = 1
        n_items = consensus_params["merge_dds_n_items"].to_i
        row_data = Array.new
        row_data << "Design Details"
        worksheet.column(0).width = 40
        worksheet.row(rowidx).set_format(0,fmt_title)
        for sidx in 0..(n_studies - 1)
            study_id = consensus_params["study_id_"+sidx.to_s].to_i
            study_title = consensus_params["study_title_"+sidx.to_s]
            row_data << "["+study_id.to_s+"] "+study_title
            worksheet.column(sidx + 1).width = 20
            worksheet.row(rowidx).set_format(sidx + 1,fmt_study_title)
        end
        worksheet.column(n_studies + 1).width = 20
        row_data << "Consensus Value"
        worksheet.row(rowidx).concat row_data
        worksheet.row(rowidx).set_format(n_studies + 1,fmt_title)
        # Render individual design details data
        rowidx = rowidx + 1
        for idx in 0..(n_items - 1)
            dispid = consensus_params["merge_dds_"+idx.to_s+"_id"]
            dispname = consensus_params["merge_dds_"+idx.to_s+"_name"]
            merged_value = consensus_params["merge_dds_"+idx.to_s+"_text"]
            row_data = Array.new
            row_data << dispname 
            worksheet.row(rowidx).set_format(0,fmt_data_title)
            for sidx in 0..(n_studies - 1)
                study_id = consensus_params["study_id_"+sidx.to_s].to_i
                study_title = consensus_params["study_title_"+sidx.to_s]
                dispvalue = @compareset.getDesignDetailValue(sidx,dispname)
                if dispvalue.nil?
                    dispvalue = "-"
                end
                
                row_data << dispvalue
                if dispvalue.to_s == merged_value
                    worksheet.row(rowidx).set_format(sidx + 1,fmt_data_selected)
                else
                    worksheet.row(rowidx).set_format(sidx + 1,fmt_data_value)
                end
            end
            row_data << getValidValue(merged_value)
            worksheet.row(rowidx).concat row_data
            worksheet.row(rowidx).set_format(n_studies + 1,fmt_data_merged)
            rowidx = rowidx + 1
        end
        
        # Baseline Characteristics sheet -----------------------------------------------------------
	    worksheet = doc.create_worksheet :name => "Baseline Characteristics"
        rowidx = 1
        colidx = 0
        n_studies = @compareset.size()
        n_arms = @compareset.getNumDistinctArms()
        n_bls = @compareset.getNumDistinctBaseline()
        # Format as Study,Arm (ea row),BL (ea col x single and adj matrix width)
        row_data = Array.new
        row_data << "Baseline Characteristics"
        row_data << "Arm"
        row_data << "Matrix Row"
        row_data << "Matrix Column"
        worksheet.column(0).width = 40
        worksheet.row(rowidx).set_format(0,fmt_title)
        for sidx in 0..(n_studies - 1)
            study_id = consensus_params["study_id_"+sidx.to_s].to_i
            study_title = consensus_params["study_title_"+sidx.to_s]
            row_data << "["+study_id.to_s+"] "+study_title
            worksheet.column(sidx + 1).width = 20
            worksheet.row(rowidx).set_format(sidx + 1,fmt_study_title)
        end
        worksheet.column(n_studies + 1).width = 20
        row_data << "Consensus Value"
        worksheet.row(rowidx).concat row_data
        worksheet.row(rowidx).set_format(n_studies + 1,fmt_title)
        
        # Render individual baseline characteristic data
        rowidx = rowidx + 1
        for blidx in 0..n_bls - 1
            for armidx in 0..n_arms - 1
                # If all studies compared are of the same data type - pick up selected values
                bl_name = @compareset.getBaselineName(blidx)
                arm_name = @compareset.getArmName(armidx)
                is_complex_flag = consensus_params["merge_bls_"+armidx.to_s+"_"+blidx.to_s+"_complex"]
                puts "comp_excel_export - is_complex_flag="+is_complex_flag.to_s
                if is_complex_flag == "1"
                    n_bl_rows = consensus_params["merge_blnr_"+armidx.to_s+"_"+blidx.to_s].to_i
                    n_bl_cols = consensus_params["merge_blnc_"+armidx.to_s+"_"+blidx.to_s].to_i
                    puts "comp_excel_export - matrix type rows="+n_bl_rows.to_s+" cols="+n_bl_cols.to_s
                    for rfidx in 0..n_bl_rows - 1
                        for cfidx in 0..n_bl_cols - 1
                            rowname = consensus_params["merge_blrn_"+armidx.to_s+"_"+blidx.to_s+"_"+rfidx.to_s]
                            colname = consensus_params["merge_blcn_"+armidx.to_s+"_"+blidx.to_s+"_"+cfidx.to_s]
                            row_data = Array.new
                            row_data << bl_name 
                            row_data << arm_name 
                            row_data << rowname 
                            row_data << colname 
                            for sidx in 0..n_studies - 1
                                val = @compareset.getBaselineMatrixValue(sidx,arm_name,bl_name,rfidx,cfidx)
                                if val.nil?
                                    val = "-"
                                end
                                row_data << val 
                            end
                            # get merged value
                            cval = consensus_params["merge_bls_"+armidx.to_s+"_"+blidx.to_s+"_"+rfidx.to_s+"_"+cfidx.to_s]
                            if cval.nil? ||
                                (cval == "SELECT")
                                cval = "-"
                            end
                            row_data << getValidValue(val) 
                            worksheet.row(rowidx).concat row_data
                            worksheet.row(rowidx).set_format(n_studies + 1,fmt_data_merged)
                            rowidx = rowidx + 1
                        end
                    end
                elsif is_complex_flag == "0"
                    row_data = Array.new
                    row_data << bl_name 
                    row_data << arm_name 
                    row_data << "na"    # No row name 
                    row_data << "na"    # No colname name 
                    for sidx in 0..n_studies - 1
                        val = @compareset.getBaselineValue(sidx,arm_name,bl_name)
                        if val.nil?
                            val = "-"
                        end
                        row_data << val 
                    end
                    # get merged value
                    cval = consensus_params["merge_bls_"+armidx.to_s+"_"+blidx.to_s]
                    if cval.nil? ||
                        (cval == "SELECT")
                        cval = "-"
                    end
                    row_data << getValidValue(val) 
                    worksheet.row(rowidx).concat row_data
                    worksheet.row(rowidx).set_format(n_studies + 1,fmt_data_merged)
                    rowidx = rowidx + 1
                else
                    row_data = Array.new
                    row_data << bl_name 
                    row_data << arm_name 
                    row_data << "na"    # No row name 
                    row_data << "na"    # No colname name 
                    for sidx in 0..n_studies - 1
                        row_data << "na" 
                    end
                    row_data << "na" 
                    worksheet.row(rowidx).concat row_data
                    worksheet.row(rowidx).set_format(n_studies + 1,fmt_data_merged)
                    rowidx = rowidx + 1
                end
            end
        end
        
        # Outcomes sheet -----------------------------------------------------------
	    worksheet = doc.create_worksheet :name => "Outcomes Setup"
        colidx = 0
        rowidx = 1
        n_items = consensus_params["merge_outc_n_items"].to_i
        row_data = Array.new
        row_data << "Outcome Setup"
        worksheet.column(0).width = 40
        worksheet.row(rowidx).set_format(0,fmt_title)
        for sidx in 0..(n_studies - 1)
            study_id = consensus_params["study_id_"+sidx.to_s].to_i
            study_title = consensus_params["study_title_"+sidx.to_s]
            row_data << "["+study_id.to_s+"] "+study_title
            worksheet.column(sidx + 1).width = 20
            worksheet.row(rowidx).set_format(sidx + 1,fmt_study_title)
        end
        worksheet.column(n_studies + 1).width = 20
        row_data << "Consensus Value"
        worksheet.row(rowidx).concat row_data
        worksheet.row(rowidx).set_format(n_studies + 1,fmt_title)
        # Render individual arms data
        rowidx = rowidx + 1
        for idx in 0..(n_items - 1)
            dispid = consensus_params["merge_outc_"+idx.to_s+"_id"]
            dispname = consensus_params["merge_outc_"+idx.to_s+"_name"]
            merged_value = consensus_params["merge_outc_"+idx.to_s+"_text"]
            row_data = Array.new
            row_data << dispname 
            worksheet.row(rowidx).set_format(0,fmt_data_title)
            for sidx in 0..(n_studies - 1)
                study_id = consensus_params["study_id_"+sidx.to_s].to_i
                study_title = consensus_params["study_title_"+sidx.to_s]
                if @compareset.containsOutcomeName(sidx,dispname)
                    dispvalue = "[REMOVE] "+dispname
                    dispvalue_txt = "Contains this, remove from consensus"
                else
                    dispvalue = "[ADD] "+dispname
                    dispvalue_txt = "Add to consensus"
                end
                
                row_data << dispvalue_txt
                if dispvalue.to_s == merged_value
                    worksheet.row(rowidx).set_format(sidx + 1,fmt_data_selected)
                else
                    worksheet.row(rowidx).set_format(sidx + 1,fmt_data_value)
                end
            end
            row_data << getValidValue(merged_value)
            worksheet.row(rowidx).concat row_data
            worksheet.row(rowidx).set_format(n_studies + 1,fmt_data_merged)
            rowidx = rowidx + 1
        end
	    
        # Outcomes Results sheet -----------------------------------------------------------
        worksheet = doc.create_worksheet :name => "Outcome Results"
        colidx = 0
        rowidx = 1
        n_items = consensus_params["merge_outcr_n_outcomes"].to_i
        row_data = Array.new
        row_data << "Outcome"
        row_data << "Arm"
        row_data << "Timepoint"
        row_data << "Measure"
        worksheet.column(0).width = 20
        worksheet.column(1).width = 20
        worksheet.column(2).width = 20
        worksheet.column(3).width = 20
        worksheet.row(rowidx).set_format(0,fmt_title)
        worksheet.row(rowidx).set_format(1,fmt_title)
        worksheet.row(rowidx).set_format(2,fmt_title)
        worksheet.row(rowidx).set_format(3,fmt_title)
        for sidx in 0..(n_studies - 1)
            study_id = consensus_params["study_id_"+sidx.to_s].to_i
            study_title = consensus_params["study_title_"+sidx.to_s]
            row_data << "["+study_id.to_s+"] "+study_title
            worksheet.column(sidx + 1 + 3).width = 20
            worksheet.row(rowidx).set_format(sidx + 1 + 3,fmt_study_title)
        end
        worksheet.column(n_studies + 1 + 3).width = 20
        row_data << "Consensus Value"
        worksheet.row(rowidx).concat row_data
        worksheet.row(rowidx).set_format(n_studies + 1 + 3,fmt_title)
        # Render individual arms data
        rowidx = rowidx + 1
        for idx in 0..n_items - 1
            dispid = consensus_params["merge_outcr_"+idx.to_s+"_id"]
            dispname = consensus_params["merge_outcr_"+idx.to_s+"_name"]
            armname = consensus_params["merge_outcr_"+idx.to_s+"_arm"]
            timept = consensus_params["merge_outcr_"+idx.to_s+"_timept"]
            meas = consensus_params["merge_outcr_"+idx.to_s+"_meas"]
            merged_value = consensus_params["merge_outcr_"+idx.to_s+"_text"]
            if !dispname.nil? &&
                !armname.nil? &&
                !timept.nil? &&
                !meas.nil? &&
                !merged_value.nil?
                row_data = Array.new
                row_data << dispname 
                row_data << armname 
                row_data << timept 
                row_data << meas 
                worksheet.row(rowidx).set_format(0,fmt_data_title)
                for sidx in 0..(n_studies - 1)
                    study_id = consensus_params["study_id_"+sidx.to_s].to_i
                    study_title = consensus_params["study_title_"+sidx.to_s]
                    dispvalue = @compareset.getOutcomesValue(sidx,dispname,timept,meas,armname)
                    if dispvalue.nil?
                        dispvalue = "-"
                    end
                    # remove any line feeds, convert to simple space
                    dispvalue = dispvalue.gsub( /\r\n/m, " " )
                    
                    row_data << dispvalue
                    if dispvalue.to_s == merged_value
                        worksheet.row(rowidx).set_format(sidx + 1 + 3,fmt_data_selected)
                    else
                        worksheet.row(rowidx).set_format(sidx + 1 + 3,fmt_data_value)
                    end
                end
                row_data << getValidValue(merged_value)
                worksheet.row(rowidx).concat row_data
                worksheet.row(rowidx).set_format(n_studies + 1 + 3,fmt_data_merged)
                rowidx = rowidx + 1
            end
        end
                        
        # Outcome Details sheet -----------------------------------------------------------
	    worksheet = doc.create_worksheet :name => "Outcome Details"
        colidx = 0
        rowidx = 1
        n_items = consensus_params["merge_outds_n_items"].to_i
        row_data = Array.new
        row_data << "Outcome Details"
        worksheet.column(0).width = 40
        worksheet.row(rowidx).set_format(0,fmt_title)
        for sidx in 0..(n_studies - 1)
            study_id = consensus_params["study_id_"+sidx.to_s].to_i
            study_title = consensus_params["study_title_"+sidx.to_s]
            row_data << "["+study_id.to_s+"] "+study_title
            worksheet.column(sidx + 1).width = 20
            worksheet.row(rowidx).set_format(sidx + 1,fmt_study_title)
        end
        worksheet.column(n_studies + 1).width = 20
        row_data << "Consensus Value"
        worksheet.row(rowidx).concat row_data
        worksheet.row(rowidx).set_format(n_studies + 1,fmt_title)
        # Render individual outcome details data
        rowidx = rowidx + 1
        for idx in 0..(n_items - 1)
            dispid = consensus_params["merge_outds_"+idx.to_s+"_id"]
            dispname = consensus_params["merge_outds_"+idx.to_s+"_name"]
            merged_value = consensus_params["merge_outds_"+idx.to_s+"_text"]
            row_data = Array.new
            row_data << dispname 
            worksheet.row(rowidx).set_format(0,fmt_data_title)
            for sidx in 0..(n_studies - 1)
                study_id = consensus_params["study_id_"+sidx.to_s].to_i
                study_title = consensus_params["study_title_"+sidx.to_s]
                dispvalue = @compareset.getOutcomeDetailValue(sidx,dispname)
                if dispvalue.nil?
                    dispvalue = "-"
                end
                
                row_data << dispvalue
                if dispvalue.to_s == merged_value
                    worksheet.row(rowidx).set_format(sidx + 1,fmt_data_selected)
                else
                    worksheet.row(rowidx).set_format(sidx + 1,fmt_data_value)
                end
            end
            row_data << getValidValue(merged_value)
            worksheet.row(rowidx).concat row_data
            worksheet.row(rowidx).set_format(n_studies + 1,fmt_data_merged)
            rowidx = rowidx + 1
        end
	    
        # Adverse Events sheet -----------------------------------------------------------
	    worksheet = doc.create_worksheet :name => "Adverse Events"
        rowidx = 1
        colidx = 0
        n_items = consensus_params["merge_adve_n_items"].to_i
        row_data = Array.new
        row_data << "Adverse Events"
        worksheet.column(0).width = 40
        worksheet.row(rowidx).set_format(0,fmt_title)
        for sidx in 0..(n_studies - 1)
            study_id = consensus_params["study_id_"+sidx.to_s].to_i
            study_title = consensus_params["study_title_"+sidx.to_s]
            row_data << "["+study_id.to_s+"] "+study_title
            worksheet.column(sidx + 1).width = 20
            worksheet.row(rowidx).set_format(sidx + 1,fmt_study_title)
        end
        worksheet.column(n_studies + 1).width = 20
        row_data << "Consensus Value"
        worksheet.row(rowidx).concat row_data
        worksheet.row(rowidx).set_format(n_studies + 1,fmt_title)
        # Render individual baseline characteristic data
        rowidx = rowidx + 1
        for idx in 0..((n_items * n_arms) - 1)
            dispname = consensus_params["merge_adve_"+idx.to_s+"_name"]
            armname = consensus_params["merge_adve_"+idx.to_s+"_arm"]
            merged_value = consensus_params["merge_adve_"+idx.to_s+"_text"]
            row_data = Array.new
            row_data << consensus_params["merge_adve_"+idx.to_s+"_name"] + " ARM: " +consensus_params["merge_adve_"+idx.to_s+"_arm"] 
            if consensus_params["merge_adve_"+idx.to_s+"_arm"] == "total"
                worksheet.row(rowidx).set_format(0,fmt_data_title_total)
            else
                worksheet.row(rowidx).set_format(0,fmt_data_title)
            end
            for sidx in 0..(n_studies - 1)
                study_id = consensus_params["study_id_"+sidx.to_s].to_i
                study_title = consensus_params["study_title_"+sidx.to_s]
                dispvalue = @compareset.getAdverseEventsValue(sidx,dispname,armname)
                if dispvalue.nil?
                    dispvalue = "-"
                end
                row_data << dispvalue.to_s
                if dispvalue.to_s == merged_value
                    worksheet.row(rowidx).set_format(sidx + 1,fmt_data_selected)
                else
                    worksheet.row(rowidx).set_format(sidx + 1,fmt_data_value)
                end
            end
            row_data << getValidValue(merged_value)
            worksheet.row(rowidx).concat row_data
            worksheet.row(rowidx).set_format(n_studies + 1,fmt_data_merged)
            rowidx = rowidx + 1
        end
        
        # Quality Dimentions sheet -----------------------------------------------------------
	    worksheet = doc.create_worksheet :name => "Quality Dimentions"
        colidx = 0
        rowidx = 1
        n_items = consensus_params["merge_qualdim_n_items"].to_i
        row_data = Array.new
        row_data << "Quality Dimentions"
        worksheet.column(0).width = 40
        worksheet.row(rowidx).set_format(0,fmt_title)
        for sidx in 0..(n_studies - 1)
            study_id = consensus_params["study_id_"+sidx.to_s].to_i
            study_title = consensus_params["study_title_"+sidx.to_s]
            row_data << "["+study_id.to_s+"] "+study_title
            worksheet.column(sidx + 1).width = 20
            worksheet.row(rowidx).set_format(sidx + 1,fmt_study_title)
        end
        worksheet.column(n_studies + 1).width = 20
        row_data << "Consensus Value"
        worksheet.row(rowidx).concat row_data
        worksheet.row(rowidx).set_format(n_studies + 1,fmt_title)
        # Render individual design details data
        rowidx = rowidx + 1
        for idx in 0..(n_items - 1)
            dispid = consensus_params["merge_qualdim_"+idx.to_s+"_id"]
            dispname = consensus_params["merge_qualdim_"+idx.to_s+"_name"]
            merged_value = consensus_params["merge_qualdim_"+idx.to_s+"_text"]
            row_data = Array.new
            row_data << dispname 
            worksheet.row(rowidx).set_format(0,fmt_data_title)
            for sidx in 0..(n_studies - 1)
                study_id = consensus_params["study_id_"+sidx.to_s].to_i
                study_title = consensus_params["study_title_"+sidx.to_s]
                dispvalue = @compareset.getQualityDimValue(sidx,dispname)
                if dispvalue.nil?
                    dispvalue = "-"
                end
                
                row_data << dispvalue
                if dispvalue.to_s == merged_value
                    worksheet.row(rowidx).set_format(sidx + 1,fmt_data_selected)
                else
                    worksheet.row(rowidx).set_format(sidx + 1,fmt_data_value)
                end
            end
            row_data << getValidValue(merged_value)
            worksheet.row(rowidx).concat row_data
            worksheet.row(rowidx).set_format(n_studies + 1,fmt_data_merged)
            rowidx = rowidx + 1
        end
        # Render overall quality measure
        row_data = Array.new
        row_data << "Overall Quality" 
        worksheet.row(rowidx).set_format(0,fmt_data_title)
        for sidx in 0..(n_studies - 1)
            study_id = consensus_params["study_id_"+sidx.to_s].to_i
            study_title = consensus_params["study_title_"+sidx.to_s]
            dispvalue = @compareset.getTotalQualityValue(sidx)
            if dispvalue.nil?
                dispvalue = "-"
            end
            
            row_data << dispvalue
            if dispvalue.to_s == merged_value
                worksheet.row(rowidx).set_format(sidx + 1,fmt_data_selected)
            else
                worksheet.row(rowidx).set_format(sidx + 1,fmt_data_value)
            end
        end
        row_data << getValidValue(consensus_params["merge_qualdim_overallquality_text"])
        worksheet.row(rowidx).concat row_data
        worksheet.row(rowidx).set_format(n_studies + 1,fmt_data_merged)
        rowidx = rowidx + 1
        
        # Setup and return the results as a blob
		blob = StringIO.new("")
        # Write the contents of the EXCEL file to the blob
		doc.write blob
        # Return the blob for download
		return blob.string
	end
    
    # Check for valid value entered in comparson form
    def self.isValid(sval)
        if sval.nil? ||
            sval.strip.size == 0
            return false
        elsif sval.strip == "Select value"
            return false
        else 
            return true
        end
    end
    
    def self.getValidValue(sval)
        if isValid(sval)
            return sval.strip
        else
            return ""
        end
    end
end