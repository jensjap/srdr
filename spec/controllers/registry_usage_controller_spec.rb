require 'spec_helper'

describe RegistryUsageController do

  describe "GET 'search_registry'" do
    it "returns http success" do
      get 'search_registry'
      response.should be_success
    end
  end

end
