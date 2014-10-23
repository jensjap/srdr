###############################################################################
# This class contains code for exporting various parts of a systematic review #
# to Microsoft Excel format. 						      #
###############################################################################

class TCExcelExport
	
	# export all data specified in the table creator configuration for this project
	def self.project_to_xls tc_project, reportconfig, reportset, user 
        
		# EXCEL FORMATTING ========================================================================
		@doc = Spreadsheet::Workbook.new # create the workbook
		section_title = Spreadsheet::Format.new(:weight => :bold, :size => 14) 
		bold = Spreadsheet::Format.new(:weight=>:bold,:align=>'center',:vertical_align=>'top')
		bold_centered = Spreadsheet::Format.new(:weight => :bold, :align=>"center", :text_wrap=>true) 
		normal_wrap = Spreadsheet::Format.new(:text_wrap => true,:vertical_align=>"top")
		row_data = Spreadsheet::Format.new(:text_wrap => true,:align=>"center",:vertical_align=>"top")
		formats = {'section_title'=>section_title,'bold'=>bold,'bold_centered'=>bold_centered,
		          'normal_wrap'=>normal_wrap,'row_data'=>row_data}
		@doc.add_format(section_title)
		@doc.add_format(bold)
		@doc.add_format(bold_centered)
		@doc.add_format(normal_wrap)
		@doc.add_format(row_data)
		# EXCEL FORMATTING ========================================================================
		h1_left = Spreadsheet::Format.new(:weight=>:bold,:size=>12,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		h2_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		h3_left = Spreadsheet::Format.new(:weight=>:bold,:size=>9,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		h3_center = Spreadsheet::Format.new(:weight=>:bold,:size=>9,:align=>'center',:vertical_align=>'top',:text_wrap=>true)
		val_center = Spreadsheet::Format.new(:size=>9,:align=>'center',:vertical_align=>'top',:text_wrap=>true)
		title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		prj_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>false,:color=>:blue)
		ef_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>false,:color=>:blue)
		arms_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>false,:color=>:blue)
		seg_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		subseg_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>10,:align=>'center',:vertical_align=>'top',:text_wrap=>true)
		pub_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>10,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		pub_data_left = Spreadsheet::Format.new(:size=>10,:align=>'center',:vertical_align=>'top',:text_wrap=>true)
                datacolwidth = 20
		# EXCEL FORMATTING ========================================================================
        
	    user_info = user.to_string
	    @worksheet = @doc.create_worksheet :name => "Report"
        rowidx = 1
        
        # Render top level project information ========================================================================
        @worksheet.column(0).width = 40
        prj = tc_project["project"]
        prj_id = prj.id
        prj_title = prj.title
        @worksheet.row(rowidx).concat ["Creator", user_info]
		@worksheet.row(rowidx).set_format(0,h1_left)
        rowidx = rowidx + 1
        @worksheet.row(rowidx).concat ["Organization",user.organization]
		@worksheet.row(rowidx).set_format(0,h1_left)
        rowidx = rowidx + 2
        tmptxt = "Project "+prj_title+" ["+prj_id.to_s+"]"
        @worksheet.row(rowidx).concat ["Project "+prj_title+" ["+prj_id.to_s+"]"]
		@worksheet.row(rowidx).set_format(0,prj_title_left)
        rowidx = rowidx + 1
        # Render Project Information
        for ridx in 0..reportconfig.getNumProjectItems() - 1
            datalist = reportconfig.getProjectConfig(ridx)
            itemname = datalist[0]
            itemdesc = datalist[1]
            itemshow = datalist[2]
            if reportconfig.showProject(ridx)
                datavalue = reportset.getProjectValue(ridx)
                @worksheet.row(rowidx).concat [itemdesc,datavalue]
	            @worksheet.row(rowidx).set_format(0,h2_left)
                rowidx = rowidx + 1
            end
        end       
        if reportconfig.isFormatByArm()
            self.renderByArms(rowidx, reportconfig,reportset)
        else
            self.renderByEFs(rowidx, reportconfig,reportset)
        end
        
        
        # Setup and return the results as a blob
		blob = StringIO.new("")
        # Write the contents of the EXCEL file to the blob
		@doc.write blob
        # Return the blob for download
		return blob.string
	end
    
    # Helper method for rendering report by Extraction Forms
    # @doc - EXCEL document
    # @worksheet - single worksheet where everything gets written to
    # rowidx - start in this row
    def self.renderByEFs(rowidx, reportconfig, reportset)
		# EXCEL FORMATTING ========================================================================
		h1_left = Spreadsheet::Format.new(:weight=>:bold,:size=>12,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		h2_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		h2_left_span = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>false)
		h3_left = Spreadsheet::Format.new(:weight=>:bold,:size=>9,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		h3_left_span = Spreadsheet::Format.new(:weight=>:bold,:size=>9,:align=>'left',:vertical_align=>'top',:text_wrap=>false)
		h3_center = Spreadsheet::Format.new(:weight=>:bold,:size=>9,:align=>'center',:vertical_align=>'top',:text_wrap=>true)
		val_center = Spreadsheet::Format.new(:size=>9,:align=>'center',:vertical_align=>'top',:text_wrap=>true)
		title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		prj_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>false,:color=>:blue)
		ef_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>false,:color=>:blue)
		arms_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>false,:color=>:blue)
		seg_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		subseg_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>10,:align=>'center',:vertical_align=>'top',:text_wrap=>true)
		pub_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>10,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		pub_data_left = Spreadsheet::Format.new(:size=>10,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		pub_data = Spreadsheet::Format.new(:size=>10,:align=>'center',:vertical_align=>'top',:text_wrap=>true)
        datacolwidth = 20
		# EXCEL FORMATTING ========================================================================
        
        for eidx in 0..reportconfig.getNumExtractionFormsItems() - 1
            efid = reportconfig.getExtractionFormID(eidx)
            @worksheet.row(rowidx).concat ["Extraction Form: "+reportset.getEFTitle(eidx)+" ["+efid.to_s+"]"]
	        @worksheet.row(rowidx).set_format(0,ef_title_left)
            rowidx = rowidx + 1
            # Render header data ----------------------------------------------------------------------------
            colidx = 0
            # Publication
            @worksheet[rowidx,colidx] = "Publication Summary"
	        @worksheet.row(rowidx).set_format(colidx,ef_title_left)
            colidx = colidx + 1
            # Design Details --------------------------------------------------------------------------------
            if reportconfig.getNumShowDesignDetails() > 0
                @worksheet[rowidx,colidx] = "Design Details"
	            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
                colidx = colidx + reportconfig.getTotalDesignDetailsEXCELSpan(reportset)
            end
            # Arms ------------------------------------------------------------------------------------------
            if reportconfig.getNumShowArms() > 0
                @worksheet[rowidx,colidx] = "Arms"
	            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
                colidx = colidx + reportconfig.getNumShowArms()
            end
            # Arms Details --------------------------------------------------------------------------------
            if reportconfig.getNumArmDetailsCols() > 0
                @worksheet[rowidx,colidx] = "Arm Details"
	            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
                colidx = colidx + reportconfig.getNumArmDetailsCols()
            end
            # Baseline Characteristics ----------------------------------------------------------------------
            # Baseline contains both single and matrix data values - which must be flatten into Arms/BL/row/col
            if reportconfig.getNumBaselineItems() > 0
                @worksheet[rowidx,colidx] = "Baseline Characteristics"
	            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
                # colidx = colidx + getNumBaselineCols(reportconfig, reportset)
                ncols = getNumBaselineCols(reportconfig, reportset)
                colidx = colidx + ncols
            end
            # Outcome Timepoints ----------------------------------------------------------------------------
            if reportconfig.getNumOutcomeTimepointsCols() > 0
                @worksheet[rowidx,colidx] = "Outcome Timepoints"
	            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
                colidx = colidx + reportconfig.getNumOutcomeTimepointsCols()
            end
            # Outcome Measures ------------------------------------------------------------------------------
            if reportconfig.getNumOutcomeMeasuresCols() > 0
                @worksheet[rowidx,colidx] = "Outcome Measures"
	            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
                colidx = colidx + reportconfig.getNumOutcomeMeasuresCols()
            end
            # Outcome Results -------------------------------------------------------------------------------
            if reportconfig.getNumOutcomesCols() > 0
                @worksheet[rowidx,colidx] = "Outcome Results"
	            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
                colidx = colidx + (5 * reportconfig.getNumOutcomesCols())
            end
            # Outcome Details --------------------------------------------------------------------------------
            if reportconfig.getNumOutcomeDetailsCols() > 0
                @worksheet[rowidx,colidx] = "Outcome Details"
	            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
                colidx = colidx + reportconfig.getNumOutcomeDetailsCols()
            end
            # Adverse Events -------------------------------------------------------------------------------
            if reportconfig.getNumAdverseEventsCols() > 0
                @worksheet[rowidx,colidx] = "Adverse Events"
	            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
                colidx = colidx + reportconfig.getNumAdverseEventsCols()
            end
            # Quality Dimensions -------------------------------------------------------------------------------
            if reportconfig.getNumQualityDimCols() > 0
                @worksheet[rowidx,colidx] = "Quality Dimensions"
	            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
                colidx = colidx + reportconfig.getNumQualityDimCols()
            end
            # Between Arms Comparisons -------------------------------------------------------------------------
            if (reportconfig.getNumBACCols() * reportconfig.getNumBACMeasureCols()) > 0
                @worksheet[rowidx,colidx] = "Between Arms Comparison"
	            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
                colidx = colidx + reportconfig.getNumBACMeasureCols() + 4      # Outcome, Subgroup, Timepoint, Comparator
            end
            # Overall Quality -------------------------------------------------------------------------------
            @worksheet[rowidx,colidx] = "Overall Quality"
            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
            colidx = colidx + 1
            rowidx = rowidx + 1
            
            # Render sub-header data ----------------------------------------------------------------------------
            colidx = 0
            # Publication
            @worksheet[rowidx,colidx] = " "
	        @worksheet.row(rowidx).set_format(colidx,ef_title_left)
            colidx = colidx + 1
            # Design Details --------------------------------------------------------------------------------
            for ridx in 0..reportconfig.getNumDesignDetailsItems() - 1
                if reportconfig.showDesignDetails(ridx)
                    # Get list of labels for this DD
                    dd_labels = reportconfig.getDesignDetailsEXCELLabels(ridx,reportset)
                    dd_labels.each do |ddlabel|
                        @worksheet[rowidx,colidx] = ddlabel
        	            @worksheet.row(rowidx).set_format(colidx,h2_left_span)
                        colidx = colidx + 1
                    end
                end
            end
            # Arms ------------------------------------------------------------------------------------------
            for ridx in 0..reportconfig.getNumArmsItems() - 1
                if reportconfig.showArms(ridx)
                    @worksheet[rowidx,colidx] = reportconfig.getArmsDesc(ridx)
    	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                    colidx = colidx + 1
                end
            end
            # Arm Details --------------------------------------------------------------------------------
            # Check for matrix 
            for ridx in 0..reportconfig.getNumArmDetailsItems() - 1
                if reportconfig.showArmDetails(ridx)
                    @worksheet[rowidx,colidx] = reportconfig.getArmDetailsDesc(ridx)
    	            @worksheet.row(rowidx).set_format(colidx,h2_left_span)
                    ncols = reportconfig.getArmDetailsMatrixNCols(ridx)
                    colidx = colidx + ncols
                    if (reportconfig.isArmDetailsMatrix(ridx))
                        # Adjust 1 for row titles
                        colidx = colidx + 1
                    end
                end
            end
            # Baseline Characteristics ----------------------------------------------------------------------
            for ridx in 0..reportconfig.getNumBaselineItems() - 1
                if reportconfig.showBaseline(ridx)
                    bl = reportconfig.getBaselineName(ridx)
                    sublabels = getBaselineColLabels(reportconfig, reportset, bl)
                    sublabels.each do |sl|
                        @worksheet[rowidx,colidx] = sl
        	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                        colidx = colidx + 1
                    end
                end
            end
            # Outcome Timepoints ----------------------------------------------------------------------------
            for ridx in 0..reportconfig.getNumOutcomeTimepointsItems() - 1
                if reportconfig.showOutcomeTimepoints(ridx)
                    @worksheet[rowidx,colidx] = reportconfig.getOutcomeTimepointsDesc(ridx)
    	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                    colidx = colidx + 1
                end
            end
            # Outcome Measures ------------------------------------------------------------------------------
            for ridx in 0..reportconfig.getNumOutcomeMeasuresItems() - 1
                if reportconfig.showOutcomeMeasures(ridx)
                    @worksheet[rowidx,colidx] = reportconfig.getOutcomeMeasuresDesc(ridx)
    	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                    colidx = colidx + 1
                end
            end
            # Outcome Results -------------------------------------------------------------------------------
            for ridx in 0..reportconfig.getNumOutcomesItems() - 1
                if reportconfig.showOutcomes(ridx)
                    @worksheet[rowidx,colidx] = reportconfig.getOutcomesDesc(ridx)+" (Arm)"
    	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                    colidx = colidx + 1
                    @worksheet[rowidx,colidx] = reportconfig.getOutcomesDesc(ridx)+" (Subgroup)"
    	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                    colidx = colidx + 1
                    @worksheet[rowidx,colidx] = reportconfig.getOutcomesDesc(ridx)+" (Timepoint)"
    	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                    colidx = colidx + 1
                    @worksheet[rowidx,colidx] = reportconfig.getOutcomesDesc(ridx)+" (Measure)"
    	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                    colidx = colidx + 1
                    @worksheet[rowidx,colidx] = reportconfig.getOutcomesDesc(ridx)+" (Value)"
    	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                    colidx = colidx + 1
                end
            end
            # Outcome Details --------------------------------------------------------------------------------
            # Check for matrix 
            for ridx in 0..reportconfig.getNumOutcomeDetailsItems() - 1
                if reportconfig.showOutcomeDetails(ridx)
                    @worksheet[rowidx,colidx] = reportconfig.getOutcomeDetailsDesc(ridx)
    	            @worksheet.row(rowidx).set_format(colidx,h2_left_span)
                    ncols = reportconfig.getOutcomeDetailsMatrixNCols(ridx)
                    colidx = colidx + ncols
                    if (reportconfig.isOutcomeDetailsMatrix(ridx))
                        # Adjust 1 for row titles
                        colidx = colidx + 1
                    end
                end
            end
            # Adverse Events -------------------------------------------------------------------------------
            for ridx in 0..reportconfig.getNumAdverseEventsItems() - 1
                if reportconfig.showAdverseEvents(ridx)
                    @worksheet[rowidx,colidx] = reportconfig.getAdverseEventsDesc(ridx)
    	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                    colidx = colidx + 1
                end
            end
            # Quality Dimensions -------------------------------------------------------------------------------
            for ridx in 0..reportconfig.getNumQualityDimItems() - 1
                if reportconfig.showQualityDim(ridx)
                    @worksheet[rowidx,colidx] = reportconfig.getQualityDimDesc(ridx)
    	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                    colidx = colidx + 1
                end
            end
            # Between Arms Comparisons -------------------------------------------------------------------------
            if (reportconfig.getNumBACCols() * reportconfig.getNumBACMeasureCols()) > 0
                @worksheet[rowidx,colidx] = "Outcome"
    	        @worksheet.row(rowidx).set_format(colidx,h2_left)
                colidx = colidx + 1
                @worksheet[rowidx,colidx] = "Subgroup"
    	        @worksheet.row(rowidx).set_format(colidx,h2_left)
                colidx = colidx + 1
                @worksheet[rowidx,colidx] = "Timepoint"
    	        @worksheet.row(rowidx).set_format(colidx,h2_left)
                colidx = colidx + 1
                @worksheet[rowidx,colidx] = "Comparator"
    	        @worksheet.row(rowidx).set_format(colidx,h2_left)
                colidx = colidx + 1
                for bmidx in 0..reportconfig.getNumBACMeasureCols() - 1
                    if reportconfig.showBACMeasure(bmidx)
                        bacm = reportset.getBACMeasureName(bmidx)
                        @worksheet[rowidx,colidx] = bacm
            	        @worksheet.row(rowidx).set_format(colidx,h2_left)
                        colidx = colidx + 1
                    end
                end
            end
            # Overall Quality -------------------------------------------------------------------------------
            @worksheet[rowidx,colidx] = " "
            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
            colidx = colidx + 1
            rowidx = rowidx + 1
            
            # Iterate through each publication --------------------------------------------------------------------
            for sidx in 0..reportset.size() - 1
                # rowadj is used to track how many rows are taken up by rendering each study
                rowadj = 1                           
                if reportset.studyMemberOfEF(sidx,efid) &&
                    reportconfig.showStudy(sidx)
                    # Render cell data ----------------------------------------------------------------------------
                    colidx = 0
                    # Publication ---------------------------------------------------------------------------------
                    pub_author = reportset.getAuthor(sidx)
                    for ridx in 0..reportconfig.getNumPublicationItems() - 1
                        if (reportconfig.getPublicationConfigName(ridx) == "authorfirstonly") &&
                            (reportconfig.getPublicationConfigFlag(ridx) == 1)
                            pub_author = reportset.getFirstAuthor(sidx)
                        end
                    end
                    if pub_author.nil?
                        pub_author = "-"
                    end
                    celltxt = ""
                    for ridx in 0..reportconfig.getNumPublicationItems() - 1
                        val = reportset.getPublicationData(sidx,ridx)
                        if val.nil?
                            val = "null"
                        end
                        puts "..... publication cell - "+reportconfig.getPublicationConfigName(ridx)+" show "+reportconfig.showPublication(ridx).to_s+" celltxt "+celltxt+" add "+val
                        if reportconfig.getPublicationConfigName(ridx) == "authorfirstonly"
                            # Skip
                        else
                            if reportconfig.showPublication(ridx)
                                if celltxt.size() > 0
                                    if ridx > 4
                                        celltxt = celltxt + ", "
                                    else
                                        celltxt = celltxt + "; "
                                    end
                                end
                                if reportconfig.getPublicationConfigName(ridx) == "author"
                                    celltxt = celltxt + pub_author
                                else
                                    celltxt = celltxt + reportset.getPublicationData(sidx,ridx)
                                end
                            end
                        end
                    end
                    @worksheet[rowidx,colidx] = "["+sidx.to_s+"] "+celltxt
        	        @worksheet.row(rowidx).set_format(colidx,pub_data_left)
                    colidx = colidx + 1
                    # Design Details --------------------------------------------------------------------------------
                    for ridx in 0..reportconfig.getNumDesignDetailsItems() - 1
                        if reportconfig.showDesignDetails(ridx)
                            dd_values = reportconfig.getDesignDetailEXCELValues(sidx,ridx,reportset)
                            dd_values.each do |value|
                                @worksheet[rowidx,colidx] = value
            	                @worksheet.row(rowidx).set_format(colidx,h3_left_span)
                                colidx = colidx + 1
                            end
                        end
                    end
                    # Arms ------------------------------------------------------------------------------------------
                    for ridx in 0..reportconfig.getNumArmsItems() - 1
                        if reportconfig.showArms(ridx)
                            marker = "0"
                            if reportset.containsArmName(sidx,reportconfig.getArmsName(ridx))
                                marker = "1"
                            end
                            @worksheet[rowidx,colidx] = marker
            	            @worksheet.row(rowidx).set_format(colidx,pub_data)
                            colidx = colidx + 1
                        end
                    end
                    # Arm Details --------------------------------------------------------------------------------
                    for ridx in 0..reportconfig.getNumArmDetailsItems() - 1
                        if reportconfig.showArmDetails(ridx)
                            nmatrix = reportconfig.getNumArmDetailsMatrixConfig(ridx)
                            nfields = reportconfig.getNumArmDetailsFieldConfig(ridx)
                            if nmatrix > 0
                                # [rowidx,colidx] is the upper left corner of the matrix - reference
                                armdrnames = reportconfig.getArmDetailsMatrixRowsConfig(ridx)
                                armdcnames = reportconfig.getArmDetailsMatrixColsConfig(ridx)
                                @worksheet[rowidx,colidx] = ""
            	                @worksheet.row(rowidx).set_format(colidx,h3_left_span)
                                
                                carmdfidx = 0
                                ci = 0
                                armdcnames.each do |colname|
                                    showcol = reportconfig.getArmDetailsMatrixColFlag(ridx,carmdfidx)
                                    if showcol.to_s == "1" 
                                        @worksheet[rowidx,colidx + 1 + ci] = colname
            	                        @worksheet.row(rowidx).set_format(colidx + 1 + ci,h3_center)
                                        ci = ci + 1
                                    end
                                    carmdfidx = carmdfidx + 1
                                end
                                ri = 0
                                for armdfidx in 0..armdrnames.size - 1
                                    showcol = reportconfig.getArmDetailsMatrixRowFlag(ridx,armdfidx)
                                    if showcol.to_s == "1"
                                        # render row name
                                        @worksheet[rowidx + 1 + ri,colidx] = armdrnames[armdfidx]
            	                        @worksheet.row(rowidx + 1 + ri).set_format(colidx,h3_left)
                                        ci = 0
                                        for carmdfidx in 0..armdcnames.size - 1
                                            checkedflag = reportconfig.getArmDetailsMatrixFlag(ridx,armdfidx,carmdfidx)
                                            val = reportset.getArmDetailMatrixValue(sidx,ridx,armdfidx,carmdfidx)
                                            if checkedflag.to_s == "0"
                                                if !val.nil? && (val.size > 0)
                                                    val = "[-]"
                                                else
                                                    val = "-"
                                                end
                                            end
                                            showcol = reportconfig.getArmDetailsMatrixColFlag(ridx,carmdfidx)
                                            if showcol.to_s == "1" 
                                                @worksheet[rowidx + 1 + ri,colidx + 1 + ci] = val
            	                                @worksheet.row(rowidx + 1 + ri).set_format(colidx + 1 + ci,val_center)
                                                ci = ci + 1
                                            end
                                        end
                                        ri = ri + 1
                                    end
                                end 
                                # Check how many rows to move down 
                                nrows = reportconfig.getArmDetailsMatrixNRows(ridx) + 1
                                if nrows > rowadj
                                    rowadj = nrows
                                end
                            else
                                # Single value
                                @worksheet[rowidx,colidx] = reportset.getArmDetailValue(sidx,ridx)
                	            @worksheet.row(rowidx).set_format(colidx,h3_left)
                            end
                            
                            ncols = reportconfig.getArmDetailsMatrixNCols(ridx)
                            colidx = colidx + ncols
                            if (reportconfig.isArmDetailsMatrix(ridx))
                                # Adjust 1 for row titles
                                colidx = colidx + 1
                            end
                        end
                    end
                    # Baseline Characteristics ----------------------------------------------------------------------
                    for ridx in 0..reportconfig.getNumBaselineItems() - 1
                        if reportconfig.showBaseline(ridx)
                            bl = reportconfig.getBaselineName(ridx)
                            sublabels = getBaselineColLabels(reportconfig, reportset, bl)
                            sublabels.each do |sl|
                                bl_dp_id = reportset.getBaselineIDByLabel(sidx,sl)
                                @worksheet[rowidx,colidx] = reportset.getBaselineValueByLabelID(sidx,bl_dp_id)
                	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                                colidx = colidx + 1
                            end
                        end
                    end
                    # Outcome Timepoints ----------------------------------------------------------------------------
                    for ridx in 0..reportconfig.getNumOutcomeTimepointsItems() - 1
                        if reportconfig.showOutcomeTimepoints(ridx)
                            marker = "0"
                            if reportset.containsTimePointsName(sidx,reportconfig.getOutcomeTimepointsName(ridx))
                                marker = "1"
                            end
                            @worksheet[rowidx,colidx] = marker
            	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                            colidx = colidx + 1
                        end
                    end
                    # Outcome Measures ------------------------------------------------------------------------------
                    for ridx in 0..reportconfig.getNumOutcomeMeasuresItems() - 1
                        if reportconfig.showOutcomeMeasures(ridx)
                            marker = "0"
                            if reportset.containsOutcomeMeasureName(sidx,reportconfig.getOutcomeMeasuresName(ridx))
                                marker = "1"
                            end
                            @worksheet[rowidx,colidx] = marker
            	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                            colidx = colidx + 1
                        end
                    end
                    # Outcome Results -------------------------------------------------------------------------------
                    max_rows = rowidx
                    for ridx in 0..reportconfig.getNumOutcomesItems() - 1
                        if reportconfig.showOutcomes(ridx)
                            out_rowidx = rowidx
                            outcomename = reportconfig.getOutcomesName(ridx)
                            # For measures - iterate through all the different timepoints and arms attached to the outcome measure
                            for aidx in 0..reportconfig.getNumArmsItems()
                                if reportconfig.showArms(aidx)
                                    armname = reportconfig.getArmsName(aidx)
                                    armdesc = reportconfig.getArmsDesc(aidx)
                                    for sgidx in 0..reportconfig.getNumOutcomeSubgroupsItems() - 1
                                        if reportconfig.showOutcomeSubgroups(sgidx)
                                            sgname = reportconfig.getOutcomeSubgroupsName(sgidx)
                                            sgdesc = reportconfig.getOutcomeSubgroupsDesc(sgidx)
                                            for tpidx in 0..reportconfig.getNumOutcomeTimepointsItems() - 1
                                                if reportconfig.showOutcomeTimepoints(tpidx)
                                                    tpname = reportconfig.getOutcomeTimepointsName(tpidx)
                                                    tpdesc = reportconfig.getOutcomeTimepointsDesc(tpidx)
                                                    for midx in 0..reportconfig.getNumOutcomeMeasuresItems() - 1
                                                        if reportconfig.showOutcomeMeasures(midx)
                                                            measname = reportconfig.getOutcomeMeasuresName(midx)
                                                            measdesc = reportconfig.getOutcomeMeasuresDesc(midx)
                                                            val = reportset.getOutcomesValue(sidx,outcomename,sgname,tpname,measname,armname)
                                                            if !val.nil?
                                                                @worksheet[out_rowidx,colidx] = armdesc
                                                                @worksheet[out_rowidx,colidx + 1] = sgdesc
                                                                @worksheet[out_rowidx,colidx + 2] = tpdesc
                                                                @worksheet[out_rowidx,colidx + 3] = measdesc
                                                                @worksheet[out_rowidx,colidx + 4] = val
                                                                out_rowidx = out_rowidx + 1
                                                            end
                                                        end # if showOutcomeMeasures
                                                    end # for outcome measures
                                                end # if showOutcomeTimepoints
                                            end # for outcome timepoints
                                        end # if showOutcomeSubgroups
                                    end # for outcome subgroups
                                end # if showArms
                            end # for outcomes
                            if out_rowidx > max_rows
                                max_rows = out_rowidx
                            end
                            colidx = colidx + 5
                        end
                    end
                    # Outcome Details --------------------------------------------------------------------------------
                    for ridx in 0..reportconfig.getNumOutcomeDetailsItems() - 1
                        if reportconfig.showOutcomeDetails(ridx)
                            nmatrix = reportconfig.getNumOutcomeDetailsMatrixConfig(ridx)
                            nfields = reportconfig.getNumOutcomeDetailsFieldConfig(ridx)
                            if nmatrix > 0
                                # [rowidx,colidx] is the upper left corner of the matrix - reference
                                outcomedrnames = reportconfig.getOutcomeDetailsMatrixRowsConfig(ridx)
                                outcomedcnames = reportconfig.getOutcomeDetailsMatrixColsConfig(ridx)
                                @worksheet[rowidx,colidx] = ""
            	                @worksheet.row(rowidx).set_format(colidx,h3_left_span)
                                
                                coutcomedfidx = 0
                                ci = 0
                                outcomedcnames.each do |colname|
                                    showcol = reportconfig.getOutcomeDetailsMatrixColFlag(ridx,coutcomedfidx)
                                    if showcol.to_s == "1" 
                                        @worksheet[rowidx,colidx + 1 + ci] = colname
            	                        @worksheet.row(rowidx).set_format(colidx + 1 + ci,h3_center)
                                        ci = ci + 1
                                    end
                                    coutcomedfidx = coutcomedfidx + 1
                                end
                                ri = 0
                                for outcomedfidx in 0..outcomedrnames.size - 1
                                    showcol = reportconfig.getOutcomeDetailsMatrixRowFlag(ridx,outcomedfidx)
                                    if showcol.to_s == "1"
                                        # render row name
                                        @worksheet[rowidx + 1 + ri,colidx] = outcomedrnames[outcomedfidx]
            	                        @worksheet.row(rowidx + 1 + ri).set_format(colidx,h3_left)
                                        ci = 0
                                        for coutcomedfidx in 0..outcomedcnames.size - 1
                                            checkedflag = reportconfig.getOutcomeDetailsMatrixFlag(ridx,outcomedfidx,coutcomedfidx)
                                            val = reportset.getOutcomeDetailMatrixValue(sidx,ridx,outcomedfidx,coutcomedfidx)
                                            if checkedflag.to_s == "0"
                                                if !val.nil? && (val.size > 0)
                                                    val = "[-]"
                                                else
                                                    val = "-"
                                                end
                                            end
                                            showcol = reportconfig.getOutcomeDetailsMatrixColFlag(ridx,coutcomedfidx)
                                            if showcol.to_s == "1" 
                                                @worksheet[rowidx + 1 + ri,colidx + 1 + ci] = val
            	                                @worksheet.row(rowidx + 1 + ri).set_format(colidx + 1 + ci,val_center)
                                                ci = ci + 1
                                            end
                                        end
                                        ri = ri + 1
                                    end
                                end 
                                # Check how many rows to move down 
                                nrows = reportconfig.getOutcomeDetailsMatrixNRows(ridx) + 1
                                if nrows > rowadj
                                    rowadj = nrows
                                end
                            else
                                # Single value
                                @worksheet[rowidx,colidx] = reportset.getOutcomeDetailValue(sidx,ridx)
                	            @worksheet.row(rowidx).set_format(colidx,h3_left)
                            end
                            
                            ncols = reportconfig.getOutcomeDetailsMatrixNCols(ridx)
                            colidx = colidx + ncols
                            if (reportconfig.isOutcomeDetailsMatrix(ridx))
                                # Adjust 1 for row titles
                                colidx = colidx + 1
                            end
                        end
                    end
                    # Adverse Events -------------------------------------------------------------------------------
                    for ridx in 0..reportconfig.getNumAdverseEventsItems() - 1
                        if reportconfig.showAdverseEvents(ridx)
                            celltxt = ""
                            advename = reportconfig.getAdverseEventsName(ridx)
                            for aidx in 0..reportconfig.getNumArmsItems()
                                armname = reportconfig.getArmsName(aidx)
                                armdesc = reportconfig.getArmsDesc(aidx)
                                val = reportset.getAdverseEventsValue(sidx,advename,armname)
                                if !val.nil?
                                    if celltxt.size() > 0
                                        celltxt = celltxt + "; "
                                    end
                                    celltxt = "["+armdesc+"] "+val
                                end
                            end
                            @worksheet[rowidx,colidx] = celltxt
            	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                            colidx = colidx + 1
                        end
                    end
                    # Quality Dimensions -------------------------------------------------------------------------------
                    for ridx in 0..reportconfig.getNumQualityDimItems() - 1
                        if reportconfig.showQualityDim(ridx)
                            val = reportset.getQualityDimValue(sidx,reportconfig.getQualityDimName(ridx))
                            if val.nil?
                                val = "-"
                            end
                            @worksheet[rowidx,colidx] = val
            	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                            colidx = colidx + 1
                        end
                    end
                    # Between Arms Comparisons -------------------------------------------------------------------------
                    bac_ridx = rowidx
                    bac_colidx = colidx
                    if (reportconfig.getNumBACCols() * reportconfig.getNumBACMeasureCols()) > 0
                        # iterate through all the outcomes, subgroups, timepoints, comparators, and comp measures
                        for outidx in 0..reportconfig.getNumOutcomesItems() - 1
                            puts ".....previewFlat - outcomes["+outidx.to_s+"] of "+reportconfig.getNumOutcomesItems().to_s
                            if reportconfig.showOutcomes(outidx)
                                outcomename = reportconfig.getOutcomesName(outidx)
                                if reportset.containsOutcomeName(sidx,outcomename)
                                    for sgidx in 0..reportconfig.getNumOutcomeSubgroupsItems() - 1
                                        puts ".....previewFlat - subgroups["+sgidx.to_s+"] of "+reportconfig.getNumOutcomeSubgroupsItems().to_s
                                        if reportconfig.showOutcomeSubgroups(sgidx)
                                            sgname = reportconfig.getOutcomeSubgroupsName(sgidx)
                                            sgdesc = reportconfig.getOutcomeSubgroupsDesc(sgidx)
                                            if reportset.containsDistinctSubGroupsName(sidx,sgname)
                                                for tpidx in 0..reportconfig.getNumOutcomeTimepointsItems() - 1
                                                    puts ".....previewFlat - timepoints["+tpidx.to_s+"] of "+reportconfig.getNumOutcomeTimepointsItems().to_s
                                                    if reportconfig.showOutcomeTimepoints(tpidx)
                                                        tpname = reportconfig.getOutcomeTimepointsName(tpidx)
                                                        tpdesc = reportconfig.getOutcomeTimepointsDesc(tpidx)+":"+reportconfig.getOutcomeTimepointsFlag(tpidx).to_s
                                                        if reportset.containsTimePointsName(sidx,tpname)
                                                            for bidx in 0..reportconfig.getNumBACItems() - 1
                                                                puts ".....previewFlat - comparators["+bidx.to_s+"] of "+reportconfig.getNumBACItems().to_s
                                                                if reportconfig.showBAC(bidx)
                                                                    bac = reportconfig.getBACName(bidx)
                                                                    bac_desc = reportconfig.getBACDesc(bidx)
                                                                    if reportset.containsBACComparatorName(sidx,bac)
                                                                        @worksheet[bac_ridx,bac_colidx] = "["+sidx.to_s+"] "+outcomename
                    	                                                @worksheet.row(bac_ridx).set_format(bac_colidx,h2_left)
                                                                        bac_colidx = bac_colidx + 1
                                                                        @worksheet[bac_ridx,bac_colidx] = sgname
                    	                                                @worksheet.row(bac_ridx).set_format(bac_colidx,h2_left)
                                                                        bac_colidx = bac_colidx + 1
                                                                        @worksheet[bac_ridx,bac_colidx] = tpname
                    	                                                @worksheet.row(bac_ridx).set_format(bac_colidx,h2_left)
                                                                        bac_colidx = bac_colidx + 1
                                                                        @worksheet[bac_ridx,bac_colidx] = bac
                    	                                                @worksheet.row(bac_ridx).set_format(bac_colidx,h2_left)
                                                                        bac_colidx = bac_colidx + 1
                                                                        for bmidx in 0..reportconfig.getNumBACMeasureCols() - 1
                                                                            puts ".....previewFlat - comparison measures ["+bmidx.to_s+"] of "+reportconfig.getNumBACMeasureCols().to_s
                                                                            if reportconfig.showBACMeasure(bmidx)
                                                                                bacm = reportset.getBACMeasureName(bmidx)
                                                                                if reportset.containsBACMeasureName(sidx,bacm)
                                                                                    @worksheet[bac_ridx,bac_colidx] = reportset.getBACValue(sidx,outcomename,sgname,tpname,bac,bacm)
                                                                                else
                                                                                    @worksheet[bac_ridx,bac_colidx] = "-"   # this study doesn't contain the bac measure
                                                                                end
                            	                                                @worksheet.row(bac_ridx).set_format(bac_colidx,h2_left)
                                                                                bac_colidx = bac_colidx + 1
                                                                            end     # if reportconfig.showBACMeasure(bmidx)
                                                                        end     # reportconfig.getNumBACMeasureCols()
                                                                        bac_ridx = bac_ridx + 1
                                                                        bac_colidx = colidx
                                                                    end     # containsBACComparatorName
                                                                end     # if reportconfig.showBAC(bidx)
                                                            end     # reportconfig.getNumBAC()
                                                        end
                                                    end     # if reportconfig.showOutcomeTimepoints(tpidx)
                                                end     # reportconfig.getNumOutcomeTimepointsItems()
                                            end     # containsDistinctSubGroupsName
                                        end     # if reportconfig.showOutcomeSubgroups(sgidx)
                                    end     # reportconfig.getNumOutcomeSubgroupsItems()
                                end     # containsOutcomeName
                            end     # if reportconfig.showOutcomes(outidx) 
                        end     # reportconfig.getNumOutcomesItems()
                        colidx = colidx + reportconfig.getNumBACMeasureCols() + 4
                    end
                    if rowidx < bac_ridx
                        rowidx = bac_ridx
                    end
                    # Overall Quality -------------------------------------------------------------------------------
                    @worksheet[rowidx,colidx] = reportset.getTotalQualityValue(sidx)
    	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                    colidx = colidx + 1
                    if (rowidx + rowadj) > max_rows
                        rowidx = rowidx + rowadj
                    else
                        rowidx = max_rows
                    end
                end
            end # end for publications
            rowidx = rowidx + 2
        end # end for efs
    end
    
    # Helper method for rendering report by Extraction Forms
    # @doc - EXCEL document
    # @worksheet - single worksheet where everything gets written to
    # rowidx - start in this row
    def self.renderByArms(rowidx, reportconfig, reportset)
		# EXCEL FORMATTING ========================================================================
		h1_left = Spreadsheet::Format.new(:weight=>:bold,:size=>12,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		h2_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		h2_left_span = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>false)
		h3_left = Spreadsheet::Format.new(:weight=>:bold,:size=>9,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		h3_left_span = Spreadsheet::Format.new(:weight=>:bold,:size=>9,:align=>'left',:vertical_align=>'top',:text_wrap=>false)
		h3_center = Spreadsheet::Format.new(:weight=>:bold,:size=>9,:align=>'center',:vertical_align=>'top',:text_wrap=>true)
		val_center = Spreadsheet::Format.new(:size=>9,:align=>'center',:vertical_align=>'top',:text_wrap=>true)
		title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		prj_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>false,:color=>:blue)
		ef_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>false,:color=>:blue)
		arms_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>false,:color=>:blue)
		seg_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>11,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		subseg_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>10,:align=>'center',:vertical_align=>'top',:text_wrap=>true)
		pub_title_left = Spreadsheet::Format.new(:weight=>:bold,:size=>10,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		pub_data_left = Spreadsheet::Format.new(:size=>10,:align=>'left',:vertical_align=>'top',:text_wrap=>true)
		pub_data = Spreadsheet::Format.new(:size=>10,:align=>'center',:vertical_align=>'top',:text_wrap=>true)
        datacolwidth = 20
		# EXCEL FORMATTING ========================================================================
        
        for aidx in 0..reportconfig.getNumArmsItems()
            armname = reportconfig.getArmsName(aidx)
            armdesc = reportconfig.getArmsDesc(aidx)
            @worksheet.row(rowidx).concat ["Arm: "+armdesc]
	        @worksheet.row(rowidx).set_format(0,ef_title_left)
            rowidx = rowidx + 1
            
            # Render header data ----------------------------------------------------------------------------
            colidx = 0
            # Publication
            @worksheet[rowidx,colidx] = "Publication Summary"
	        @worksheet.row(rowidx).set_format(colidx,ef_title_left)
            colidx = colidx + 1
            # Design Details --------------------------------------------------------------------------------
            if reportconfig.getNumShowDesignDetails() > 0
                @worksheet[rowidx,colidx] = "Design Details"
	            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
                colidx = colidx + reportconfig.getNumShowDesignDetails()
            end
            # Arm Details --------------------------------------------------------------------------------
            if reportconfig.getNumShowArmDetails() > 0
                @worksheet[rowidx,colidx] = "Arm Details"
	            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
                colidx = colidx + reportconfig.getNumShowArmDetails()
            end
            # Baseline Characteristics ----------------------------------------------------------------------
            if reportconfig.getNumShowBaseline() > 0
                @worksheet[rowidx,colidx] = "Baseline Characteristics"
	            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
                colidx = colidx + reportconfig.getNumShowBaseline()
            end
            # Outcome Timepoints ----------------------------------------------------------------------------
            if reportconfig.getNumOutcomeTimepointsCols() > 0
                @worksheet[rowidx,colidx] = "Outcome Timepoints"
	            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
                colidx = colidx + reportconfig.getNumOutcomeTimepointsCols()
            end
            # Outcome Measures ------------------------------------------------------------------------------
            if reportconfig.getNumOutcomeMeasuresCols() > 0
                @worksheet[rowidx,colidx] = "Outcome Measures"
	            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
                colidx = colidx + reportconfig.getNumOutcomeMeasuresCols()
            end
            # Outcome Results -------------------------------------------------------------------------------
            if reportconfig.getNumOutcomesCols() > 0
                @worksheet[rowidx,colidx] = "Outcome Results"
	            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
                colidx = colidx + (4 * reportconfig.getNumOutcomesCols())
            end
            # Outcome Details --------------------------------------------------------------------------------
            if reportconfig.getNumShowOutcomeDetails() > 0
                @worksheet[rowidx,colidx] = "Outcome Details"
	            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
                colidx = colidx + reportconfig.getNumShowOutcomeDetails()
            end
            # Adverse Events -------------------------------------------------------------------------------
            if reportconfig.getNumAdverseEventsCols() > 0
                @worksheet[rowidx,colidx] = "Adverse Events"
	            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
                colidx = colidx + reportconfig.getNumAdverseEventsCols()
            end
            # Quality Dimensions -------------------------------------------------------------------------------
            if reportconfig.getNumQualityDimCols() > 0
                @worksheet[rowidx,colidx] = "Quality Dimensions"
	            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
                colidx = colidx + reportconfig.getNumQualityDimCols()
            end
            # Overall Quality -------------------------------------------------------------------------------
            @worksheet[rowidx,colidx] = "Overall Quality"
            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
            colidx = colidx + 1
            rowidx = rowidx + 1
            # Render sub-header data ----------------------------------------------------------------------------
            colidx = 0
            # Publication
            @worksheet[rowidx,colidx] = " "
	        @worksheet.row(rowidx).set_format(colidx,ef_title_left)
            colidx = colidx + 1
            # Design Details --------------------------------------------------------------------------------
            # Check for matrix 
            for ridx in 0..reportconfig.getNumDesignDetailsItems() - 1
                if reportconfig.showDesignDetails(ridx)
                    @worksheet[rowidx,colidx] = reportconfig.getDesignDetailsDesc(ridx)
    	            @worksheet.row(rowidx).set_format(colidx,h2_left_span)
                    ncols = reportconfig.getDesignDetailsMatrixNCols(ridx)
                    colidx = colidx + ncols
                    if (reportconfig.isDesignDetailsMatrix(ridx))
                        # Adjust 1 for row titles
                        colidx = colidx + 1
                    end
                end
            end
            # Arm Details --------------------------------------------------------------------------------
            # Check for matrix 
            for ridx in 0..reportconfig.getNumArmDetailsItems() - 1
                if reportconfig.showArmDetails(ridx)
                    @worksheet[rowidx,colidx] = reportconfig.getArmDetailsDesc(ridx)
    	            @worksheet.row(rowidx).set_format(colidx,h2_left_span)
                    ncols = reportconfig.getArmDetailsMatrixNCols(ridx)
                    colidx = colidx + ncols
                    if (reportconfig.isArmDetailsMatrix(ridx))
                        # Adjust 1 for row titles
                        colidx = colidx + 1
                    end
                end
            end
            # Baseline Characteristics ----------------------------------------------------------------------
            for ridx in 0..reportconfig.getNumBaselineItems() - 1
                if reportconfig.showBaseline(ridx)
                    @worksheet[rowidx,colidx] = reportconfig.getBaselineDesc(ridx)
    	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                    colidx = colidx + 1
                end
            end
            # Outcome Timepoints ----------------------------------------------------------------------------
            for ridx in 0..reportconfig.getNumOutcomeTimepointsItems() - 1
                if reportconfig.showOutcomeTimepoints(ridx)
                    @worksheet[rowidx,colidx] = reportconfig.getOutcomeTimepointsDesc(ridx)
    	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                    colidx = colidx + 1
                end
            end
            # Outcome Measures ------------------------------------------------------------------------------
            for ridx in 0..reportconfig.getNumOutcomeMeasuresItems() - 1
                if reportconfig.showOutcomeMeasures(ridx)
                    @worksheet[rowidx,colidx] = reportconfig.getOutcomeMeasuresDesc(ridx)
    	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                    colidx = colidx + 1
                end
            end
            # Outcome Results -------------------------------------------------------------------------------
            for ridx in 0..reportconfig.getNumOutcomesItems() - 1
                if reportconfig.showOutcomes(ridx)
                    @worksheet[rowidx,colidx] = reportconfig.getOutcomesDesc(ridx)+" (Subgroup)"
    	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                    colidx = colidx + 1
                    @worksheet[rowidx,colidx] = reportconfig.getOutcomesDesc(ridx)+" (Timepoint)"
    	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                    colidx = colidx + 1
                    @worksheet[rowidx,colidx] = reportconfig.getOutcomesDesc(ridx)+" (Measure)"
    	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                    colidx = colidx + 1
                    @worksheet[rowidx,colidx] = reportconfig.getOutcomesDesc(ridx)+" (Value)"
    	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                    colidx = colidx + 1
                end
            end
            # Outcome Details --------------------------------------------------------------------------------
            # Check for matrix 
            for ridx in 0..reportconfig.getNumOutcomeDetailsItems() - 1
                if reportconfig.showOutcomeDetails(ridx)
                    @worksheet[rowidx,colidx] = reportconfig.getOutcomeDetailsDesc(ridx)
    	            @worksheet.row(rowidx).set_format(colidx,h2_left_span)
                    ncols = reportconfig.getOutcomeDetailsMatrixNCols(ridx)
                    colidx = colidx + ncols
                    if (reportconfig.isOutcomeDetailsMatrix(ridx))
                        # Adjust 1 for row titles
                        colidx = colidx + 1
                    end
                end
            end
            # Adverse Events -------------------------------------------------------------------------------
            for ridx in 0..reportconfig.getNumAdverseEventsItems() - 1
                if reportconfig.showAdverseEvents(ridx)
                    @worksheet[rowidx,colidx] = reportconfig.getAdverseEventsDesc(ridx)
    	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                    colidx = colidx + 1
                end
            end
            # Quality Dimensions -------------------------------------------------------------------------------
            for ridx in 0..reportconfig.getNumQualityDimItems() - 1
                if reportconfig.showQualityDim(ridx)
                    @worksheet[rowidx,colidx] = reportconfig.getQualityDimDesc(ridx)
    	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                    colidx = colidx + 1
                end
            end
            # Overall Quality -------------------------------------------------------------------------------
            @worksheet[rowidx,colidx] = " "
            @worksheet.row(rowidx).set_format(colidx,ef_title_left)
            colidx = colidx + 1
            rowidx = rowidx + 1
            
            for sidx in 0..reportset.size() - 1
                # rowadj is used to track how many rows are taken up by rendering each study
                rowadj = 1                           
                if reportset.containsArmName(sidx,armname)
                    # Render cell data ----------------------------------------------------------------------------
                    colidx = 0
                    # Publication ---------------------------------------------------------------------------------
                    pub_author = reportset.getAuthor(sidx)
                    for ridx in 0..reportconfig.getNumPublicationItems() - 1
                        if (reportconfig.getPublicationConfigName(ridx) == "authorfirstonly") &&
                            (reportconfig.getPublicationConfigFlag(ridx) == 1)
                            pub_author = reportset.getFirstAuthor(sidx)
                        end
                    end
                    if pub_author.nil?
                        pub_author = "-"
                    end
                    celltxt = ""
                    for ridx in 0..reportconfig.getNumPublicationItems() - 1
                        val = reportset.getPublicationData(sidx,ridx)
                        if val.nil?
                            val = "null"
                        end
                        if reportconfig.getPublicationConfigName(ridx) == "authorfirstonly"
                            # Skip
                        else
                            if reportconfig.showPublication(ridx)
                                if celltxt.size() > 0
                                    if ridx > 4
                                        celltxt = celltxt + ", "
                                    else
                                        celltxt = celltxt + "; "
                                    end
                                end
                                if reportconfig.getPublicationConfigName(ridx) == "author"
                                    celltxt = celltxt + pub_author
                                else
                                    celltxt = celltxt + reportset.getPublicationData(sidx,ridx)
                                end
                            end
                        end
                    end
                    @worksheet[rowidx,colidx] = celltxt
        	        @worksheet.row(rowidx).set_format(colidx,pub_data_left)
                    colidx = colidx + 1
=begin
                    # Design Details --------------------------------------------------------------------------------
                    for ridx in 0..reportconfig.getNumDesignDetailsItems() - 1
                        if reportconfig.showDesignDetails(ridx)
                            nmatrix = reportconfig.getNumDesignDetailsMatrixConfig(ridx)
                            nfields = reportconfig.getNumDesignDetailsFieldConfig(ridx)
                            if nmatrix > 0
                                # [rowidx,colidx] is the upper left corner of the matrix - reference
                                ddrnames = reportconfig.getDesignDetailsMatrixRowsConfig(ridx)
                                ddcnames = reportconfig.getDesignDetailsMatrixColsConfig(ridx)
                                @worksheet[rowidx,colidx] = ""
            	                @worksheet.row(rowidx).set_format(colidx,h3_left_span)
                                
                                cddfidx = 0
                                ci = 0
                                ddcnames.each do |colname|
                                    showcol = reportconfig.getDesignDetailsMatrixColFlag(ridx,cddfidx)
                                    if showcol.to_s == "1" 
                                        @worksheet[rowidx,colidx + 1 + ci] = colname
            	                        @worksheet.row(rowidx).set_format(colidx + 1 + ci,h3_center)
                                        ci = ci + 1
                                    end
                                    cddfidx = cddfidx + 1
                                end
                                ri = 0
                                for ddfidx in 0..ddrnames.size - 1
                                    showcol = reportconfig.getDesignDetailsMatrixRowFlag(ridx,ddfidx)
                                    if showcol.to_s == "1"
                                        # render row name
                                        @worksheet[rowidx + 1 + ri,colidx] = ddrnames[ddfidx]
            	                        @worksheet.row(rowidx + 1 + ri).set_format(colidx,h3_left)
                                        ci = 0
                                        for cddfidx in 0..ddcnames.size - 1
                                            checkedflag = reportconfig.getDesignDetailsMatrixFlag(ridx,ddfidx,cddfidx)
                                            val = reportset.getDesignDetailMatrixValue(sidx,ridx,ddfidx,cddfidx)
                                            if checkedflag.to_s == "0"
                                                if !val.nil? && (val.size > 0)
                                                    val = "[-]"
                                                else
                                                    val = "-"
                                                end
                                            end
                                            showcol = reportconfig.getDesignDetailsMatrixColFlag(ridx,cddfidx)
                                            if showcol.to_s == "1" 
                                                @worksheet[rowidx + 1 + ri,colidx + 1 + ci] = val
            	                                @worksheet.row(rowidx + 1 + ri).set_format(colidx + 1 + ci,val_center)
                                                ci = ci + 1
                                            end
                                        end
                                        ri = ri + 1
                                    end
                                end 
                                # Check how many rows to move down 
                                nrows = reportconfig.getDesignDetailsMatrixNRows(ridx) + 1
                                if nrows > rowadj
                                    rowadj = nrows
                                end
                            else
                                # Single value
                                @worksheet[rowidx,colidx] = reportset.getDesignDetailValue(sidx,ridx)
                	            @worksheet.row(rowidx).set_format(colidx,h3_left)
                            end
                            
                            ncols = reportconfig.getDesignDetailsMatrixNCols(ridx)
                            colidx = colidx + ncols
                            if (reportconfig.isDesignDetailsMatrix(ridx))
                                # Adjust 1 for row titles
                                colidx = colidx + 1
                            end
                        end
                    end
                    # Arm Details --------------------------------------------------------------------------------
                    for ridx in 0..reportconfig.getNumArmDetailsItems() - 1
                        if reportconfig.showArmDetails(ridx)
                            nmatrix = reportconfig.getNumArmDetailsMatrixConfig(ridx)
                            nfields = reportconfig.getNumArmDetailsFieldConfig(ridx)
                            if nmatrix > 0
                                # [rowidx,colidx] is the upper left corner of the matrix - reference
                                armdrnames = reportconfig.getArmDetailsMatrixRowsConfig(ridx)
                                armdcnames = reportconfig.getArmDetailsMatrixColsConfig(ridx)
                                @worksheet[rowidx,colidx] = ""
            	                @worksheet.row(rowidx).set_format(colidx,h3_left_span)
                                
                                carmdfidx = 0
                                ci = 0
                                armdcnames.each do |colname|
                                    showcol = reportconfig.getArmDetailsMatrixColFlag(ridx,carmdfidx)
                                    if showcol.to_s == "1" 
                                        @worksheet[rowidx,colidx + 1 + ci] = colname
            	                        @worksheet.row(rowidx).set_format(colidx + 1 + ci,h3_center)
                                        ci = ci + 1
                                    end
                                    carmdfidx = carmdfidx + 1
                                end
                                ri = 0
                                for armdfidx in 0..armdrnames.size - 1
                                    showcol = reportconfig.getArmDetailsMatrixRowFlag(ridx,armdfidx)
                                    if showcol.to_s == "1"
                                        # render row name
                                        @worksheet[rowidx + 1 + ri,colidx] = armdrnames[armdfidx]
            	                        @worksheet.row(rowidx + 1 + ri).set_format(colidx,h3_left)
                                        ci = 0
                                        for carmdfidx in 0..armdcnames.size - 1
                                            checkedflag = reportconfig.getArmDetailsMatrixFlag(ridx,armdfidx,carmdfidx)
                                            val = reportset.getArmDetailMatrixValue(sidx,ridx,armdfidx,carmdfidx)
                                            if checkedflag.to_s == "0"
                                                if !val.nil? && (val.size > 0)
                                                    val = "[-]"
                                                else
                                                    val = "-"
                                                end
                                            end
                                            showcol = reportconfig.getArmDetailsMatrixColFlag(ridx,carmdfidx)
                                            if showcol.to_s == "1" 
                                                @worksheet[rowidx + 1 + ri,colidx + 1 + ci] = val
            	                                @worksheet.row(rowidx + 1 + ri).set_format(colidx + 1 + ci,val_center)
                                                ci = ci + 1
                                            end
                                        end
                                        ri = ri + 1
                                    end
                                end 
                                # Check how many rows to move down 
                                nrows = reportconfig.getArmDetailsMatrixNRows(ridx) + 1
                                if nrows > rowadj
                                    rowadj = nrows
                                end
                            else
                                # Single value
                                @worksheet[rowidx,colidx] = reportset.getArmDetailValue(sidx,ridx)
                	            @worksheet.row(rowidx).set_format(colidx,h3_left)
                            end
                            
                            ncols = reportconfig.getArmDetailsMatrixNCols(ridx)
                            colidx = colidx + ncols
                            if (reportconfig.isArmDetailsMatrix(ridx))
                                # Adjust 1 for row titles
                                colidx = colidx + 1
                            end
                        end
                    end
                    # Baseline Characteristics ----------------------------------------------------------------------
                    if reportconfig.getNumBaselineItems() > 0
                        for ridx in 0..reportconfig.getNumBaselineItems() - 1
                            if reportconfig.showBaseline(ridx)
                                celltxt = ""
                                val = reportset.getBaselineValue(sidx,reportconfig.getBaselineName(ridx),armname)
                                if val.nil?
                                    val = "-"
                                end
                                @worksheet[rowidx,colidx] = val.strip
                	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                                colidx = colidx + 1
                            end
                        end
                    end # end Design Details
                    # Outcome Timepoints ----------------------------------------------------------------------------
                    for ridx in 0..reportconfig.getNumOutcomeTimepointsItems() - 1
                        if reportconfig.showOutcomeTimepoints(ridx)
                            marker = "0"
                            if reportset.containsTimePointsName(sidx,reportconfig.getOutcomeTimepointsName(ridx))
                                marker = "1"
                            end
                            @worksheet[rowidx,colidx] = marker
            	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                            colidx = colidx + 1
                        end
                    end
                    # Outcome Measures ------------------------------------------------------------------------------
                    for ridx in 0..reportconfig.getNumOutcomeMeasuresItems() - 1
                        if reportconfig.showOutcomeMeasures(ridx)
                            marker = "0"
                            if reportset.containsOutcomeMeasureName(sidx,reportconfig.getOutcomeMeasuresName(ridx))
                                marker = "1"
                            end
                            @worksheet[rowidx,colidx] = marker
            	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                            colidx = colidx + 1
                        end
                    end
                    # Outcome Results -------------------------------------------------------------------------------
                    max_rows = rowidx
                    for ridx in 0..reportconfig.getNumOutcomesItems() - 1
                        if reportconfig.showOutcomes(ridx)
                            out_rowidx = rowidx
                            outcomename = reportconfig.getOutcomesName(ridx)
                            for sgidx in 0..reportconfig.getNumOutcomeSubgroupsItems() - 1
                                if reportconfig.showOutcomeSubgroups(sgidx)
                                    sgname = reportconfig.getOutcomeSubgroupsName(sgidx)
                                    sgdesc = reportconfig.getOutcomeSubgroupsDesc(sgidx)
                                    for tpidx in 0..reportconfig.getNumOutcomeTimepointsItems() - 1
                                        if reportconfig.showOutcomeTimepoints(tpidx)
                                            tpname = reportconfig.getOutcomeTimepointsName(tpidx)
                                            tpdesc = reportconfig.getOutcomeTimepointsDesc(tpidx)
                                            for midx in 0..reportconfig.getNumOutcomeMeasuresItems() - 1
                                                if reportconfig.showOutcomeMeasures(midx)
                                                    measname = reportconfig.getOutcomeMeasuresName(midx)
                                                    measdesc = reportconfig.getOutcomeMeasuresDesc(midx)
                                                    val = reportset.getOutcomesValue(sidx,outcomename,sgname,tpname,measname,armname)
                                                    if !val.nil?
                                                        @worksheet[out_rowidx,colidx] = sgdesc
                                                        @worksheet[out_rowidx,colidx + 1] = tpdesc
                                                        @worksheet[out_rowidx,colidx + 2] = measdesc
                                                        @worksheet[out_rowidx,colidx + 3] = val
                                                        out_rowidx = out_rowidx + 1
                                                    end
                                                end # if showOutcomeMeasures
                                            end # for outcome measures
                                        end # if showOutcomeTimepoints
                                    end # for outcome time points
                                end # if showOutcomeSubgroups
                            end # for outcome subgroups
                            if out_rowidx > max_rows
                                max_rows = out_rowidx
                            end
                            colidx = colidx + 4
                        end
                    end
                    # Outcome Details --------------------------------------------------------------------------------
                    for ridx in 0..reportconfig.getNumOutcomeDetailsItems() - 1
                        if reportconfig.showOutcomeDetails(ridx)
                            nmatrix = reportconfig.getNumOutcomeDetailsMatrixConfig(ridx)
                            nfields = reportconfig.getNumOutcomeDetailsFieldConfig(ridx)
                            if nmatrix > 0
                                # [rowidx,colidx] is the upper left corner of the matrix - reference
                                outcomedrnames = reportconfig.getOutcomeDetailsMatrixRowsConfig(ridx)
                                outcomedcnames = reportconfig.getOutcomeDetailsMatrixColsConfig(ridx)
                                @worksheet[rowidx,colidx] = ""
            	                @worksheet.row(rowidx).set_format(colidx,h3_left_span)
                                
                                coutcomedfidx = 0
                                ci = 0
                                outcomedcnames.each do |colname|
                                    showcol = reportconfig.getOutcomeDetailsMatrixColFlag(ridx,coutcomedfidx)
                                    if showcol.to_s == "1" 
                                        @worksheet[rowidx,colidx + 1 + ci] = colname
            	                        @worksheet.row(rowidx).set_format(colidx + 1 + ci,h3_center)
                                        ci = ci + 1
                                    end
                                    coutcomedfidx = coutcomedfidx + 1
                                end
                                ri = 0
                                for outcomedfidx in 0..outcomedrnames.size - 1
                                    showcol = reportconfig.getOutcomeDetailsMatrixRowFlag(ridx,outcomedfidx)
                                    if showcol.to_s == "1"
                                        # render row name
                                        @worksheet[rowidx + 1 + ri,colidx] = outcomedrnames[outcomedfidx]
            	                        @worksheet.row(rowidx + 1 + ri).set_format(colidx,h3_left)
                                        ci = 0
                                        for coutcomedfidx in 0..outcomedcnames.size - 1
                                            checkedflag = reportconfig.getOutcomeDetailsMatrixFlag(ridx,outcomedfidx,coutcomedfidx)
                                            val = reportset.getOutcomeDetailMatrixValue(sidx,ridx,outcomedfidx,coutcomedfidx)
                                            if checkedflag.to_s == "0"
                                                if !val.nil? && (val.size > 0)
                                                    val = "[-]"
                                                else
                                                    val = "-"
                                                end
                                            end
                                            showcol = reportconfig.getOutcomeDetailsMatrixColFlag(ridx,coutcomedfidx)
                                            if showcol.to_s == "1" 
                                                @worksheet[rowidx + 1 + ri,colidx + 1 + ci] = val
            	                                @worksheet.row(rowidx + 1 + ri).set_format(colidx + 1 + ci,val_center)
                                                ci = ci + 1
                                            end
                                        end
                                        ri = ri + 1
                                    end
                                end 
                                # Check how many rows to move down 
                                nrows = reportconfig.getOutcomeDetailsMatrixNRows(ridx) + 1
                                if nrows > rowadj
                                    rowadj = nrows
                                end
                            else
                                # Single value
                                @worksheet[rowidx,colidx] = reportset.getOutcomeDetailValue(sidx,ridx)
                	            @worksheet.row(rowidx).set_format(colidx,h3_left)
                            end
                            
                            ncols = reportconfig.getOutcomeDetailsMatrixNCols(ridx)
                            colidx = colidx + ncols
                            if (reportconfig.isOutcomeDetailsMatrix(ridx))
                                # Adjust 1 for row titles
                                colidx = colidx + 1
                            end
                        end
                    end
                    # Adverse Events -------------------------------------------------------------------------------
                    for ridx in 0..reportconfig.getNumAdverseEventsItems() - 1
                        if reportconfig.showAdverseEvents(ridx)
                            celltxt = ""
                            advename = reportconfig.getAdverseEventsName(ridx)
                            val = reportset.getAdverseEventsValue(sidx,advename,armname)
                            if !val.nil?
                                if celltxt.size() > 0
                                    celltxt = celltxt + "; "
                                end
                                celltxt = "["+armdesc+"] "+val
                            end
                            @worksheet[rowidx,colidx] = celltxt
            	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                            colidx = colidx + 1
                        end
                    end
                    # Quality Dimensions -------------------------------------------------------------------------------
                    for ridx in 0..reportconfig.getNumQualityDimItems() - 1
                        if reportconfig.showQualityDim(ridx)
                            val = reportset.getQualityDimValue(sidx,reportconfig.getQualityDimName(ridx))
                            if val.nil?
                                val = "-"
                            end
                            @worksheet[rowidx,colidx] = val
            	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                            colidx = colidx + 1
                        end
                    end
                    # Overall Quality -------------------------------------------------------------------------------
                    @worksheet[rowidx,colidx] = reportset.getTotalQualityValue(sidx)
    	            @worksheet.row(rowidx).set_format(colidx,h2_left)
                    colidx = colidx + 1
                    if (rowidx + rowadj) > max_rows
                        rowidx = rowidx + rowadj
                    else
                        rowidx = max_rows
                    end
=end
                end
            end # end for publications
            rowidx = rowidx + 2
        end # end for arms
    end
    
    def self.getNumBaselineCols(reportconfig, reportset)
        puts "tc_excel_export::getNumBaselineCols()"
        total_ncols = 0
        puts "-------------- tc_excel_export::getNumBaselineCols - reportconfig.getNumBaselineItems() = "+reportconfig.getNumBaselineItems().to_s
        for ridx in 0..reportconfig.getNumBaselineItems() - 1
            puts "-------------- tc_excel_export::getNumBaselineCols - ridx = "+ridx.to_s
            if reportconfig.showBaseline(ridx)
                puts "tc_excel_export::getNumBaselineCols() - show ridx "+ridx.to_s
                bl = reportconfig.getBaselineName(ridx)
                puts "tc_excel_export::getNumBaselineCols() - bl="+bl
                clabels = getBaselineColLabels(reportconfig, reportset, bl)
                if !clabels.nil?
                    total_ncols = total_ncols + clabels.size()
                end
            end
        end
        return total_ncols
    end
    
    def self.getBaselineColLabels(reportconfig, reportset, bl)
        puts "tc_excel_export::getBaselineColLabels("+bl+")"
        clabels = Array.new
        # Iterate through all the studies for unique labels for this baseline characteristic
        for sidx in 0..reportset.size() - 1
            if reportconfig.showStudy(sidx)
                puts "tc_excel_export::getBaselineColLabels("+bl+") - pull colnames from sidx="+sidx.to_s
                colnames = reportset.getBaselineColLabels(sidx,bl)
                if !colnames.nil? &&
                    (colnames.size() > 0)
                    puts "tc_excel_export::getBaselineColLabels("+bl+") - colnames = "+colnames.to_s
                    colnames.each do |cn|
                        if !clabels.include?(cn)
                            clabels << cn
                        end
                    end
                end
            end
        end
        return clabels
    end
end