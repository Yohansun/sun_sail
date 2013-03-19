require 'spec_helper'

describe BbsCategoriesController do
	before do
    @current_account = create(:account)
    @current_user = create(:user, account_ids: [@current_account.id])
    # 3.times { create(:bbs_category) }
    sign_in(@current_user)
    @category = create(:bbs_category, account_id: @current_account.id)
  end

 	describe "GET show" do

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