# encoding: utf-8
require 'spec_helper'

describe CategoryPropertiesController do

  login_admin

  let(:category_property) { create(:category_property, account_id: current_account.id) }
  before(:each) {
    category_property
  }


  def valid_attributes
    {  }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # CustomersController. Be sure to keep this updated too.
  def valid_session
    {}
  end


  describe "GET #index" do
    it "should success" do
      get :index
      response.code.should eq("200")
    end
  end

  describe "GET #new" do
    it "should success" do
      get :new
      response.code.should eq("200")
    end
  end

  describe "POST #create" do
    it "shoud success" do
      post :create, {category_property:{name:"油烟机",value_type:2}}
    end
  end

  describe "GET #edit" do
    it "should success" do
      get :edit, id:category_property.id
      response.code.should eq("200")
    end
  end

  describe "PUT #update" do
    it "shoud success" do
      put :update, {id:category_property.id,category_property:{name:"油烟机", value_type:2}}
      response.code.should eq("302")
    end
  end


end
