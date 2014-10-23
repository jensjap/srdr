# == Schema Information
#
# Table name: outcome_data_points
#
#  id                 :integer          not null, primary key
#  outcome_measure_id :integer
#  value              :string(255)
#  footnote           :string(255)
#  is_calculated      :boolean          default(FALSE)
#  arm_id             :integer
#  created_at         :datetime
#  updated_at         :datetime
#  footnote_number    :integer          default(0)
#

class OutcomeDataPoint < ActiveRecord::Base
    belongs_to :outcome_measure, :touch=>true
    def self.save_data datapoints
        unless datapoints.keys.empty?
            datapoints.keys.each do |key|
                ids = key.split("_");
                ocid = ids[0]; tpid = ids[1]; armid = ids[2]; measid = ids[3];
                # determine if this data point already exists
                dp = OutcomeDataPoint.where(:outcome_measure_id=>measid, :arm_id=>armid).first
                value = datapoints[key]
                unless dp.nil?
                    if value == ""
                        dp.destroy
                    else
                        dp.value = datapoints[key]
                        dp.save
                    end
                else
                    unless value == ""
                        OutcomeDataPoint.create(:outcome_measure_id=>measid,:arm_id=>armid,:value=>datapoints[key])
                    end
                end
            end
        end
    end

    # self.get_data_point_object
    # given the id of a table field (ex datapoint__1_2_1_428, comparison_datapoint__1_2_3 or
    # wac_datapoint__1_2_3, return the proper outcome or comparison data point object.
    def self.get_data_point_object field_id
        # first, split the field name by [
        field_id_array = field_id.split("__")
        type = field_id_array.first
        parts = field_id_array.last.split("_")
        puts "\n\nGetting the data point object... parts is #{parts}"
        datapoint = nil
        puts "Type is #{type}\n\n"
        if type == "datapoints"
            armid = parts[2]  # arm id
            mid = parts[3]    # outcome measure id
            puts "armid is #{armid} and mid is #{mid}"
            datapoint = OutcomeDataPoint.where(:outcome_measure_id=>mid, :arm_id=>armid).first
            type = 'outcome'
        elsif type == "comparison_datapoints"
            compid = parts[1] # comparator id
            mid = parts[2]    # comparison measure id
            datapoint = ComparisonDataPoint.where(:comparison_measure_id=>mid, :comparator_id=>compid).first
            type = 'comparison'
        elsif type == "wac_datapoints"
            compid = parts[1] # comparator id
            mid = parts[2]    # comparison measure id
            armid = parts[3]  # arm id
            puts "Finding the datapoint with compid #{compid}, mid #{mid} and armid #{armid}\n\n"
            datapoint = ComparisonDataPoint.where(:comparison_measure_id=>mid, :comparator_id=>compid,
                                                  :arm_id=>armid).first
            type = 'comparison'
        elsif  type=="table2x2_datapoints"
            compid = parts[1] # comparator id
            mid = parts[2]    # comparison measure id
            cell = parts[3] # the table cell of the comparison data point
            datapoint = ComparisonDataPoint.where(:comparison_measure_id=>mid, :comparator_id=>compid, :table_cell=>cell).first
            type = 'comparison'
        end

        return [datapoint, type]
    end
    #-------------------------------------
    #-------------------------------------
    #-------------------------------------
    #---- OLD METHODS BELOW THIS LINE ---
    #-------------------------------------
    #-------------------------------------
    def self.get_data_point(outcome_id, arm_id, timepoint_id, measure_id)
        @outcome = Outcome.find(outcome_id)
        extraction_form_id = @outcome.extraction_form_id
        datapoints = OutcomeDataPoint.where(:outcome_id => outcome_id, :arm_id => arm_id, :timepoint_id => timepoint_id, :outcome_measure_id => measure_id, :extraction_form_id => extraction_form_id).all
        if datapoints.length == 0
            return nil
        else
            return datapoints[0]
        end
    end

    def self.get_data_point_value(outcome_id, arm_id, timepoint_id, measure_id)
        @outcome = Outcome.find(outcome_id)
        extraction_form_id = @outcome.extraction_form_id
        datapoints = OutcomeDataPoint.where(:outcome_id => outcome_id, :arm_id => arm_id, :timepoint_id => timepoint_id, :outcome_measure_id => measure_id, :extraction_form_id => extraction_form_id).all
        if datapoints.length == 0
            return ""
        else
            return datapoints[0].value
        end
    end

    def self.get_data_point_n_enrolled(outcome_id, arm_id, timepoint_id, measure_id)
        @outcome = Outcome.find(outcome_id)
        extraction_form_id = @outcome.extraction_form_id
        datapoints = OutcomeDataPoint.where(:outcome_id => outcome_id, :arm_id => arm_id, :timepoint_id => timepoint_id, :outcome_measure_id => measure_id, :extraction_form_id => extraction_form_id).all
        if (datapoints.length == 0) || datapoints[0].n_enrolled.nil? || (datapoints[0].n_enrolled == "")
            @arm = Arm.find(arm_id)
            return (@arm.nil? || !@arm.is_intention_to_treat) ? "" : @arm.default_num_enrolled
        else
            return datapoints[0].n_enrolled
        end
    end

    def self.get_data_point_calc(outcome_id, arm_id, timepoint_id, measure_id)
        datapoints = OutcomeDataPoint.where(:outcome_id => outcome_id, :arm_id => arm_id, :timepoint_id => timepoint_id, :outcome_measure_id => measure_id).all
        if datapoints.length == 0
            return false
        else
            return datapoints[0].is_calculated
        end
    end

    # save_data_points
    # save data points based on parameters submitted to form
    #     outcome_datapoint_outcome_X_arm_Y_timepoint_Z_measure_Q
    #     X = outcome_id
    #     Y = arm_id
    #     Z = timepoint_id
    #     Q = measure_id
    def self.save_data_points(params, study_id, extraction_form_id)
        params.each do |item, data|
            # parse each parameter element
            if (item.starts_with? "outcome_datapoint") && !(item.ends_with? "calc")
                parts = item.to_s.split("_")
                outcome_id = parts[3]
                arm_id = parts[5]
                timepoint_id = parts[7]
                measure_id = parts[9]
                existing = OutcomeDataPoint.where(:outcome_id => outcome_id, :arm_id => arm_id, :timepoint_id => timepoint_id, :outcome_measure_id => measure_id, :extraction_form_id => extraction_form_id).all
                if existing.length == 1
                    @outcome_data_point = existing[0]
                    @outcome_data_point.value = data
                    @outcome_data_point.save
                else
                    if existing.length > 1
                        existing.each do |one_point|
                            one_point.destroy
                        end
                    end
                    @outcome_data_point = OutcomeDataPoint.new
                    @outcome_data_point.outcome_id = outcome_id
                    @outcome_data_point.timepoint_id = timepoint_id
                    @outcome_data_point.arm_id = arm_id
                    @outcome_data_point.outcome_measure_id = measure_id
                    @outcome_data_point.extraction_form_id = extraction_form_id
                    @outcome_data_point.value = data
                    @outcome_data_point.save
                end
            elsif (item.starts_with? "n_enrolled")
                parts = item.to_s.split("_")
                outcome_id = parts[3]
                arm_id = parts[5]
                timepoint_id = parts[7]
                measure_id = parts[9]
                existing = OutcomeDataPoint.where(:outcome_id => outcome_id, :arm_id => arm_id, :timepoint_id => timepoint_id, :outcome_measure_id => measure_id, :extraction_form_id => extraction_form_id).all
                if existing.length == 1
                    @outcome_data_point = existing[0]
                    @outcome_data_point.n_enrolled = data
                    @outcome_data_point.save
                else
                    if existing.length > 1
                        existing.each do |one_point|
                            one_point.destroy
                        end
                    end
                    @outcome_data_point = OutcomeDataPoint.new
                    @outcome_data_point.outcome_id = outcome_id
                    @outcome_data_point.timepoint_id = timepoint_id
                    @outcome_data_point.arm_id = arm_id
                    @outcome_data_point.outcome_measure_id = measure_id
                    @outcome_data_point.n_enrolled = data
                    @outcome_data_point.extraction_form_id = extraction_form_id
                    @outcome_data_point.save
                end
            end
        end
    end


end
