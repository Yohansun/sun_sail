# -*- encoding : utf-8 -*-
require 'spec_helper'

describe ReconcileStatementDetailsController do
  login_admin

  before do
    controller.stub(:check_module).and_return(true)
    request.env["HTTP_REFERER"] = "http://test.host/"
  end

    describe "GET #show" do
      before do
        @rs = create(:reconcile_statement)
        @rsd = create(:reconcile_statement_detail, reconcile_statement: @rs)
        ReconcileStatementDetail.any_instance.stub(:select_trades).and_return("success")
        @money_type = "alipay_revenue"
      end

      context 'render sub-table with detail data' do
        before { get :show, reconcile_statement_id: @rsd.reconcile_statement_id, id: @rsd.id, money_type: "type" }
        it { should respond_with 200 }
        it { assigns(:trade_details).should_not be_blank }
        it { assigns(:money_type).should_not be_blank }
      end
    end

    describe "GET #export_detail" do
      before do
        @rs = create(:reconcile_statement, audit_time: Time.now, exported: {:alipay_revenue => true})
        @rsd = create(:reconcile_statement_detail, reconcile_statement: @rs)
      end

      context 'render data first' do
        before {
          @file_name = File.open("#{Rails.root}/spec/fixtures/test.xls")
          controller.should_receive(:send_file).and_return(@file_name)
          controller.stub!(:render)
          get :export_detail, reconcile_statement_id: @rsd.reconcile_statement_id, id: @rsd.id, money_type: "alipay_revenue"
        }
        it { should respond_with 200 }
      end

      context 'download file directly' do
        before {
          @rs.update_attributes(exported: nil)
          controller.stub(:send_file).and_return(true)
          get :export_detail, reconcile_statement_id: @rsd.reconcile_statement_id, id: @rsd.id, money_type: "alipay_revenue"
        }
        exported_array = []
        it { should redirect_to :back }
      end
    end
end
