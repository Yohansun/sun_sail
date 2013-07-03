#encoding: utf-8
require 'spec_helper'

describe "Users" do
  login_admin
  let(:user_1) { create(:user,:account_ids => [current_account.id]) }
  let(:user_2) { create(:user,:account_ids => [current_account.id]) }
  before(:each) do
    @user = current_user
  end
  
  describe "GET /users#autologin" do
    it "works! (now write some real specs)" do
      get autologin_path
      response.status.should be(302)
    end 
  end

  describe "GET /users#index" do
    it "works! (now write some real specs)" do
      get users_path
      expect(response).to render_template(:index)
      response.status.should be(200)
    end
  end
  
  describe "POST /users#search" do
    it "works! (now write some real specs)" do
      post search_users_path
      expect(response).to redirect_to(users_path)
    end
  end
  
  describe "GET /users#roles" do
    it "works! (now write some real specs)" do
      get roles_users_path
      expect(response).to render_template(:roles)
      response.status.should be(200)
    end
  end
  
  describe "GET /users#show" do
    it "works! (now write some real specs)" do
      get user_path(@user)
      expect(response).to render_template(:show)
      response.status.should be(200)
    end
  end
  
  describe "PUT /users#new" do
    #暂时没有编辑的功能
    it "works! (now write some real specs)" do
      get new_user_path
      expect(response).to render_template(:new)
      response.status.should be(200)
    end
  end
  
  describe "POST /users#create" do
    it "should render template :new" do
      post users_path,user: {email: "zhoubin@networking.io"}
      expect(response).to render_template(:new)
    end
    it "should redirect_to index" do
      post users_path,user: {email: "zhoubin@networking.io", password: "123456", username: "admin", phone: "15848792001"}
      expect(response).to redirect_to(users_path)
    end
  end
  
  describe "PUT /users#update" do
    it "should render template :edit" do
      put user_path(@user), user: { username: "" }
      expect(response).to render_template(:edit)
    end
    
    it "should redirect_to :index" do
      @user.stub_chain(:update_attributes => true)
      put user_path(@user), user: {active: true}
      expect(response).to redirect_to(users_path)
    end
  end
  
  describe "GET /users#edit" do
    it "works! (now write some real specs)" do
      get edit_user_path(1)
      expect(response).to render_template(:edit)
      response.status.should be(200)
    end
  end
  
  describe "GET /users#edit_with_role" do
    it "works! (now write some real specs)" do
      get edit_with_role_user_path(@user)
      response.status.should be(200)
    end
  end
  
  describe "GET /users#switch_account" do
    it "works! (now write some real specs)" do
      get switch_account_path(@user.id)
      expect(response).to redirect_to("/")
    end
  end
  
  describe "POST /users#batch_update" do

    it "should receive error flash (不能操作自己)" do
      post batch_update_users_path,user_ids: [current_user.id]
      expect(response).to redirect_to(users_path)
      follow_redirect!
      expect(response.body).to include("不能操作自己")
    end
    
    it "should receive error flash (请正常操作)" do
      post batch_update_users_path
      expect(response).to redirect_to(users_path)
      follow_redirect!
      expect(response.body).to include("请正常操作")
    end
    
    it "should receive notice flash (锁定成功!)" do
      user_1 && user_2
      post batch_update_users_path,user_ids: [user_1.id.to_s,user_2.id.to_s], operation: "lock"
      expect(response).to redirect_to(users_path)
      follow_redirect!
      expect(response.body).to include("锁定成功!")
    end

    it "should receive notice flash (解锁成功!)" do
      user_1 && user_2
      post batch_update_users_path,user_ids: [user_1.id.to_s,user_2.id.to_s], operation: "unlock"
      expect(response).to redirect_to(users_path)
      follow_redirect!
      expect(response.body).to include("解锁成功!")
    end
  end
  
  describe "GET /users#limits" do
    it "works! (now write some real specs)" do
      get limits_users_path(@user.id)
      expect(response).to render_template(:limits)
      response.status.should eq(200)
    end
  end
  
  describe "PUT /users#create_role" do
    it "should be redirect and receive notice message(创建成功)" do
      put create_role_users_path,role: {name: 'admin-001'}
      expect(response).to redirect_to(roles_users_path)
      follow_redirect!
      expect(response.body).to include("创建成功")
    end
    
    it "should be render text" do
      put create_role_users_path
      expect(response.body).to include("<a href=\"/users/roles\">返回</a><br />名称 不能为空字符")
    end
  end
  
  describe "PUT /users#update_permissions" do
    it "should be save" do
      put update_permissions_users_path,{role_id: role.id}
      expect(response).to redirect_to(roles_users_path)
      follow_redirect!
      expect(response.body).to include("更新成功")
    end
    
    it "should not be save" do
      put update_permissions_users_path,{role_id: role.id, role: { name: "" } }
      expect(response).to render_template(:limits)
      expect(response.body).to include("名称 不能为空字符")
    end
  end
  
  describe "POST /users#destroy_role" do
    it "works! (now write some real specs)" do
      post destroy_role_users_path,role_id: role.id
      expect(response).to redirect_to(roles_users_path)
    end
  end
  
  describe "POST /users#delete" do
    it "works! (now write some real specs)" do
      user_1
      post delete_users_path, user_ids: [user_1.id]
      expect(response).to redirect_to(users_path)
    end
  end
end