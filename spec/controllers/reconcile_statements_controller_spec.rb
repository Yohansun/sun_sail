require 'spec_helper'

describe ReconcileStatementsController do

  before do
    @current_user = create(:user)
    sign_in(@current_user)
  end

  describe "GET #index" do

    it 'should render default page' do
      get :index
      response.should be_success
      response.should render_template(:index)
    end

    describe "search by date" do
      
      it 'should render empty results with incorrectly date' do
        get :index, date: (Time.now + 3.months).strftime('%Y-%m')
        assigns(:rs_set).should be_empty
      end

      it 'should render reconcile statement list with correctly date' do
        get :index, date: 1.months.ago.strftime('%Y-%m')
        # assigns(:rs_set).should_not be_empty
        # you can uncomment above code and change that as you want
      end
    end

  end

  describe "GET #show" do
    before do
      @rs = create(:reconcile_statement)
      create(:reconcile_statement_detail, reconcile_statement: @rs)
    end

    it 'should render sub-table with detail data' do
      get :show, id: @rs.id
      response.should be_success
      assigns(:rs).should_not be_blank
      assigns(:detail).should_not be_blank
    end

  end

  describe "PUT #audit" do
    before do
      @rs = create(:reconcile_statement)
    end
    it 'should toggle audit status' do
      @rs.audited.should be_false
      put :audit, id: @rs.id
      response.should be_success
      assigns(:rs).audited.should be_true
    end
  end

  describe "GET #exports" do

    it 'should give me a warning when target params is blank' do
      get :exports
      response.should redirect_to(reconcile_statements_url)
      flash[:error].should_not be_blank
    end

    it 'should give me a success msg after exports the data by params' do
      3.times { create(:reconcile_statement) }
      get :exports, selected_rs: ReconcileStatement.all.map(&:id)
      response.should redirect_to(reconcile_statements_url)
      flash[:notice].should_not be_blank
    end

  end  

end
