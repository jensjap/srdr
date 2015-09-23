require 'spec_helper'

describe BryantFormController do

  describe "GET 'form'" do
    it "returns http success" do
      get 'form'
      response.should be_success
    end
  end

end
