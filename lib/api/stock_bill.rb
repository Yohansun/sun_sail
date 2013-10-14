#encoding: utf-8
module MagicOrder
  class StockBill < Grape::API

    resource :stock_in_bils do
      
      ### StockInBill Feedback
      desc "StockInBill Feedback"
      params do
        requires :tid, type: Integer, desc: "订单号"
      end

      post "stock_in_bill_verify" do
        @stock_in_bill = ::StockInBill.with_account(current_account.id).find_by(tid: params[:tid])
        
        # present @refund_product, with: Entities::StockInBill
      end
    end

    resource :stock_out_bills do
      ### StockOutBill Feedback
      desc "StockOutBill Feedback"
      params do
        requires :tid, type: Integer, desc: "订单号"
      end

      post "stock_out_bill_verify" do
        @refund_product = ::StockOutBill.with_account(current_account.id).find_by(tid: datas[:tid])
        # present @refund_product, with: Entities::StockOutBill
      end
    end
  end
end