#encoding: utf-8
class RefundProductTaobaoSync < ECommerce::Synchronization::Base
  set_klass "RefundProduct"
  identifier 'refund_id'

  set_variable :get_size, 100
  set_variable :page_no, 1
  set_variable :page_count, proc { |v|  total_results.zero? ? 1 : (total_results / get_size.to_f).ceil}
  set_variable :api,'taobao.refunds.receive.get'
  alias_columns buyer_nick: 'buyer_name',created: "refund_time"

  def initialize(trade_source_id)
    @trade_source = TradeSource.find(trade_source_id)
    @default_attributes = {account_id: @trade_source.account_id,ec_name: "TaobaoTrade",is_location: false}
    @refund_ids = RefundProduct.where(@default_attributes).map(&:refund_id)
    super
  end

  def response
    params = {method: api,fields: 'refund_id, tid, title,buyer_nick, seller_nick, total_fee, status, created, refund_fee', status: "WAIT_BUYER_RETURN_GOODS",page_no: page_no, page_size: get_size}
    @response = TaobaoQuery.get(params,@trade_source.id)
    handle_exception(params.merge(response: @response)) { parse_data }
  end

  def parse_data
    @response["refunds_receive_get_response"]["refunds"]["refund"].tap do |refunds|
      refunds.each_witn_index do |refund,index|
        refunds.delete(refund) && next if @refund_ids.include?(refund["refund_id"].to_i)
        #去掉与数据库重名的字段
        reject_attributes(refund)

        seller_id = taobao_trade(refund["tid"]).seller_id
        refund.merge!({
          "seller_id" => seller_id,
          "address" => refund["address"],
          "reason" => refund["reason"],
          "refund_orders_attributes" => refund_order_attributes(refund)
          })
      end
    end
  end

  def total_results
    @response["refunds_receive_get_response"]["total_results"]
  end

  def reject_attributes(refund)
    attrs = %w(status)
    refund.delete_if {|a| attrs.include?(a)}
  end

  def parsing
    super && (@page_no+=1) while page_count > page_no
  end

  def taobao_trade(tid)
    TaobaoTrade.unscoped.find_by(:tid => tid)
  end

  # refund_orders_attributes
  def refund_order_attributes(refund)
    taobao_trade = TaobaoTrade.where(tid: refund["tid"].to_s).first
    order = taobao_trade && taobao_trade.taobao_orders.find_by(oid: refund["oid"])

    handle_exception(response: refund) do
      refund_order_attributes = {}
      refund_price = refund.delete("refund_fee")
      order && order.skus.each_with_index do |sku,index|
        options = {account_id: @trade_source.account_id, sku_id: sku.id,num_iid: sku.num_iid}.reject {|k,v| v.blank?}
        stock_product = StockProduct.where(options).first
        refund_order_attributes[index.to_s] = {
          refund_price: index == 0 ? refund_price : 0,
          num:          refund["num"],
          num_iid:      stock_product.num_iid,
          title:        sku.title,
          stock_product_id: stock_product.id,
          sku_id: sku.id
        }
      end

      if refund_order_attributes.blank?
        raise "同步的淘宝退货单在出库单中没有找到对应的商品"
      end
      refund_order_attributes
    end
  end
end