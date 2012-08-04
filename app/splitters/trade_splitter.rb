class TradeSplitter
  attr_accessor :trade

  def initialize(trade)
    @trade = trade
  end

  def split!
    # 先获得 splitted_orders
    @splitted_orders = splitted_orders

    if @splitted_orders.size == 1
      # 无需拆单
      return false
    end

    # 复制创建新 trade
    splitted_trades = []
    @splitted_orders.each_with_index do |splitted_order, index|
      new_trade = @trade.clone
      new_trade.orders = splitted_order[:orders]
      new_trade.splitted_tid = "#{@trade.tid}-#{index+1}"

      # TODO 完善物流费用拆分逻辑
      new_trade.post_fee = splitted_order[:post_fee]
      new_trade.total_fee = splitted_order[:total_fee]

      new_trade.save
      splitted_trades << new_trade
    end

    # 删除旧 trade
    @trade.delete

    splitted_trades
  end

  def splitted_orders
    case @trade._type
    when 'TaobaoPurchaseOrder'
      TaobaoPurchaseOrderSplitter.split_orders(@trade)
    else
      [{orders: @trade.orders}]
    end
  end
end