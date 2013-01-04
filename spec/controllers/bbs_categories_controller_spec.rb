require 'spec_helper'

describe BbsCategoriesController do
	before do
    @current_user = create(:user)
    # 3.times { create(:bbs_category) }
    sign_in(@current_user)
    @category = create(:bbs_category)
  end

 	describe "GET show" do

    it 'should success' do
      get :show, id: @category.id
      response.should be_succes
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
