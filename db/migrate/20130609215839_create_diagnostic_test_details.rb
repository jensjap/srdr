class CreateDiagnosticTestDetails < ActiveRecord::Migration
  def self.up
    # DIAGNOSTIC TEST DETAILS
    create_table :diagnostic_test_details do |t|
      OutcomeDetail.columns.each do |column|
        next if column.name == "id"   # already created by create_table
        t.send(column.type.to_sym, column.name.to_sym,  :null => column.null, 
          :limit => column.limit, :default => column.default)
      end
    end

    # DIAGNOSTIC TEST DETAIL FIELDS
    create_table :diagnostic_test_detail_fields do |t|
      OutcomeDetailField.columns.each do |column|
        next if column.name == "id"   # already created by create_table
        next if column.name == "outcome_detail_id"
        t.send(column.type.to_sym, column.name.to_sym,  :null => column.null, 
          :limit => column.limit, :default => column.default)
      end
      t.integer :diagnostic_test_detail_id
    end

    # DIAGNOSTIC TEST DETAIL DATA POINTS
    create_table :diagnostic_test_detail_data_points do |t|
      OutcomeDetailDataPoint.columns.each do |column|
        # We don't need any of the following fields...
        next if ["id","outcome_detail_field_id","outcome_id","arm_id"].include?(column.name)
        
        t.send(column.type.to_sym, column.name.to_sym,  :null => column.null, 
          :limit => column.limit, :default => column.default)
      end
      t.integer :diagnostic_test_detail_field_id
      t.integer :diagnostic_test_id
    end

    # UPDATE THE EF SECTION OPTION TO INCLUDE DIAGNOSTIC TEST ID
    change_table :ef_section_options do |ef|
        ef.boolean :by_diagnostic_test, :default=>false
    end
  end

  def self.down
    drop_table :diagnostic_test_details
    drop_table :diagnostic_test_detail_fields
    drop_table :diagnostic_test_detail_data_points
    drop_colum :ef_section_options, :by_diagnostic_test
  end
end