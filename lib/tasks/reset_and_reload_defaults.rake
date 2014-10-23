# RESET AND RELOAD THE EXISTING DATABASE. INCLUDE DEFAULT MEASURES AND USER ACCOUNTS, AND
# CREATE AN EXAMPLE PROJECT.
#
# Rake::Task["namespace:taskname"].execute()  - runs the task without dependencies
# Rake::Task["namespace:taskname"].invoke()   - runs the task and dependencies unless it was already run
# Rake::Task["namespace:taskname"].reenable() - resets the already_run state on the task so that it can be run again

desc "Resetting and reloading!"
task :reset_and_reload_defaults do

	# reset the existing database and reload the tables
	Rake::Task["db:reset"].invoke();

	# run any existing migrations
	Rake::Task["db:migrate"].invoke();

	# load the default data
	Rake::Task["default_data:all"].invoke();

	# load the default result measures
	Rake::Task["default_result_measures:all"].invoke();

	# create the example prostate project
	Rake::Task["create_prostate_project:all"].invoke();
	
end
