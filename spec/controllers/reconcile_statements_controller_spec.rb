require 'spec_helper'

describe ReconcileStatementsController do

  before do
    @current_user = create(:user)
    sign_in(@current_user)
  end

  describe "GET #index" do

    context 'by default loading' do
      before { get :index }
      it { should respond_with 200 }
      it { should render_template :index }
    end

    describe "search by date" do

      context 'with incorrectly date' do
        before { get :index, date: (Time.now + 3.months).strftime('%Y-%m') }
        it { assigns(:rs_set).should be_empty }
      end

      context 'with correctly date' do
        before { get :index, date: 1.months.ago.strftime('%Y-%m') }
        # it { assigns(:rs_set).should_not be_empty }
      end

    end

  end

  describe "GET #show" do
    before do
      @rs = create(:reconcile_statement)
      create(:reconcile_statement_detail, reconcile_statement: @rs)
    end

    context 'render sub-table with detail data' do
      before { get :show, id: @rs.id }
      it { should respond_with 200 }
      it { assigns(:rs).should_not be_blank }
      it { assigns(:detail).should_not be_blank }
    end

  end

  describe "PUT #audit" do
    before do
      @rs = create(:reconcile_statement)
    end

    context 'toggle audit status' do
      before { put :audit, id: @rs.id }
      it { should respond_with 200 }
      it { assigns(:rs).audited.should be_true }
    end
  end

  describe "GET #exports" do

    context 'when target params is blank' do
      before { get :exports }
      it { should redirect_to(reconcile_statements_url) }
      it { flash[:error].should_not be_blank }
    end

    context 'exports the data by params' do
      before do
        3.times { create(:reconcile_statement) }
        get :exports, selected_rs: ReconcileStatement.all.map(&:id)
      end
      it { should redirect_to(reconcile_statements_url) }
      it { flash[:notice].should_not be_blank }
    end

  end  

end