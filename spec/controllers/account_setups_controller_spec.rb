require 'spec_helper'

describe AccountSetupsController do
  taobao_authed

  describe "Account setup steps" do
    it "should go to admin_init" do
      current_account.settings[:wizard_step] = :admin_init
      get :index
      response.should redirect_to("/account_setups/admin_init")
    end

    it "should create a user, and goto data_fetch step" do
      post :update, :id=>"admin_init", :user=>{email:"test@doorder.com",phone:"13312345678",username:"testuser",name:"test_user"}
      User.find_by_name("test_user").name.should == "test_user"
      response.should redirect_to("/account_setups/data_fetch")
    end


    it "should go to data_fetch" do
      current_account.settings[:wizard_step] = :data_fetch
      get :show,  :id=>"admin_init"
      response.should redirect_to("/account_setups/data_fetch")
    end

    it "should go to options_setup" do
      current_account.settings[:wizard_step] = :options_setup
      get :show,  :id=>"admin_init"
      response.should redirect_to("/account_setups/options_setup")
    end

    it "should go to user_init" do
      current_account.settings[:wizard_step] = :user_init
      get :show,  :id=>"admin_init"
      response.should redirect_to("/account_setups/user_init")
    end

  end

  describe "POST data_fetch_start" do
    it "success" do
      post :data_fetch_start, :id=>1
      response.code.should eq("200")
    end
  end

  describe "GET data_fetch_check" do
    it "success" do
      get :data_fetch_check, :id=>1
      response.code.should eq("200")
    end
  end

  describe "PUT data_fetch_finish" do
    it "success" do
      put :data_fetch_finish, :id=>1
      response.code.should eq("200")
    end
  end

  AutoSettingsHelper::AutoBlocks.each do |block|
    describe "GET edit_#{block}_settings" do
      it "success" do
        get "edit_#{block}_settings".to_sym
        response.code.should eq("200")
      end
    end
    describe "GET update_#{block}_settings" do
      it "success" do
        request.env["HTTP_REFERER"] = "http://test.host/"
        get "update_#{block}_settings".to_sym, auto_settings: {}
        response.code.should eq("302")
      end
    end
  end
end
