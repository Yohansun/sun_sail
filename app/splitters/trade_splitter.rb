class TradeSplitter
  attr_accessor :trade

  def initialize(trade)
    @trade = trade
  end

  def split!
    splitted_orders_container = []
 
    splitted_orders_container = splitted_orders

    return false if splitted_orders_container.size == 1

    new_trade_ids = []

    # 复制创建新 trade
    splitted_trades = []
    splitted_orders_container.each_with_index do |splitted_order, index|
      new_trade = trade.clone
      new_trade.orders = splitted_order[:orders]
      new_trade.splitted_tid = "#{trade.tid}-#{index+1}"

      # TODO 完善物流费用拆分逻辑
      new_trade.post_fee = splitted_order[:post_fee]

      if splitted_order[:total_fee].present?
        new_trade.total_fee = splitted_order[:total_fee]
      end

      if splitted_order[:payment].present?
        new_trade.payment = splitted_order[:payment]
      end

      if splitted_order[:promotion_fee].present?
        new_trade.promotion_fee = splitted_order[:promotion_fee]
      end

      new_trade.splitted = true
      new_trade.has_color_info = new_trade.orders.any?{|order| order.color_num.present?}

      new_trade.save
      new_trade_ids << new_trade.id
    end

    # 删除旧 trade
    trade.delete

    new_trade_ids
  end

  def splitted_orders
    case @trade._type
    when 'TaobaoPurchaseOrder'
      TaobaoPurchaseOrderSplitter.split_orders(@trade)
    when 'TaobaoTrade'
      TaobaoTradeSplitter.split_orders(@trade)
    else
      [{orders: @trade.orders}]
    end
  end
end
