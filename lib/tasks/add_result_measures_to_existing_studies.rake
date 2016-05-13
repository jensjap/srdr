project_ids = [427, 553]

measures = ["Number of people (best guess)"]

namespace :jj do
    desc "Adds result measures (descriptive, bac and wac) to existing studies"
    task :add_measures_to_existing_studies => :environment do
        # Variables
        added_outcome_measure_count = 0
        added_comparison_measure_count = 0
        project_ids.each do |p_id|
            project = Project.find(p_id)
            project.studies.each do |study|
                # outcome_data_entries are for descriptive statistics.
                study.outcome_data_entries.each do |ode|
                    measures.each do |measure|
                        measure_missing = true
                        ode.outcome_measures.each do |om|
                            if om.title == measure
                                puts "Project ID: " + p_id.to_s
                                puts "Study ID: " + study.id.to_s
                                puts "Outcome Data Entry: " + ode.to_s
                                puts "Measure: " + measure.to_s
                                puts "Outcome Measure " + om.to_s
                                puts "==="
                                puts "outcome_data_entry_id: " + ode.id.to_s
                                puts "outcome_data_entry_id: " + om.outcome_data_entry_id.to_s
                                puts "title: " + om.title.to_s
                                puts "description: " + om.description.to_s
                                puts "unit: " + om.unit.to_s
                                puts "note: " + om.note.to_s
                                puts "measure_type" + om.measure_type.to_s

                                measure_missing = false
                            end
                        end
                        if measure_missing
                            puts "Creating outcome measure"
                            OutcomeMeasure.create(
                                outcome_data_entry_id: ode.id,
                                title: measure.to_s,
                                description: nil,
                                unit: nil,
                                note: nil,
                                measure_type: 1,
                                created_at: Time.now,
                                updated_at: Time.now
                            )

                            added_outcome_measure_count += 1
                        end
                    end
                end
                # comparisons are for bac and wac statistics.
                study.comparisons.each do |comparison|
                    measures.each do |measure|
                        measure_missing = true
                        comparison.comparison_measures.each do |cm|
                            if cm.title == measure
                                puts "Project ID: " + p_id.to_s
                                puts "Study ID: " + study.id.to_s
                                puts "Comparison: " + comparison.to_s
                                puts "Measure: " + measure.to_s
                                puts "Comparison Measure " + cm.to_s
                                puts "==="
                                puts "comparison_id: " + comparison.id.to_s
                                puts "comparison_id: " + cm.comparison_id.to_s
                                puts "title: " + cm.title.to_s
                                puts "description: " + cm.description.to_s
                                puts "unit: " + cm.unit.to_s
                                puts "note: " + cm.note.to_s
                                puts "measure_type" + cm.measure_type.to_s

                                measure_missing = false
                            end
                        end
                        if measure_missing
                            puts "Creating comparison measure"
                            ComparisonMeasure.create(
                                comparison_id: comparison.id,
                                title: measure.to_s,
                                description: nil,
                                unit: nil,
                                note: nil,
                                measure_type: 1,
                                created_at: Time.now,
                                updated_at: Time.now
                            )

                            added_comparison_measure_count += 1
                        end
                    end
                end
            end
        end

        puts "================================================"
        puts ">> SUMMARY <<"
        puts ">> Added " + added_outcome_measure_count.to_s + " outcome measures! <<"
        puts ">> Added " + added_comparison_measure_count.to_s + " comparison measures! <<"
        puts "================================================"
    end
end
