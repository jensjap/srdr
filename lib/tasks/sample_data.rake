namespace :db do
    desc "Fill database with sample data"
    task populate: :environment do
        User.create!(login:                 'testerbot',
                     email:                 'tester@bot.org',
                     fname:                 'tester',
                     lname:                 'bot',
                     organization:          'Test Inc.',
                     user_type:             'admin',
                     password:              'mYSecuREPassword',
                     password_confirmation: 'mYSecuREPassword',
                     password_salt:         'PmtBr8o62s0xtT5BzZ',
                     persistence_token:     'token',
                     login_count:           0,
                     failed_login_count:    0,
                     perishable_token:      'perishable')
        9999.times do |n|

            name         = Faker::Lorem.characters(14)
            email        = "example-#{n+1}@faker.org"
            persis_token = "token-#{n+1}"

            User.create!(login:                 name,
                         email:                 email,
                         fname:                 'tester',
                         lname:                 'bot',
                         organization:          'Test Inc.',
                         user_type:             'admin',
                         password:              'mYSecuREPassword',
                         password_confirmation: 'mYSecuREPassword',
                         password_salt:         'PmtBr8o62s0xtT5BzZ',
                         persistence_token:     persis_token,
                         login_count:           0,
                         failed_login_count:    0,
                         perishable_token:      'perishable')
        end
    end
end
