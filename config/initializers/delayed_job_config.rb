# config/initializers/delayed_job_config.rb
Delayed::Worker.destroy_failed_jobs = false
#Delayed::Worker.sleep_delay = 60
Delayed::Worker.max_attempts = 1
#Delayed::Worker.max_run_time = 5.minutes
#Delayed::Worker.read_ahead = 10
#Delayed::Worker.default_queue_name = 'default'
#Delayed::Worker.delay_jobs = !Rails.env.test?
require 'assignment_job'
require 'import_handler'
