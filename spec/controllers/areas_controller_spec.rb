# -*- encoding : utf-8 -*-

require 'spec_helper'

describe AreasController do

  login_admin
  before(:each) {
    create(:area)
  }


  describe "GET #index" do
    it "should success" do
      get :index
      response.code.should eq("200")
    end
  end

  describe "POST #create" do
    it "should success" do
      post :create, {area:{name:"北京"}}
      response.code.should redirect_to(areas_url)
    end
  end


  describe "GET #export" do
    it "should success" do
      #TODO: no routes for this action
      #get :export
      #response.code.should eq("200")
    end
  end

  describe "PUT #update" do
    it "should success" do
      put :update, {id: 110000, area:{}}
      response.code.should eq("302")
    end
  end


  describe "GET #autocomplete" do
    it "should success" do
      #TODO: no routes for this action
      # post :create, {q:"北京"}
      # response.code.should eq("200")
    end
  end


  describe "GET #area_search" do
    it "should success" do
      #TODO: no routes for this action
      # post :create, {area:{}}
      # response.code.should eq("200")
    end
  end

end
