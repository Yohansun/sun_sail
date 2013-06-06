require 'spec_helper'

describe NotifyController do

  describe "GET 'sms'" do
    it "returns http success" do
      get 'sms'
      response.should be_success
    end
  end

  describe "GET 'email'" do
    it "returns http success" do
      get 'email'
      response.should be_success
    end
  end

end
