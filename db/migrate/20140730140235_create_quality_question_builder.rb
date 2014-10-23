class CreateQualityQuestionBuilder < ActiveRecord::Migration
  def self.up
    #----- CREATE THE TABLES NEEDED FOR DEFINING A NEW QUESTION TYPE
    create_table :quality_details do |t|
      DesignDetail.columns.each do |column|
        next if column.name == "id"   # already created by create_table
        t.send(column.type.to_sym, column.name.to_sym,  :null => column.null, 
          :limit => column.limit, :default => column.default)
      end
    end

    create_table :quality_detail_fields do |t|
      DesignDetailField.columns.each do |column|
        next if column.name == "id"   # already created by create_table
        if column.name == 'design_detail_id'
          t.integer :quality_detail_id
        else
          t.send(column.type.to_sym, column.name.to_sym,  :null => column.null, 
            :limit => column.limit, :default => column.default)
        end
      end
    end

    create_table :quality_detail_data_points do |t|
      DesignDetailDataPoint.columns.each do |column|
        next if column.name == "id"   # already created by create_table
        if column.name == 'design_detail_field_id'
          t.integer :quality_detail_field_id
        else
          t.send(column.type.to_sym, column.name.to_sym,  :null => column.null, 
            :limit => column.limit, :default => column.default)
        end
      end
    end

    create_table :eft_quality_details do |t|
      t.integer :extraction_form_id
      t.text :question 
      t.string :field_type 
      t.string :field_note 
      t.integer :question_number 
      t.text :instruction 
      t.boolean :is_matrix 
      t.boolean :include_other_as_option 
    end

    create_table :eft_quality_detail_fields do |t|
      t.integer :eft_quality_detail_id 
      t.string :option_text 
      t.string :subquestion 
      t.boolean :has_subquestion 
      t.integer :row_number 
      t.integer :column_number 
    end

    #----- ADD INDECES
    add_index :quality_details, [:extraction_form_id, :question_number], :name=>'qd_efix'
    add_index :quality_detail_fields, [:quality_detail_id, :row_number], :name=>'qdf_odix'
    add_index :quality_detail_data_points, [:quality_detail_field_id, :study_id], :name=>'qddp_odix'
  end

  def self.down
    # remove the indeces
    remove_index :quality_details, name: 'qd_efix'
    remove_index :quality_detail_fields, name: 'qdf_odix'
    remove_index :quality_detail_data_points, name: 'qddp_odix'

    # drop the tables
    drop_table :quality_details
    drop_table :quality_detail_fields
    drop_table :quality_detail_data_points
    drop_table :eft_quality_details
    drop_table :eft_quality_detail_fields 
    

  end
end
