require 'spec_helper'

describe BbsTopicsController do

  before do
    @current_user = create(:user)
    3.times { create(:bbs_category) }
    sign_in(@current_user)
  end

  describe "GET index" do

    it 'should success' do
      get :index
      response.should be_success
    end

    it "should assign categories/hot topics/latest topics" do
      get :index
      assigns(:categories).should_not be_empty
      assigns(:hot_topics).should be_true
      assigns(:latest_topics).should be_true
    end
  end 

end
