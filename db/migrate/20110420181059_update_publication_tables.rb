class UpdatePublicationTables < ActiveRecord::Migration
  def self.up
		change_table :primary_publications do |pp|
			pp.string :journal
			pp.string :volume
			pp.string :issue
		end
		
		change_table :secondary_publications do |sp|
			sp.string :journal
			sp.string :volume
			sp.string :issue
		end
  end

  def self.down
  end
end
