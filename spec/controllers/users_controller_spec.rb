require 'spec_helper'

describe UsersController do

  describe "GET 'autologin'" do
    it "returns http success" do
      get 'autologin'
      response.should be_success
    end
  end

end
