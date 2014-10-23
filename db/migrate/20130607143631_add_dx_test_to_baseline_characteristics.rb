class AddDxTestToBaselineCharacteristics < ActiveRecord::Migration
    def self.up
        add_column :baseline_characteristic_data_points, :diagnostic_test_id, :integer, :default=>0
        add_column :diagnostic_tests, :created_at, :datetime
        add_column :diagnostic_tests, :updated_at, :datetime
    end

    def self.down
        remove_column :baseline_characteristic_data_points, :diagnostic_test_id
        remove_column :diagnostic_tests, :created_at
        remove_column :diagnostic_tests, :updated_at
    end
end
