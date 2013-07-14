require 'spec_helper'

describe AccountsController do
  login_admin


    describe "GET #index" do
      it "should success" do
        get :index 
        response.code.should eq("200")

      end
    end

    describe "POST #create" do
      it "should success" do 
        post :create, {seller_name:"test_seller", name:"seller1", phone:"138112341234"}
        response.code.should eq("200")
      end
    end
end
