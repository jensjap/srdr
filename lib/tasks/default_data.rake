    namespace :default_data do
      desc "Add default (admin) user"
      task :default_user => :environment do
        User.create(:login => 'admin', :email => 'srdr@tuftsmedicalcenter.org', :fname => 'SRDR', :lname => 'Administrator', :password => 'srdr2011', :password_confirmation => 'srdr2011', :organization => 'Tufts EPC', :user_type => 'admin')
      end

      desc "Add other users"
      task :other_users => :environment do
        User.create(:login => 'cparkin', :email => 'cparkin@tuftsmedicalcenter.org', :fname => 'Chris', :lname => 'Parkin', :password => 'test', :password_confirmation => 'test', :organization => 'Tufts EPC', :user_type => 'member')
        User.create(:login => 'skeefe', :email => 'skeefe@tuftsmedicalcenter.org', :fname => 'Sarah', :lname => 'Keefe', :password => 'test', :password_confirmation => 'test', :organization => 'Tufts EPC', :user_type => 'member')
		User.create(:login => 'nhadar', :email => 'nhadar@tuftsmedicalcenter.org', :fname => 'Nira', :lname => 'Hadar', :password => 'srdr', :password_confirmation => 'srdr', :organization => 'Tufts EPC', :user_type => 'member')
      end	  
	  
      desc "Create the default template fields"
      task :default_template_fields => :environment do
	  

        DefaultAdverseEventColumn.create( :header => '', :name => 'Timeframe', :description => 'Created by default' )
        DefaultAdverseEventColumn.create( :header => '', :name => 'Is event serious?', :description => 'Created by default' )
        DefaultAdverseEventColumn.create( :header => '', :name => 'Definition of Serious', :description => 'Created by default' )
        DefaultAdverseEventColumn.create( :header => '', :name => 'Number affected', :description => 'Created by default' )
        DefaultAdverseEventColumn.create( :header => '', :name => 'Number at risk', :description => 'Created by default' )
		
		DefaultDesignDetail.create(:title => 'Study Type', :notes =>'Created by default')
		DefaultDesignDetail.create(:title => 'Inclusion Criteria', :notes =>'Created by default')
		DefaultDesignDetail.create(:title => 'Exclusion Criteria', :notes =>'Created by default')
		
		DefaultOutcomeColumn.create(:column_name => 'n Event', :column_description => 'Created by default', :column_header => '', :outcome_type => 'Categorical')
		DefaultOutcomeColumn.create(:column_name => 'n Total', :column_description => 'Created by default', :column_header => '', :outcome_type => 'Categorical')
		DefaultOutcomeColumn.create(:column_name => 'Metric', :column_description => 'Reported; RR, OR, HR, RD; Created by default', :column_header => 'Unadjusted', :outcome_type => 'Categorical')
		DefaultOutcomeColumn.create(:column_name => 'Result', :column_description => 'Reported; Created by default', :column_header => 'Unadjusted', :outcome_type => 'Categorical')
		DefaultOutcomeColumn.create(:column_name => '95% CI', :column_description => 'Reported; Created by default', :column_header => 'Unadjusted', :outcome_type => 'Categorical')
		DefaultOutcomeColumn.create(:column_name => 'P btw', :column_description => 'Reported; Created by default', :column_header => 'Unadjusted', :outcome_type => 'Categorical')
		DefaultOutcomeColumn.create(:column_name => 'Result', :column_description => 'Reported; Created by default', :column_header => 'Adjusted', :outcome_type => 'Categorical')
		DefaultOutcomeColumn.create(:column_name => '95% CI', :column_description => 'Reported; Created by default', :column_header => 'Adjusted', :outcome_type => 'Categorical')
		DefaultOutcomeColumn.create(:column_name => 'P btw', :column_description => 'Reported; Created by default', :column_header => 'Adjusted', :outcome_type => 'Categorical')		
		DefaultOutcomeColumn.create(:column_name => 'Adjusted For', :column_description => 'Reported; Created by default', :column_header => 'Adjusted', :outcome_type => 'Categorical')		
		DefaultOutcomeColumn.create(:column_name => 'n Analyzed', :column_description => 'Created by default', :column_header => '', :outcome_type => 'Continuous')		
		DefaultOutcomeColumn.create(:column_name => 'Value', :column_description => 'Created by default', :column_header => 'Baseline', :outcome_type => 'Continuous')		
		DefaultOutcomeColumn.create(:column_name => 'SD', :column_description => 'Created by default', :column_header => 'Baseline', :outcome_type => 'Continuous')
		DefaultOutcomeColumn.create(:column_name => 'SE', :column_description => 'Created by default', :column_header => 'Baseline', :outcome_type => 'Continuous')
		DefaultOutcomeColumn.create(:column_name => 'Value', :column_description => 'Created by default', :column_header => 'Final', :outcome_type => 'Continuous')		
		DefaultOutcomeColumn.create(:column_name => 'SD', :column_description => 'Created by default', :column_header => 'Final', :outcome_type => 'Continuous')
		DefaultOutcomeColumn.create(:column_name => 'SE', :column_description => 'Created by default', :column_header => 'Final', :outcome_type => 'Continuous')

		DefaultOutcomeComparisonColumn.create(:column_name => 'n Analyzed', :column_description => 'Created by default', :column_header => '', :outcome_type => 'Continuous')
		DefaultOutcomeComparisonColumn.create(:column_name => 'Value', :column_description => 'Final - Baseline; Created by default', :column_header => 'Change', :outcome_type => 'Continuous')
		DefaultOutcomeComparisonColumn.create(:column_name => 'SD', :column_description => 'Final - Baseline; Created by default', :column_header => 'Change', :outcome_type => 'Continuous')
		DefaultOutcomeComparisonColumn.create(:column_name => 'SE', :column_description => 'Final - Baseline; Created by default', :column_header => 'Change', :outcome_type => 'Continuous')
		DefaultOutcomeComparisonColumn.create(:column_name => 'P', :column_description => 'Final - Baseline; Created by default', :column_header => 'Change', :outcome_type => 'Continuous')
		DefaultOutcomeComparisonColumn.create(:column_name => 'Value', :column_description => 'Created by default', :column_header => 'Net Change / Difference', :outcome_type => 'Continuous')
		DefaultOutcomeComparisonColumn.create(:column_name => 'SD', :column_description => 'Created by default', :column_header => 'Net Change / Difference', :outcome_type => 'Continuous')
		DefaultOutcomeComparisonColumn.create(:column_name => 'SE', :column_description => 'Created by default', :column_header => 'Net Change / Difference', :outcome_type => 'Continuous')
		DefaultOutcomeComparisonColumn.create(:column_name => 'P', :column_description => 'Created by default', :column_header => 'Net Change / Difference', :outcome_type => 'Continuous')

		DefaultQualityRatingField.create(:rating_item => 'Good', :display_number => '1')
		DefaultQualityRatingField.create(:rating_item => 'Fair', :display_number => '2')
		DefaultQualityRatingField.create(:rating_item => 'Poor', :display_number => '3')
      end

      desc "Run all default_data tasks"
      task :all => [:default_user, :default_template_fields]
    end
