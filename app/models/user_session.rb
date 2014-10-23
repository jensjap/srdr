# This class handles user sessions - login and logout - via the authlogic authentication gem.
# For more information see: https://github.com/binarylogic/authlogic
# For specifics about setting up authlogic on rails 3, see http://www.dixis.com/?p=352
class UserSession < Authlogic::Session::Base

    # convert the session to a key
    def to_key
        new_record? ? nil : [ self.send(self.class.primary_key) ]
    end

    def clearOldSessions
        puts "............... UserSession::clearOldSessions "
        #self.destroy_all(["created_at < ? OR updated_at < ?", 30.minutes.ago, 30.minutes.ago])
    end


end
