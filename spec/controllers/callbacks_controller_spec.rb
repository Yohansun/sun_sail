require 'spec_helper'

describe CallbacksController do

  describe "GET 'jingdong'" do
    it "returns http success" do
      get 'jingdong'
      response.should be_success
    end
  end

end
