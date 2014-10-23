class SetupOutcomeDetails < ActiveRecord::Migration
  def self.up
  	create_table :outcome_details do |t|
      DesignDetail.columns.each do |column|
        next if column.name == "id"   # already created by create_table
        t.send(column.type.to_sym, column.name.to_sym,  :null => column.null, 
          :limit => column.limit, :default => column.default)
      end
    end

    create_table :outcome_detail_fields do |t|
    	DesignDetailField.columns.each do |column|
        next if column.name == "id"   # already created by create_table
        if column.name == 'design_detail_id'
        	t.integer :outcome_detail_id
        else
        	t.send(column.type.to_sym, column.name.to_sym,  :null => column.null, 
          	:limit => column.limit, :default => column.default)
       	end
      end
    end

    create_table :outcome_detail_data_points do |t|
    	DesignDetailDataPoint.columns.each do |column|
        next if column.name == "id"   # already created by create_table
        if column.name == 'design_detail_field_id'
        	t.integer :outcome_detail_field_id
        else
        	t.send(column.type.to_sym, column.name.to_sym,  :null => column.null, 
          	:limit => column.limit, :default => column.default)
       	end
      end
    end
  end

  def self.down
  end
end
