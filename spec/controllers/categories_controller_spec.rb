# -*- encoding : utf-8 -*-
require 'spec_helper'

describe CategoriesController do

  login_admin

  let(:category) { create(:category, name:"油烟机") }
  before(:each) { 
    current_account.categories << category 
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
      post :create, {category:{name:"油烟机"}}
    end
  end
  describe "GET #show" do

    it "should success" do
      # TODO: 
#      get :show,  id:category.id
#      response.code.should eq("200")
    end
  end

  describe "GET #edit" do
    it "should success" do
      get :edit, id:category.id
      response.code.should eq("200")
    end
  end

  describe "PUT #update" do
    it "shoud success" do
      put :update, {id:category.id, category:{name:"油烟机"}}
      response.code.should eq("302")
    end
  end

  describe "DELETE #delete" do
    it "should success" do
      delete :destroy,  id:category.id
      Category.find_by_id(category.id).should be_nil
      response.should redirect_to categories_path
    end
  end

  describe "GET #deletes" do
    it "should success and delete all records" do
      get :deletes, {ids:category.id}
      Category.find_by_id(category.id).should be_nil
      response.should redirect_to categories_path(:parent_id=>category.parent_id)

    end
  end


  describe "GET #category_templates" do
    it "should succes" do
      get :category_templates
      response.code.should eq("200")
    end
  end


  describe "GET #product_templates" do
    it "should success" do
      get :product_templates, category_id:category.id
      response.code.should eq("200")
    end
  end

  describe "GET #sku_templates" do
    let(:product){create(:product)}
    it "should success" do
      get :sku_templates, product_id:category.id
      response.code.should eq("200")
    end
  end


end
