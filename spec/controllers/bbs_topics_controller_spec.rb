require 'spec_helper'

describe BbsTopicsController do

  before do
    @current_account = create(:account)
    @current_user = create(:user, account_ids: [@current_account.id])

    3.times { create(:bbs_category, account_id: @current_account.id) }
    sign_in(@current_user)
    @topic = create(:bbs_topic, user: @current_user, account_id: @current_account.id)
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
      post :create,  uploads: [] , bbs_topic: { bbs_category_id: 1, title: 'rspec title', body: 'rspec body' }
      assigns(:topic).should_not be_nil
      response.should redirect_to(bbs_category_url(:id => 1))
    end

    it 'fail' do
      post :create,  uploads: [] ,bbs_topic: { bbs_category_id: 1, title: 'rspec title'}
      BbsTopic.any_instance.stub(:save).and_return(false)
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
      response.should redirect_to(bbs_topics_url)
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
    end

    it 'should increase the read count' do
      expect {
        get :show, id: @topic.id
      }.to change{ @topic.reload.read_count }.by(1)
    end

  end

  describe "GET download" do

    context 'success' do
      before {
        controller.stub!(:render)
        controller.stub!(:send_file)
        UploadFile.any_instance.stub_chain(:file, :path).and_return("filepath")
        get :download, id: @topic.id, fid: create(:upload_file).id
      }

      it { @topic.reload.download_count.should == 1 }
    end

     context 'fail without upload file' do
      before {
        UploadFile.should_receive(:find).with("1").and_return(false)
        get :download, id: @topic.id, fid: 1
      }

      it { should respond_with 404 }
    end
  end

   # describe "GET destroy" do

   #  it 'if params[:category]="hot" should be success' do
   #    delete :destroy, id: @topic.id, category: "hot"
   #    assigns(:topic).should_not be_nil
   #    response.should redirect_to(list_bbs_topics_url(category: "hot"))
   #  end

   #  it 'fail' do
   #    delete :destroy, id: @topic.id, category: "hot"
   #    assigns(:topic).should_not be_nil
   #    response.should redirect_to(list_bbs_topics_url(category: "hot"))

   #  end

  # end


end