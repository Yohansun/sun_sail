# encoding : utf-8 -*-
class TaobaoTradeSplitter
	def self.splitable_maps
    # 1720 => 立邦仓库经销商
    {
      "1720" => [
        'A1P14L20048C0W01',
        'I1P18L50060C4V03',
        'I1P18L50061C4V04',
        'I1P18L40062C4V03',
        'I1P18L40063C4V04',
        'I1P04L10028C0V01',
        'I1P04L10026C0V01',
        'I1P04L10027C0V01',
        'I1P04L10056C0V00',
        'I1P04L10058C0V01',
        'I1P01L40015C4V03',
        'I1P01L40052C4V04',
        'P1P16L60064C0V00'
      ]
    }
  end

  def self.split_orders(trade)
    # 如果存在特殊商品, 将特殊商品拆分给仓库经销商
    all_orders = trade.orders
    cangku_outer_iids = self.splitable_maps['1720']
    cangku_orders = all_orders.select {|order| cangku_outer_iids.include? order.outer_iid }
    other_orders = all_orders - cangku_orders

    # 快递费拆分给普通经销商（非仓库经销商）
    splitted_orders = [
      {
        orders: cangku_orders,
        default_seller: 1720,
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