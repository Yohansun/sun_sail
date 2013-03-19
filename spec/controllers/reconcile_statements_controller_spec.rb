require 'spec_helper'

describe ReconcileStatementsController do

  before do
    @current_account = create(:account)
    @current_user = create(:user, account_ids: [@current_account.id])
    @current_user.add_role :admin
    sign_in(@current_user)
    controller.stub(:check_module).and_return(true)
  end

  describe "GET #index" do
    # before do
    #   @rs = create(:reconcile_statement, account_id: @current_account.id)
    # end
    context 'by default loading' do
      before {
        create(:trade_source, account_id: @current_account.id)
        create(:reconcile_statement, audit_time: Time.now, account_id: @current_account.id)
        get :index
      }
      it { should respond_with 200 }
      it { should render_template :index }
      it { assigns(:trade_sources).should_not be_empty }
      it { assigns(:rs_set).should_not be_empty }
    end

    describe "search by date" do

      context 'with incorrectly date' do
        before { get :index, date: (Time.now + 3.months).strftime('%Y-%m') }
        it { assigns(:rs_set).should be_empty }
        it { flash[:notice].should_not be_blank }
      end

      context 'with correctly date' do
        before { get :index, date: (Time.now.to_date).strftime('%Y%m') }
        it { assigns(:rs_set).should be_empty }
      end
    end

  end

  describe "GET #show" do
    before do
      @rs = create(:reconcile_statement, account_id: @current_account.id)
      create(:reconcile_statement_detail, reconcile_statement: @rs)
    end

    context 'render sub-table with detail data' do
      before { get :show, id: @rs.id, format: :js }
      it { should respond_with 200 }
      it { assigns(:rs).should_not be_blank }
      it { assigns(:detail).should_not be_blank }
    end

  end

  describe "PUT #audit" do
    before do
      @rs = create(:reconcile_statement, audit_time: Time.now, account_id: @current_account.id)
    end

    context 'success' do
      before { put :audit, id: @rs.id }
      it { should respond_with 200 }
      it { assigns(:rs).audited.should be_true }
    end

    context 'fail' do
      before {
        ReconcileStatement.any_instance.stub(:update_attribute).and_return(false)
        put :audit, id: @rs.id
      }
      it { should respond_with 304 }
      it { assigns(:rs).audited.should be_false }
    end
  end

  describe "POST #audits" do
    before do
      @rs = create(:reconcile_statement, audit_time: Time.now, account_id: @current_account.id)
    end

    context 'audits the rs_ids by params' do
      before { post :audits, rs_ids: @rs.id }
      it { should redirect_to(reconcile_statements_url) }
    end

    context 'audits the rs_ids by params is null' do
      before { post :audits, rs_ids: '' }
      it { should redirect_to(reconcile_statements_url) }
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
        rs = create(:reconcile_statement, audit_time: Time.now, account_id: @current_account.id)
        create(:reconcile_statement_detail, reconcile_statement: rs)
        get :exports, format: :xls, selected_rs: "1"
      end
      it { assigns(:rs_data).should_not be_present }
      it { should redirect_to(reconcile_statements_url) }
      it { flash[:notice].should_not be_blank }
    end

  end

end