require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
    before(:each) do
        @valid_attributes = {
            :login => 'testerbot',
            :password => 'foobar',
            :password_confirmation => 'foobar',
            :email => 'testerbot@factory.com',
            :organization => 'tester corp',
            :fname => 'tester',
            :lname => 'bot',
            :user_type => 'public',
        }
    end

    it "should create a new instance given valid attributes" do
        user = User.create!(@valid_attributes)
        user.should be_valid
    end

    it "should not allow user with duplicate login" do
        @invalid_attributes = @valid_attributes
        @invalid_attributes[:email] = 'testerbot2'
        user1 = User.create(@valid_attributes)
        user2 = User.create(@invalid_attributes)
        user2.should_not be_valid
    end

    it "should not allow user with duplicate email" do
        @invalid_attributes = @valid_attributes
        @invalid_attributes[:login] = 'testerbot2'
        user1 = User.create(@valid_attributes)
        user2 = User.create(@invalid_attributes)
        user2.should_not be_valid
    end

    it "should allow another user with all the same info except email and login" do
        @invalid_attributes = @valid_attributes.dup
        @invalid_attributes[:login] = 'testerbot2'
        @invalid_attributes[:email] = 'testerbot2@factory.com'
        user1 = User.create(@valid_attributes)
        user2 = User.create(@invalid_attributes)
        user2.should be_valid
    end
end
