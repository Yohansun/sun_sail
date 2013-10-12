#encoding: utf-8
module MagicOrder
  class RefundProduct < Grape::API
    resource :refund_products do
      desc "confirm refund product"
      params do
        requires :tid, type: String, desc: "订单号"
      end

      post "refund_product_verify" do
        @refund_product = ::RefundProduct.with_account(current_account.account_id).find_by_tid params[:tid]
        not_found!("tid: #{params[:tid]}") if @refund_product.blank?
        if @refund_product.can_confirm?
          @refund_product.send(:confirm)
        else
          @refund_product.errors.add(:base,"退货单当前状态: #{@refund_product.status_name} 不能确认")
        end
        present @refund_product, with: Entities::RefundProduct
      end
    end
  end
end