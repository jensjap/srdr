namespace :send_customer_emails do
  desc "Send email notification of termination of service."
  task notify_service_termination: :environment do
    puts "Fetching users.."
    #users = User.all
    users = User.where(id: [1, 2])
    puts "done!"

    puts "Sending emails..."
    users.each do |user|
      ServiceTerminationMailer.send_notification(user).deliver
    end
    puts "done!"
  end

  task all: [:notify_service_termination]
end
