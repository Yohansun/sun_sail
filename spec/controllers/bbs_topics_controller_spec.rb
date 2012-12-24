require 'spec_helper'

describe BbsTopicsController do

  before do
    @current_user = create(:user)
    3.times { create(:bbs_category) }
    sign_in(@current_user)
    @topic = create(:bbs_topic, user: @current_user)
  end

  describe "GET index" do

    it 'should success' do
      get :index
      response.should be_success
      response.should render_template(:index)
    end

    it "should assign categories/hot topics/latest topics" do
      get :index
      assigns(:categories).should_not be_empty
      assigns(:hot_topics).should be_true
      assigns(:latest_topics).should be_true
    end
  end

  describe "GET new" do

    it 'should render the new form with categories' do
      get :new
      response.should be_success
      response.should render_template(:new)
      assigns(:topic).should_not be_nil
      assigns(:categories).should_not be_empty      
    end

  end

  describe "Create new topic" do

    it 'success' do
      post :create, bbs_topic: { bbs_category_id: 1, title: 'rspec title', body: 'rspec body' }
      assigns(:topic).should_not be_nil
      response.should redirect_to(bbs_topic_url(assigns(:topic)))
    end

    it 'fail' do
      post :create, bbs_topic: { bbs_category_id: 1, title: 'rspec title'}
      response.should render_template(:new)
      assigns(:topic).should have(1).errors_on(:body)
    end

  end


  describe "GET edit" do

    it 'should render the form with categories' do
      get :edit, id: @topic.id
      response.should be_success
      response.should render_template(:edit)
      assigns(:topic).should_not be_nil
      assigns(:categories).should_not be_empty         
    end

  end

  describe "Update topic" do

    it 'success' do
      put :update, id: @topic.id, bbs_topic: { title: 'update title'}
      assigns(:topic).title.should == 'update title'
      response.should redirect_to(bbs_topic_url(assigns(:topic)))
    end

    it 'fail' do
      put :update, id: @topic.id, bbs_topic: { title: nil}
      response.should render_template(:edit)
      assigns(:topic).should have(1).errors_on(:title)      
    end

  end  

  describe "GET show" do

    it 'should success' do
      get :show, id: @topic.id
      response.should be_succes
      response.should render_template(:show)
    end

    it 'should assign special topic with attached files' do
      get :show, id: @topic.id
      assigns(:topic).should_not be_nil
      # assigns(:attachements).should_not be_true
    end

    it 'should increase the read count' do
      expect {
        get :show, id: @topic.id
      }.to change{ @topic.reload.read_count }.by(1)
    end

  end

  describe "GET download" do

    it 'should increase the download count' do
      expect {
        controller.stub!(:render)
        get :download, id: @topic.id
      }.to change{ @topic.reload.download_count }.by(1)
    end

  end  


end