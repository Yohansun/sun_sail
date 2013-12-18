#encoding: utf-8
require 'spec_helper'

describe "AccountSetups" do
  login_admin

  describe "GET /account_setups#show" do
    it "works! (now write some real specs)" do
      get account_setup_path(1)
      expect(response).to redirect_to(root_path)
      follow_redirect!
      response.status.should be(200)
    end
  end

  describe "PUT /account_setups#update" do
    it "works! (step admin_init)" do
      put account_setup_path(:admin_init), user: {email: "zhoubin@networking.io",phone: "15848792001", username: "admin", name: "ZhouBin"}
      expect(response).to redirect_to(account_setup_path(:data_fetch))
    end

    it "works! (step options_setup)" do
      put account_setup_path(:options_setup)
      expect(response).to redirect_to(account_setup_path(:user_init))
    end

    it "works! (step user_init)" do
      put account_setup_path(:user_init)
      expect(response).to redirect_to(account_setup_path(:finish))
      follow_redirect!
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /account_setups#data_fetch_start" do
    it "works! (now write some real specs)" do
      [:admin_init,:data_fetch,:options_setup,:user_init].each do |action|
        post data_fetch_start_account_setup_path(action)
        response.status.should be(200)
      end
    end
  end

  describe "GET /account_setups#data_fetch_check" do
    it "works! (now write some real specs)" do
      [:admin_init,:data_fetch,:options_setup,:user_init].each do |action|
        get data_fetch_check_account_setup_path(action)
        response.status.should be(200)
      end
    end
  end

  describe "GET /account_setups#data_fetch_finish" do
    it "works! (now write some real specs)" do
      [:admin_init,:data_fetch,:options_setup,:user_init].each do |action|
        get data_fetch_finish_account_setup_path(action)
        response.status.should be(200)
      end
    end
  end

  describe "GET /account_setups#edit_preprocess_settings" do
    it "works! (now write some real specs)" do
      get edit_preprocess_settings_account_setups_path
      response.status.should be(200)
    end
  end

  describe "GET /account_setups#edit_dispatch_settings" do
    it "works! (now write some real specs)" do
      get edit_dispatch_settings_account_setups_path
      response.status.should be(200)
    end
  end

  describe "GET /account_setups#edit_deliver_settings" do
    it "works! (now write some real specs)" do
      get edit_deliver_settings_account_setups_path
      response.status.should be(200)
    end
  end

  describe "GET /account_setups#edit_automerge_settings" do
    it "works! (now write some real specs)" do
      get edit_automerge_settings_account_setups_path
      response.status.should be(200)
    end
  end

  describe "PUT /account_setups#update_preprocess" do
    #Please don't use redirect_to :back
    it "works! (now write some real specs)" do
        put update_preprocess_settings_account_setups_path(:auto_settings => {:off => true}),{},{"HTTP_REFERER"=>'http://test.com/sessions/new'}

      response.status.should be(302)
    end
  end

  describe "PUT /account_setups#update_dispatch_settings" do
    #Please don't use redirect_to :back
    it "works! (now write some real specs)" do
        @request.env['HTTP_REFERER'] = 'http://test.com/sessions/new'
        put update_dispatch_settings_account_setups_path(:auto_settings => {:off => true}),{},{"HTTP_REFERER"=>'http://test.com/sessions/new'}
      response.status.should be(302)
    end
  end

  describe "PUT /account_setups#update_deliver_settings" do
    #Please don't use redirect_to :back
    it "works! (now write some real specs)" do
        @request.env['HTTP_REFERER'] = 'http://test.com/sessions/new'
        put update_deliver_settings_account_setups_path(:auto_settings => {:off => true}),{},{"HTTP_REFERER"=>'http://test.com/sessions/new'}
      response.status.should be(302)
    end
  end

  describe "PUT /account_setups#update_automerge_settings" do
    #Please don't use redirect_to :back
    it "works! (now write some real specs)" do
        @request.env['HTTP_REFERER'] = 'http://test.com/sessions/new'
        put update_automerge_settings_account_setups_path(:auto_settings => {:off => true}),{},{"HTTP_REFERER"=>'http://test.com/sessions/new'}

      response.status.should be(302)
    end
  end
end