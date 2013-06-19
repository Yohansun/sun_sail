require 'spec_helper'

describe BbsCategoriesController do
  login_admin

 	describe "GET show" do
  	before do
      @category = FactoryGirl.create(:bbs_category, account_id: current_account.id)
    end

    it 'should success' do
      get :show, id: @category.id
      response.should be_success
      response.should render_template(:show)
    end

    it 'should assign category' do
      get :show, id: @category.id
      assigns(:categories).should_not be_empty
      assigns(:topics).should be_true
      # assigns(:attachements).should_not be_true
    end

  end
end