class StudyconsensusController < ApplicationController
  
    # Method for building a consensus study
    def createconsensus
        # Get consensus parameters and save it in the session
        export2excel = params["export2excel"] == "1"
        
        # Keep track of the selected form values in @consensus_params
        @consensus_params = Hash.new
        
        @prj_id = Integer(params["prj_id"])
        @consensus_params["prj_id"] = @prj_id
        @prj_title = params["prj_title"]
        @consensus_params["prj_title"] = @prj_title
        @project = Project.find(:first, :conditions=>["id = ?", @prj_id])
        # ------- Get Study list in comparason
        @n_studies = Integer(params["n_studies"])
        @consensus_params["n_studies"] = @n_studies
        @study_ids = Array.new
        for i in (0..@n_studies - 1)
            @study_ids << Integer(params["study_id_"+i.to_s])
            @consensus_params["study_id_"+i.to_s] = params["study_id_"+i.to_s]
            @consensus_params["study_title_"+i.to_s] = params["study_title_"+i.to_s]
        end
        @consensus_comments = params["consensus_comments"]
        @consensus_params["consensus_comments"] = @consensus_comments
        
        efids = Array.new
        for i in (0..@study_ids.size() - 1)
            study_efs = StudyExtractionForm.find(:all, :conditions=>["study_id = ?", @study_ids[i]])
            if !study_efs.nil?
	            study_efs.each do |sef|
                    if !efids.include?(sef.extraction_form_id.to_s)
                        # Add the ef id to the loaded list
                        efids << sef.extraction_form_id.to_s
                    end
                end
            end
        end
        
        # Pull consensus Study values
        @consensus_params["merge_title_text"] = params["merge_title_text"]
        @consensus_params["merge_year_text"] = params["merge_year_text"]
        @consensus_params["merge_author_text"] = params["merge_author_text"]
        @consensus_params["merge_country_text"] = params["merge_country_text"]
        @consensus_params["merge_pmid_text"] = params["merge_pmid_text"]
        @consensus_params["merge_altid_text"] = params["merge_altid_text"]
        @consensus_params["merge_journal_text"] = params["merge_journal_text"]
        @consensus_params["merge_volume_text"] = params["merge_volume_text"]
        @consensus_params["merge_issue_text"] = params["merge_issue_text"]
        
        # Now get Study Arms 
        @consensus_params["merge_arm_n_items"] = params["merge_arm_n_items"]
        @consensus_params["merge_arm_n_items"] = params["merge_arm_n_items"]
        n_arms = params["merge_arm_n_items"].to_i
        for armidx in 0..n_arms - 1
            @consensus_params["merge_arm_"+armidx.to_s+"_id"] = params["merge_arm_"+armidx.to_s+"_id"]
            @consensus_params["merge_arm_"+armidx.to_s+"_name"] = params["merge_arm_"+armidx.to_s+"_name"]
            @consensus_params["merge_arm_"+armidx.to_s+"_text"] = params["merge_arm_"+armidx.to_s+"_text"]
        end
                
        # Now get Arms information - a few categories are partitioned by arms like Baseline Characteristics
        @consensus_params["merge_bls_n_arms"] = params["merge_bls_n_arms"]
        n_arms = params["merge_bls_n_arms"].to_i
        for armidx in 0..n_arms - 1
            @consensus_params["arms_"+armidx.to_s] = params["arms_"+armidx.to_s]
        end
        
        if efids.size() == 1
            # All studies used the same extraction form
            # Pull consensus Arm Details values
            @consensus_params["merge_armds_n_items"] = params["merge_armds_n_items"]
            n_armd = Integer(params["merge_armds_n_items"])
            for idx in (0..n_armd - 1)
                @consensus_params["merge_armds_"+idx.to_s+"_id"] = params["merge_armds_"+idx.to_s+"_id"]      # Reference to ArmDetail.id
                @consensus_params["merge_armds_"+idx.to_s+"_name"] = params["merge_armds_"+idx.to_s+"_name"]
                @consensus_params["merge_armds_"+idx.to_s+"_text"] = params["merge_armds_"+idx.to_s+"_text"]
            end
        end
        
        if efids.size() == 1
            # All studies used the same extraction form
            # Pull consensus Design Details values
            @consensus_params["merge_dds_n_items"] = params["merge_dds_n_items"]
            n_dd = Integer(params["merge_dds_n_items"])
            for idx in (0..n_dd - 1)
                @consensus_params["merge_dds_"+idx.to_s+"_id"] = params["merge_dds_"+idx.to_s+"_id"]      # Reference to DesignDetail.id
                @consensus_params["merge_dds_"+idx.to_s+"_name"] = params["merge_dds_"+idx.to_s+"_name"]
                @consensus_params["merge_dds_"+idx.to_s+"_text"] = params["merge_dds_"+idx.to_s+"_text"]
            end
        end
        
        if efids.size() == 1
            # Pull consensus Baseline Characteristics values - values are listed n_bl x n_arms
            @consensus_params["merge_bls_n_studies"] = params["n_studies"]
            @consensus_params["merge_bls_n_arms"] = params["n_arms"]
            @consensus_params["merge_bls_n_bls"] = params["n_bls"]
            n_bl = Integer(params["n_bls"])
            n_arms = Integer(params["n_arms"])
            n_studies = Integer(params["n_studies"])
            for blidx in 0..n_bl - 1
                for armidx in 0..n_arms - 1
                    # Check for matrix data type comparason
                    n_complex_value = 0
                    n_single_value = 0
                    for sidx in 0..n_studies - 1
                        if params["blm_"+sidx.to_s+"_"+armidx.to_s+"_"+blidx.to_s] == "1"
                            n_complex_value = n_complex_value + 1
                        end
                        if params["blm_"+sidx.to_s+"_"+armidx.to_s+"_"+blidx.to_s] == "0"
                            n_single_value = n_single_value + 1
                        end
                    end
                    # If all studies compared are of the same data type - pick up selected values
                    if n_complex_value == n_studies
                        @consensus_params["merge_bls_"+armidx.to_s+"_"+blidx.to_s+"_complex"] = "1"
                        @consensus_params["merge_blnr_"+armidx.to_s+"_"+blidx.to_s] = params["blnr_0_"+armidx.to_s+"_"+blidx.to_s]
                        @consensus_params["merge_blnc_"+armidx.to_s+"_"+blidx.to_s] = params["blnc_0_"+armidx.to_s+"_"+blidx.to_s]
                        puts "concensus_controller:: - load params on armidx="+armidx.to_s+" blidx="+blidx.to_s+" rows="+params["blnr_0_"+armidx.to_s+"_"+blidx.to_s].to_s+" cols="+params["blnc_0_"+armidx.to_s+"_"+blidx.to_s].to_s
                        n_bl_rows = params["blnr_0_"+armidx.to_s+"_"+blidx.to_s].to_i
                        n_bl_cols = params["blnc_0_"+armidx.to_s+"_"+blidx.to_s].to_i
                        for rfidx in 0..n_bl_rows - 1
                            @consensus_params["merge_blrn_"+armidx.to_s+"_"+blidx.to_s+"_"+rfidx.to_s] = params["merge_blrn_"+armidx.to_s+"_"+blidx.to_s+"_"+rfidx.to_s]
                            for cfidx in 0..n_bl_cols - 1
                                @consensus_params["merge_blcn_"+armidx.to_s+"_"+blidx.to_s+"_"+cfidx.to_s] = params["merge_blcn_"+armidx.to_s+"_"+blidx.to_s+"_"+cfidx.to_s]
                                blref = params["blm_"+armidx.to_s+"_"+blidx.to_s+"_"+rfidx.to_s+"_"+cfidx.to_s]
                                blv = params["merge_bls_"+armidx.to_s+"_"+blidx.to_s+"_"+rfidx.to_s+"_"+cfidx.to_s]
                                blmname = params["merge_blmn_"+armidx.to_s+"_"+blidx.to_s+"_"+rfidx.to_s+"_"+cfidx.to_s]
                                if !blref.nil?
                                    @consensus_params["merge_blmn_"+armidx.to_s+"_"+blidx.to_s+"_"+rfidx.to_s+"_"+cfidx.to_s] = blmname
                                    @consensus_params["merge_blm_"+armidx.to_s+"_"+blidx.to_s+"_"+rfidx.to_s+"_"+cfidx.to_s] = blref
                                    @consensus_params["merge_bls_"+armidx.to_s+"_"+blidx.to_s+"_"+rfidx.to_s+"_"+cfidx.to_s] = blv
                                end
                            end
                        end
                    elsif n_single_value == n_studies
                        @consensus_params["merge_bls_"+armidx.to_s+"_"+blidx.to_s+"_complex"] = "0"
                        @consensus_params["merge_bls_"+armidx.to_s+"_"+blidx.to_s+"_text"] = params["bl_"+armidx.to_s+"_"+blidx.to_s]   # Value is <study id>.<arm id>.<bl id>
                        blcomps = params["bl_"+armidx.to_s+"_"+blidx.to_s].split(".")
                        @consensus_params["merge_bls_"+armidx.to_s+"_"+blidx.to_s+"_studyid"] = blcomps[0]
                        @consensus_params["merge_bls_"+armidx.to_s+"_"+blidx.to_s+"_armid"] = blcomps[1]
                        @consensus_params["merge_bls_"+armidx.to_s+"_"+blidx.to_s+"_blid"] = blcomps[2]
                    else
                        @consensus_params["merge_bls_"+armidx.to_s+"_"+blidx.to_s+"_complex"] = "-1"
                    end
                end
            end
        end
        
        # Pull consensus Arm values
        @consensus_params["merge_arm_n_items"] = params["merge_arm_n_items"]
        n_arm = Integer(params["merge_outc_n_items"])
        for idx in (0..n_arm - 1)
            # Note: name has the format <id>:<title>
            @consensus_params["merge_arm_"+idx.to_s+"_id"] = params["merge_arm_"+idx.to_s+"_id"]
            @consensus_params["merge_arm_"+idx.to_s+"_name"] = params["merge_arm_"+idx.to_s+"_name"]
            @consensus_params["merge_arm_"+idx.to_s+"_text"] = params["merge_arm_"+idx.to_s+"_text"]
        end
        
        # Pull consensus Outcomes values
        @consensus_params["merge_outc_n_items"] = params["merge_outc_n_items"]
        n_outc = Integer(params["merge_outc_n_items"])
        for idx in (0..n_outc - 1)
            # Note: name has the format <id>:<title>
            @consensus_params["merge_outc_"+idx.to_s+"_name"] = params["merge_outc_"+idx.to_s+"_name"]
            @consensus_params["merge_outc_"+idx.to_s+"_text"] = params["merge_outc_"+idx.to_s+"_text"]
        end
        
        # Pull consensus Outcome Results values
        @consensus_params["merge_outcr_n_items"] = params["merge_outcr_n_items"]
        @consensus_params["merge_outcr_n_arms"] = params["merge_outcr_n_arms"]
        @consensus_params["merge_outcr_n_timepts"] = params["merge_outcr_n_timepts"]
        @consensus_params["merge_outcr_n_meas"] = params["merge_outcr_n_meas"]
        @consensus_params["merge_outcr_n_outcomes"] = params["merge_outcr_n_outcomes"]
        n_outc = Integer(params["merge_outcr_n_outcomes"])
        for idx in (0..n_outc - 1)
            # Note: name has the format <id>:<title>
            if !params["merge_outcr_"+idx.to_s+"_id"].nil?
                @consensus_params["merge_outcr_"+idx.to_s+"_id"] = params["merge_outcr_"+idx.to_s+"_id"]
                @consensus_params["merge_outcr_"+idx.to_s+"_name"] = params["merge_outcr_"+idx.to_s+"_name"]
                @consensus_params["merge_outcr_"+idx.to_s+"_timept"] = params["merge_outcr_"+idx.to_s+"_timept"]
                @consensus_params["merge_outcr_"+idx.to_s+"_meas"] = params["merge_outcr_"+idx.to_s+"_meas"]
                @consensus_params["merge_outcr_"+idx.to_s+"_arm"] = params["merge_outcr_"+idx.to_s+"_arm"]
                @consensus_params["merge_outcr_"+idx.to_s+"_text"] = params["merge_outcr_"+idx.to_s+"_text"]
            end
        end
        
        if efids.size() == 1
            # All studies used the same extraction form
            # Pull consensus Outcome Details values
            @consensus_params["merge_outds_n_items"] = params["merge_outds_n_items"]
            n_outd = Integer(params["merge_outds_n_items"])
            for idx in (0..n_outd - 1)
                @consensus_params["merge_outds_"+idx.to_s+"_id"] = params["merge_outds_"+idx.to_s+"_id"]      # Reference to OutcomeDetail.id
                @consensus_params["merge_outds_"+idx.to_s+"_name"] = params["merge_outds_"+idx.to_s+"_name"]
                @consensus_params["merge_outds_"+idx.to_s+"_text"] = params["merge_outds_"+idx.to_s+"_text"]
            end
        end
        
        # Pull consensus Adverse Events values
        if efids.size() == 1
            @consensus_params["merge_adve_n_items"] = params["merge_adve_n_items"]
            n_adve = Integer(params["merge_adve_n_items"])
            n_arms = Integer(params["merge_adve_n_arms"])
            for idx in 0..(n_adve * n_arms) - 1
                @consensus_params["merge_adve_"+idx.to_s+"_id"] = params["merge_adve_"+idx.to_s+"_id"]          # points to AdverseEvents.id
                @consensus_params["merge_adve_"+idx.to_s+"_cid"] = params["merge_adve_"+idx.to_s+"_cid"]          # points to AdverseEventColumn.id
                @consensus_params["merge_adve_"+idx.to_s+"_rid"] = params["merge_adve_"+idx.to_s+"_rid"]          # points to AdverseEventResult.id
                @consensus_params["merge_adve_"+idx.to_s+"_name"] = params["merge_adve_"+idx.to_s+"_name"]
                @consensus_params["merge_adve_"+idx.to_s+"_arm"] = params["merge_adve_"+idx.to_s+"_arm"]
                @consensus_params["merge_adve_"+idx.to_s+"_armid"] = params["merge_adve_"+idx.to_s+"_armid"]
                @consensus_params["merge_adve_"+idx.to_s+"_text"] = params["merge_adve_"+idx.to_s+"_text"]
            end
        end
        
        # Pull consensus Quality Dimensions values
        if efids.size() == 1
            @consensus_params["merge_qualdim_n_items"] = params["merge_qualdim_n_items"]
            n_qualdim = Integer(params["merge_qualdim_n_items"])
            for idx in (0..n_qualdim - 1)
                @consensus_params["merge_qualdim_"+idx.to_s+"_id"] = params["merge_qualdim_"+idx.to_s+"_id"]
                @consensus_params["merge_qualdim_"+idx.to_s+"_name"] = params["merge_qualdim_"+idx.to_s+"_name"]
                @consensus_params["merge_qualdim_"+idx.to_s+"_text"] = params["merge_qualdim_"+idx.to_s+"_text"]
            end
        end
        @consensus_params["merge_qualdim_overallquality_name"] = params["merge_qualdim_overallquality_name"]
        @consensus_params["merge_qualdim_overallquality_text"] = params["merge_qualdim_overallquality_text"]
        session["compareset.params"] = @consensus_params
        
        if params["export2excel"] == "1"
            export_to_excel()
        else
            save_consensus
        end
    end
    
    def save_consensus
        # Get form values in @consensus_params
        @prj_id = Integer(@consensus_params["prj_id"])
        @prj_title = @consensus_params["prj_title"]
        @project = Project.find(:first, :conditions=>["id = ?", @prj_id])
        # ------- Get Study list in comparason
        @n_studies = Integer(@consensus_params["n_studies"])
        @study_ids = Array.new
        for i in (0..@n_studies - 1)
            @study_ids << Integer(@consensus_params["study_id_"+i.to_s])
        end
        @consensus_comments = @consensus_params["consensus_comments"]
        
        # Pull consensus Study values
        @pubset = Hash.new
        @pubset[:title] = @consensus_params["merge_title_text"]
        @pubset[:year] = @consensus_params["merge_year_text"]
        @pubset[:author] = @consensus_params["merge_author_text"]
        @pubset[:country] = @consensus_params["merge_country_text"]
        @pubset[:pmid] = @consensus_params["merge_pmid_text"]
        @pubset[:altid] = @consensus_params["merge_altid_text"]
        @pubset[:journal] = @consensus_params["merge_journal_text"]
        @pubset[:volume] = @consensus_params["merge_volume_text"]
        @pubset[:issue] = @consensus_params["merge_issue_text"]
        
        # ------- Study is used to link the study ID to a project ID. Studies.extraction_form_id is not used
        @study = Study.new
        @study.project_id = @prj_id
        # ------- March the study as a merged record and store both the source study ids and consensus comments into the type field
        stype = "[MERGED"
        @study_ids.each do |sid|
            stype = stype + ":"+sid.to_s
        end
        stype = stype + "] "+@consensus_comments
        @study.study_type = stype
        @study.creator_id = current_user.id
        # Not currently used - @study.extraction_form_id = xxx
		@study.created_at = Time.now
		@study.updated_at = Time.now
        @study.save
        
        # ------- Create the merged publication using the new study_id
  		@publication = PrimaryPublication.new
		@publication.study_id = @study.id
        if isValid(@pubset[:title])
		    @publication.title = @pubset[:title]
        end
        if isValid(@pubset[:year])
		    @publication.year = @pubset[:year]
        end
        if isValid(@pubset[:author])
		    @publication.author = @pubset[:author]
        end
        if isValid(@pubset[:country])
		    @publication.country = @pubset[:country]
        end
        if isValid(@pubset[:pmid])
		    @publication.pmid = @pubset[:pmid]
        end
        if isValid(@pubset[:journal])
		    @publication.journal = @pubset[:journal]
        end
        if isValid(@pubset[:volume])
		    @publication.volume = @pubset[:volume]
        end
        if isValid(@pubset[:issue])
		    @publication.issue = @pubset[:issue]
        end
		@publication.save
        
        # Save alternate ID(s) if any
        if !@consensus_params["merge_altid_text"].nil? &&
            @consensus_params["merge_altid_text"].size > 0 &&
            !@consensus_params["merge_altid_text"].eql?("Select value")
            # Format should be [type] value; [type] value;...
            alternateids = @consensus_params["merge_altid_text"].split("; ")
            alternateids.each do |altid|
                comps = altid.split("] ")
                new_altid = PrimaryPublicationNumber.new
                new_altid.primary_publication_id = @publication.id
                new_altid.number_type = comps[0][1..comps[0].size - 1]   # skip first bracket character
                new_altid.number = comps[1]
        		new_altid.created_at = Time.now
        		new_altid.updated_at = Time.now
                new_altid.save
            end
        end
        
        # ------- Create and link distinct extraction forms to the merged study id
        # ------- This will need some exception handling where user picks two studies with different EFs
        efids = Array.new
        for i in (0..@study_ids.size() - 1)
            study_efs = StudyExtractionForm.find(:all, :conditions=>["study_id = ?", @study_ids[i]])
            if !study_efs.nil?
	            study_efs.each do |sef|
                    if !efids.include?(sef.extraction_form_id.to_s)
                        new_sef = StudyExtractionForm.new
                        new_sef.study_id = @study.id
                        new_sef.extraction_form_id = sef.extraction_form_id
                		new_sef.created_at = Time.now
                		new_sef.updated_at = Time.now
                        new_sef.save
                        # Add the ef id to the loaded list
                        efids << sef.extraction_form_id.to_s
                    end
                end
            end
        end
        
        if efids.size() == 1
            # All studies used the same extraction form
            # Pull consensus Arm Details values
            n_armd = Integer(@consensus_params["merge_armds_n_items"])
            @armdset = Array.new
            for idx in (0..n_armd - 1)
                consensus_id = @consensus_params["merge_armds_"+idx.to_s+"_id"]      # Reference to ArmDetail.id
                consensus_name = @consensus_params["merge_armds_"+idx.to_s+"_name"]
                consensus_value = @consensus_params["merge_armds_"+idx.to_s+"_text"]
                if isValid(consensus_value)
                    @armdset << [consensus_name, consensus_value]
                    # Create a new ArmDetailDataPoint with the arm_detail_field_id, efids[0].to_i, and study_id
                    new_armds = ArmDetailDataPoint.new
                    new_armds.arm_detail_field_id = consensus_id.to_i
                    new_armds.extraction_form_id = efids[0].to_i
                    new_armds.study_id = @study.id
                    vcomp = consensus_value.split('|')
                    if vcomp.size() > 1
                        new_armds.value = vcomp[0]
                        if vcomp[1].size > 0
                            new_armds.subquestion_value = vcomp[1]
                        end
                    else
                        new_armds.value = vcomp[0]
                    end
                    new_armds.notes = "CONSENSUS"
                    new_armds.created_at = Time.now
                    new_armds.updated_at = Time.now
                    new_armds.save
                end
            end
        end
        
        if efids.size() == 1
            # All studies used the same extraction form
            # Pull consensus Design Details values
            n_dd = Integer(@consensus_params["merge_dds_n_items"])
            @ddset = Array.new
            for idx in (0..n_dd - 1)
                consensus_id = @consensus_params["merge_dds_"+idx.to_s+"_id"]      # Reference to DesignDetail.id
                consensus_name = @consensus_params["merge_dds_"+idx.to_s+"_name"]
                consensus_value = @consensus_params["merge_dds_"+idx.to_s+"_text"]
                if isValid(consensus_value)
                    @ddset << [consensus_name, consensus_value]
                    # Create a new DesignDetailDataPoint with the design_detail_field_id, efids[0].to_i, and study_id
                    new_dds = DesignDetailDataPoint.new
                    new_dds.design_detail_field_id = consensus_id.to_i
                    new_dds.extraction_form_id = efids[0].to_i
                    new_dds.study_id = @study.id
                    vcomp = consensus_value.split('|')
                    if vcomp.size() > 1
                        new_dds.value = vcomp[0]
                        if vcomp[1].size > 0
                            new_dds.subquestion_value = vcomp[1]
                        end
                    else
                        new_dds.value = vcomp[0]
                    end
                    new_dds.notes = "CONSENSUS"
                    new_dds.created_at = Time.now
                    new_dds.updated_at = Time.now
                    new_dds.save
                end
            end
        end
        
        if efids.size() == 1
            # Pull consensus Baseline Characteristics values - consensus_arm will indicate "total" or other
            n_bl = Integer(@consensus_params["merge_bls_n_bls"])
            n_bl_arms = Integer(@consensus_params["merge_bls_n_arms"])
            @blset = Array.new
            @bl_total_set = Array.new
            # Not sure if this is really needed anymore
            newblids = Array.new
            for blidx in 0..n_bl - 1
                for armidx in 0..n_bl_arms - 1
                    complex_data_flag = @consensus_params["merge_bls_"+armidx.to_s+"_"+blidx.to_s+"_complex"]
                    if complex_data_flag == "0"
                        consensus_value = @consensus_params["merge_bls_"+armidx.to_s+"_"+blidx.to_s+"_text"]
                        consensus_studyid = @consensus_params["merge_bls_"+armidx.to_s+"_"+blidx.to_s+"_studyid"]
                        consensus_armid = @consensus_params["merge_bls_"+armidx.to_s+"_"+blidx.to_s+"_armid"]
                        consensus_blid = @consensus_params["merge_bls_"+armidx.to_s+"_"+blidx.to_s+"_blid"]
                        puts "consensus_controller:: - blidx="+blidx.to_s+" armidx="+armidx.to_s+" blid="+consensus_blid.to_s
                        bl = BaselineCharacteristic.find(:first,:conditions=>["id = ?",consensus_blid.to_i])
                        new_bl = BaselineCharacteristic.new
                        new_bl.question = bl.question
                        new_bl.field_type = bl.field_type
                        new_bl.extraction_form_id = efids[0].to_i
                        new_bl.study_id = @study.id
                        if isValid(bl.field_notes)
                            new_bl.field_notes = bl.field_notes
                        end
                        if isValid(bl.question_number)
                            new_bl.question_number = bl.question_number
                        end
                        if isValid(bl.instruction)
                            new_bl.instruction = bl.instruction
                        end
                        if isValid(bl.is_matrix)
                            new_bl.is_matrix = bl.is_matrix
                        end
                        if isValid(bl.include_other_as_option)
                            new_bl.include_other_as_option = bl.include_other_as_option
                        end
                        new_bl.created_at = Time.now
                        new_bl.updated_at = Time.now
                        new_bl.save
                        
                        blf = BaselineCharacteristicField.find(:first,:conditions=>["baseline_characteristic_id = ?",consensus_blid.to_i])
                        new_blf = BaselineCharacteristicField.new
                        new_blf.baseline_characteristic_id = bl.id
                        if isValid(blf.option_text)
                            new_blf.option_text = blf.option_text
                        end
                        if isValid(blf.subquestion)
                            new_blf.subquestion = blf.subquestion
                        end
                        if isValid(blf.has_subquestion)
                            new_blf.has_subquestion = blf.has_subquestion
                        end
                        if isValid(blf.column_number)
                            new_blf.column_number = blf.column_number
                        end
                        if isValid(blf.row_number)
                            new_blf.row_number = blf.row_number
                        end
                        new_blf.created_at = Time.now
                        new_blf.updated_at = Time.now
                        new_blf.save
                        
                        blval = BaselineCharacteristicDataPoint.find(:first,:conditions=>["extraction_form_id = ? and baseline_characteristic_field_id = ? and study_id = ? and arm_id is not null and arm_id = ?",efids[0].to_i,blf.id.to_i,consensus_studyid.to_i,consensus_armid.to_i])
                        new_blval = BaselineCharacteristicDataPoint.new
                        new_blval.baseline_characteristic_field_id = new_blf.id
                        new_blval.value = blval.value
                        if isValid(blval.subquestion_value)
                            new_blval.subquestion_value = blval.subquestion_value
                        end
                        new_blval.study_id = @study.id
                        new_blval.extraction_form_id = efids[0].to_i
                        if !blval.arm_id? 
                            new_blval.arm_id = blval.arm_id
                        end
                        new_blval.notes = "CONSENSUS"
                        new_blval.created_at = Time.now
                        new_blval.updated_at = Time.now
                        new_blval.save
                        
                        if consensus_armid == "0"
                            @bl_total_set << [new_bl.question, new_blval.value, newblids]
                        else
                            @blset << [new_bl.question, new_blval.value]
                        end
                    else
                        n_bl_rows = @consensus_params["merge_blnr_"+armidx.to_s+"_"+blidx.to_s].to_i
                        n_bl_cols = @consensus_params["merge_blnc_"+armidx.to_s+"_"+blidx.to_s].to_i
                        for rfidx in 0..n_bl_rows - 1
                            for cfidx in 0..n_bl_cols - 1
                                blcellname = @consensus_params["merge_blmn_"+armidx.to_s+"_"+blidx.to_s+"_"+rfidx.to_s+"_"+cfidx.to_s]
                                blref = @consensus_params["merge_blm_"+armidx.to_s+"_"+blidx.to_s+"_"+rfidx.to_s+"_"+cfidx.to_s]
                                blv = @consensus_params["merge_bls_"+armidx.to_s+"_"+blidx.to_s+"_"+rfidx.to_s+"_"+cfidx.to_s]
                                if !blref.nil? &&
                                   !(blv == "SELECT")
                                    puts "New Baseline Matrix["+rfidx.to_s+","+cfidx.to_s+"] ref="+blref.to_s+" value="+blv.to_s
                                    idcomp = blref.split(".")
                                    consensus_studyid = idcomp[0].to_i
                                    consensus_armid = idcomp[1].to_i
                                    consensus_blid = idcomp[2].to_i
                                    consensus_rfidx = idcomp[3].to_i
                                    consensus_cfidx = idcomp[4].to_i
                                    bl = BaselineCharacteristic.find(:first,:conditions=>["id = ?",consensus_blid])
                                    blf = BaselineCharacteristicField.find(:first,:conditions=>["baseline_characteristic_id = ? and row_number = ? and column_number = ?",
                                                                           consensus_blid,consensus_rfidx,consensus_cfidx])
                                    
                                    @blset << [bl.question+" ("+blcellname+")", blv.to_s]
                                end
                            end
                        end
                    end
                end
            end
        end
        
        # Pull consensus Arm values
        n_arm = Integer(@consensus_params["merge_arm_n_items"])
        @armset = Array.new
        for idx in (0..n_arm - 1)
            consensus_name = @consensus_params["merge_arm_"+idx.to_s+"_name"]
            consensus_value = @consensus_params["merge_arm_"+idx.to_s+"_text"]
            @armset << [consensus_name, consensus_value]
            if !(consensus_value.size() == 0) &&
               !(consensus_value.include? 'REMOVE')
                # Add arm to the study if it doesn't already exist
                arm = Arm.find(:first,:conditions=>["title = ? and extraction_form_id = ? and study_id = ?", consensus_name, efids[0].to_i, @study.id])
                if arm.nil?
                    arm = Arm.new
                    arm.title = consensus_name
                    arm.study_id = @study.id
                    arm.extraction_form_id = efids[0].to_i
                    arm.description = "CONSENSUS"
                    arm.display_number = 0
                    arm.created_at = Time.now
                    arm.updated_at = Time.now
                    arm.is_suggested_by_admin = false
                    arm.note = "CONSENSUS"
                    arm.save
                end
            end
        end
        
        # Pull consensus Outcomes values
        n_outc = Integer(@consensus_params["merge_outc_n_items"])
        @outcset = Array.new
        for idx in (0..n_outc - 1)
            consensus_name = @consensus_params["merge_outc_"+idx.to_s+"_name"]
            consensus_value = @consensus_params["merge_outc_"+idx.to_s+"_text"]
            @outcset << [consensus_name, consensus_value]
            if !(consensus_value.size() == 0) &&
               !(consensus_value.include? 'REMOVE')
                # Add arm to the study if it doesn't already exist
                outcome = Outcome.find(:first,:conditions=>["title = ? and extraction_form_id = ? and study_id = ?", consensus_name, efids[0].to_i, @study.id])
                if outcome.nil?
                    outcome = Outcome.new
                    outcome.title = consensus_name
                    outcome.study_id = @study.id
                    outcome.extraction_form_id = efids[0].to_i
                    outcome.description = "CONSENSUS"
                    outcome.units = ""
                    outcome.is_primary = true
                    outcome.outcome_type = "Categorical"
                    outcome.created_at = Time.now
                    outcome.updated_at = Time.now
                    outcome.notes = "CONSENSUS"
                    outcome.save
                end
            end
        end
        
        # Pull consensus Outcome Results values
        n_outc = Integer(@consensus_params["merge_outcr_n_outcomes"])
        @outcrset = Array.new
        for idx in (0..n_outc - 1)
            if !@consensus_params["merge_outcr_"+idx.to_s+"_id"].nil?
                consensus_id = @consensus_params["merge_outcr_"+idx.to_s+"_id"] 
                consensus_name = @consensus_params["merge_outcr_"+idx.to_s+"_name"] 
                consensus_timepoint = @consensus_params["merge_outcr_"+idx.to_s+"_timept"] 
                consensus_measure = @consensus_params["merge_outcr_"+idx.to_s+"_meas"] 
                consensus_arm = @consensus_params["merge_outcr_"+idx.to_s+"_arm"] 
                consensus_value = @consensus_params["merge_outcr_"+idx.to_s+"_text"]
                @outcrset << [consensus_id, consensus_name, consensus_arm, consensus_timepoint, consensus_measure, consensus_value]
                
                # Only take valid consensus value
                if isValid(consensus_value)
                    outcome = Outcome.find(:first, :conditions=>["extraction_form_id = ? and title = ? and study_id = ?", efids[0].to_i, consensus_name, @study.id])
                    if outcome.nil?
                        refoutcome = Outcome.find(:first, :conditions=>["extraction_form_id = ? and title = ?", efids[0].to_i, consensus_name])
                        
                        outcome = Outcome.new
                        outcome.study_id = @study.id
                        outcome.title = consensus_name
                        if !refoutcome.nil?
                            outcome.is_primary = refoutcome.is_primary
                            outcome.description = refoutcome.description
                            outcome.outcome_type = refoutcome.outcome_type
                        else
                            outcome.is_primary = true
                            outcome.description = "CONSENSUS"
                            # outcome.outcome_type = TODO - set a default value
                        end
                        outcome.notes = "CONSENSUS"
                        outcome.extraction_form_id = efids[0].to_i
                        outcome.created_at = Time.now
                        outcome.updated_at = Time.now
                        outcome.save
                    end
                    
        	        # Now check and add data entry
                    outcome_de = OutcomeDataEntry.find(:first, :conditions=>["extraction_form_id = ? and outcome_id = ? and study_id = ?", efids[0].to_i, outcome.id, @study.id])
                    if outcome_de.nil?
        	            timepoint = OutcomeTimepoint.find(:first, :conditions=>["outcome_id = ?", outcome.id])
                        if timepoint.nil?
                            timepoint = OutcomeTimepoint.new
                            timepoint.outcome_id = outcome.id
                            timepoint.number = consensus_timepoint
                            timepoint.time_unit = "CONSENSUS"
                            timepoint.created_at = Time.now
                            timepoint.updated_at = Time.now
                            timepoint.save
                        end
                        
                        outcome_de = OutcomeDataEntry.new
                        outcome_de.extraction_form_id = efids[0].to_i
                        outcome_de.outcome_id = outcome.id
                        outcome_de.study_id = @study.id
                        outcome_de.timepoint_id = timepoint.id
                        outcome_de.display_number = 0
                        outcome_de.subgroup_id = 0
                        outcome_de.created_at = Time.now
                        outcome_de.updated_at = Time.now
                        outcome_de.save
                    end
                                
                    outcome_meas = OutcomeMeasure.find(:first,:conditions=>["outcome_data_entry_id = ?",outcome_de.id])
                    if outcome_meas.nil?
                        refmeas = OutcomeMeasure.find(:first, :conditions=>["title = ?", consensus_measure])
                        outcome_meas = OutcomeMeasure.new
                        outcome_meas.outcome_data_entry_id = outcome_de.id
                        outcome_meas.title = consensus_measure
                        if !refmeas.nil?
                            outcome_meas.description = refmeas.description
                            outcome_meas.unit = refmeas.unit
                            outcome_meas.measure_type = refmeas.measure_type
                        end
                        outcome_meas.note = "CONSENSUS"
                        outcome_meas.created_at = Time.now
                        outcome_meas.updated_at = Time.now
                        outcome_meas.save
                    end
                    
                    outcome_dp = OutcomeDataPoint.new
                    outcome_dp.outcome_measure_id = outcome_meas.id
                    if consensus_arm == "total"
                        outcome_dp.arm_id = 0
                    else
                        arm = Arm.find(:first,:conditions=>["title = ? and extraction_form_id = ?", consensus_arm, efids[0].to_i])
                        outcome_dp.arm_id = arm.id
                    end
                    outcome_dp.value = consensus_value
                    outcome_dp.footnote = "CONSENSUS"
                    outcome_dp.is_calculated = false
                    outcome_dp.created_at = Time.now
                    outcome_dp.updated_at = Time.now
                    outcome_dp.footnote_number = 0
                    outcome_dp.save
                end
            end
        end
        
        if efids.size() == 1
            # All studies used the same extraction form
            # Pull consensus Outcome Details values
            n_outd = Integer(@consensus_params["merge_outds_n_items"])
            @outdset = Array.new
            for idx in (0..n_outd - 1)
                consensus_id = @consensus_params["merge_outds_"+idx.to_s+"_id"]      # Reference to OutcomeDetail.id
                consensus_name = @consensus_params["merge_outds_"+idx.to_s+"_name"]
                consensus_value = @consensus_params["merge_outds_"+idx.to_s+"_text"]
                if isValid(consensus_value)
                    @outdset << [consensus_name, consensus_value]
                    # Create a new OutcomeDetailDataPoint with the outcome_detail_field_id, efids[0].to_i, and study_id
                    new_outds = OutcomeDetailDataPoint.new
                    new_outds.outcome_detail_field_id = consensus_id.to_i
                    new_outds.extraction_form_id = efids[0].to_i
                    new_outds.study_id = @study.id
                    vcomp = consensus_value.split('|')
                    if vcomp.size() > 1
                        new_outds.value = vcomp[0]
                        if vcomp[1].size > 0
                            new_outds.subquestion_value = vcomp[1]
                        end
                    else
                        new_outds.value = vcomp[0]
                    end
                    new_outds.notes = "CONSENSUS"
                    new_outds.created_at = Time.now
                    new_outds.updated_at = Time.now
                    new_outds.save
                end
            end
        end
        
        # Pull consensus Adverse Events values
        if efids.size() == 1
            n_adve = Integer(@consensus_params["merge_adve_n_items"])
            @adveset = Array.new
            for idx in (0..n_adve - 1)
                consensus_id = @consensus_params["merge_adve_"+idx.to_s+"_id"]          # points to AdverseEvents.id
                consensus_cid = @consensus_params["merge_adve_"+idx.to_s+"_cid"]          # points to AdverseEventColumn.id
                consensus_rid = @consensus_params["merge_adve_"+idx.to_s+"_rid"]          # points to AdverseEventResult.id
                consensus_name = @consensus_params["merge_adve_"+idx.to_s+"_name"]
                consensus_value = @consensus_params["merge_adve_"+idx.to_s+"_text"]
                if isValid(consensus_value)
                    @adveset << [consensus_name, consensus_value]
                    adve = AdverseEvent.find(:first,:conditions=>["id = ?",consensus_id.to_i])
                    adver = AdverseEventResult.find(:first,:conditions=>["id = ? and arm_id is not null and arm_id > 0",consensus_rid.to_i])
                    advec = AdverseEventColumn.find(:first,:conditions=>["id = ?",consensus_cid.to_i])
                    # consensus_name is the AdverseEvent.title
                    # Create the set of 3 adverse event records. 
                    if !adver.nil?
                        # Found non total entry
                        # Create a new AdverseEvent record
                        new_adve = AdverseEvent.new
                        new_adve.study_id = @study.id
                        new_adve.extraction_form_id = efids[0].to_i
                        new_adve.title = consensus_name
                        new_adve.description = "CONSENSUS"
                        new_adve.created_at = Time.now
                        new_adve.updated_at = Time.now
                        new_adve.save
                        # Create a new AdverseEventResult record
                        new_advr = AdverseEventResult.new
                        new_advr.column_id = consensus_cid.to_i
                        new_advr.value = consensus_value
                        new_advr.adverse_event_id = new_adve.id
                        new_advr.created_at = Time.now
                        new_advr.updated_at = Time.now
                        new_advr.arm_id = adver.arm_id
                        new_advr.save
                    end
                end
            end
            # Pull consensus Adverse Events total values
            n_bl = Integer(@consensus_params["merge_adve_n_items"])
            @adve_total_set = Array.new
            for idx in (0..n_bl - 1)
                consensus_id = @consensus_params["merge_adve_total_"+idx.to_s+"_id"]          # points to AdverseEvents.id
                consensus_cid = @consensus_params["merge_adve_total_"+idx.to_s+"_cid"]          # points to AdverseEventColumn.id
                consensus_rid = @consensus_params["merge_adve_total_"+idx.to_s+"_rid"]          # points to AdverseEventResult.id
                consensus_name = @consensus_params["merge_adve_total_"+idx.to_s+"_name"]
                consensus_value = @consensus_params["merge_adve_total_"+idx.to_s+"_text"]
                if isValid(consensus_value)
                    @adve_total_set << [consensus_name, consensus_value, newblids]
                    adve = AdverseEvent.find(:first,:conditions=>["id = ?",consensus_id.to_i])
                    adver = AdverseEventResult.find(:first,:conditions=>["id = ? and arm_id is not null and arm_id = 0",consensus_rid.to_i])
                    advec = AdverseEventColumn.find(:first,:conditions=>["id = ?",consensus_cid.to_i])
                    # consensus_name is the AdverseEvent.title
                    # Create the set of 3 adverse event records. 
                    if !adver.nil?
                        # Found non total entry
                        # Create a new AdverseEvent record
                        new_adve = AdverseEvent.new
                        new_adve.study_id = @study.id
                        new_adve.extraction_form_id = efids[0].to_i
                        new_adve.title = consensus_name
                        new_adve.description = adver.description
                        new_adve.created_at = Time.now
                        new_adve.updated_at = Time.now
                        new_adve.save
                        # Create a new AdverseEvent record
                        new_advr = AdverseEventResult.new
                        new_advr.column_id = consensus_cid.to_i
                        new_advr.value = consensus_value
                        new_advr.adverse_event_id = new_adve.id
                        new_advr.created_at = Time.now
                        new_advr.updated_at = Time.now
                        new_advr.arm_id = adver.arm_id
                        new_advr.save
                    end
                end
            end
        end
        
        # Pull consensus Quality Dimensions values
        if efids.size() == 1
            n_qualdim = Integer(@consensus_params["merge_qualdim_n_items"])
            @qualdimset = Array.new
            for idx in (0..n_qualdim - 1)
                consensus_id = @consensus_params["merge_qualdim_"+idx.to_s+"_id"]
                consensus_name = @consensus_params["merge_qualdim_"+idx.to_s+"_name"]
                consensus_value = @consensus_params["merge_qualdim_"+idx.to_s+"_text"]
                if isValid(consensus_value)
                    @qualdimset << [consensus_name, consensus_value]
                    # consensus_name is the QualityDimensionField.title
                    # For each QualityDimensionDataPoint - copy and set new value. 
                    new_qualdim = QualityDimensionDataPoint.new
                    new_qualdim.quality_dimension_field_id = consensus_id.to_i
                    new_qualdim.value = consensus_value
                    new_qualdim.study_id = @study.id
                    new_qualdim.extraction_form_id = efids[0].to_i
                    new_qualdim.notes = "CONSENSUS"
                    new_qualdim.created_at = Time.now
                    new_qualdim.updated_at = Time.now
                    new_qualdim.save
                end
            end
        end
        
        consensus_name = @consensus_params["merge_qualdim_overallquality_name"]
        consensus_value = @consensus_params["merge_qualdim_overallquality_text"]
        if isValid(consensus_value)
            @overallqualset = [consensus_name, consensus_value]
            overallqual = QualityRatingDataPoint.new
            overallqual.current_overall_rating = consensus_value
            overallqual.study_id = @study.id
            overallqual.extraction_form_id = efids[0].to_i
            overallqual.notes = "CONSENSUS"
            overallqual.created_at = Time.now
            overallqual.updated_at = Time.now
            overallqual.save
        end
    end
  
    # Export Table Comparason to EXCEL
    def export_to_excel
      	# construct the Excel file and get a list of files created
      	filenames = CompExcelExport.project_to_xls(@consensus_params, current_user)
      	
        user = current_user.login
      	fname = "#{user}_project_export.xls"
      	send_data(filenames, :type=>"application/xls",:filename=>fname)
    end
    
    # Check for valid value entered in comparson form
    def isValid(sval)
        if sval.nil? ||
            sval.strip.size == 0
            return false
        elsif sval.strip == "Select value"
            return false
        else 
            return true
        end
    end
    
    def getValidValue(sval)
        if isValid(sval)
            return sval.strip
        else
            return ""
        end
    end
end
