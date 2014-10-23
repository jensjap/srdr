# == Schema Information
#
# Table name: registars
#
#  id             :integer          not null, primary key
#  login          :string(255)
#  email          :string(255)
#  fname          :string(255)
#  lname          :string(255)
#  organization   :string(255)
#  status         :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  validationcode :string(255)
#

class Registar < ActiveRecord::Base

    # manage users accounts and requests
    def manage
        puts "............. AccountmanagerController::manage"
        # Get list of users that belongs to the administrator's organization. List all if the admin is a super-admin
        if User.current_user_has_organization_superadmin_privilege(current_user)
            @users = User.find(:all, :order => "login")
        else
            # Only bring up those users that belong to the current admin's organization
            @users = User.find(:all, :order => "login")
        end
        # Get list of user requests pending review and approval
    end
end
