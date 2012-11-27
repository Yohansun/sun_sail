# -*- encoding : utf-8 -*-

class TaobaoTradeSplitter
  def self.split_orders(trade)
    default_seller_id = TradeSetting.default_seller_id   
    cangku_outer_iids = TradeSetting.special_iids
    all_orders = trade.orders
    cangku_orders = all_orders.select {|order| cangku_outer_iids.include? order.outer_iid }
    other_orders = all_orders - cangku_orders

    # 快递费拆分给普通经销商(非仓库经销商)
    splitted_orders = [
      {
        orders: cangku_orders,
        default_seller: default_seller_id,
        post_fee: 0,
        total_fee: cangku_orders.inject(0) { |sum, el| sum + el.total_fee }
      },  
      {
        orders: other_orders,
        post_fee: trade.post_fee,
        total_fee: other_orders.inject(0) { |sum, el| sum + el.total_fee }
      }
    ]

    splitted_orders.delete_if { |el| el[:orders].size == 0 }

    return splitted_orders
  end
end
