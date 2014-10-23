class AddTimestampsToDiagnosticTestThresholds < ActiveRecord::Migration
    def self.up
        change_table :diagnostic_test_thresholds do |t|
            t.timestamps 
        end
    end

    def self.down
        remove_column :diagnostic_test_thresholds, :created_at
        remove_column :diagnostic_test_thresholds, :updated_at
    end
end
