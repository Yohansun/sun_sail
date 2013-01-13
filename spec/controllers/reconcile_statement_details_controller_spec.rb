require 'spec_helper'

describe ReconcileStatementDetailsController do
	before do
      @current_user = create(:user)
      @current_user.add_role :admin
      sign_in(@current_user)
    end

    describe "GET #show" do
    before do
      @rs = create(:reconcile_statement)
      @rsd = create(:reconcile_statement_detail, reconcile_statement: @rs)
      ReconcileStatementDetail.any_instance.stub(:select_trades).and_return("success")
      @money_type = "type"
    end

    context 'render sub-table with detail data' do
      before { get :show, reconcile_statement_id: @rsd.reconcile_statement_id, id: @rsd.id, money_type: "type" }
      it { should respond_with 200 }
      it { assigns(:trade_details).should_not be_blank }
      it { assigns(:money_type).should_not be_blank }
    end
  end

end
