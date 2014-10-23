class CreateArmDetailDataPoints < ActiveRecord::Migration
  def self.up
  	create_table :arm_detail_data_points do |t|
      BaselineCharacteristicDataPoint.columns.each do |column|
        next if column.name == "id"   # already created by create_table
        t.send(column.type.to_sym, column.name.to_sym,  :null => column.null, 
          :limit => column.limit, :default => column.default)
      end
    end
  end

  def self.down
  end
end
