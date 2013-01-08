# -*- encoding : utf-8 -*-
module ReconcileStatementDetailsHelper
  def judge_money_type_th(money_type)
    case money_type
      when 'alipay_revenue'
        info_array = ["订单实付金额", "订单总价", "积分", "优惠"]
      when 'postfee_revenue'
        info_array = ["运费收入", "订单总价", "积分", "优惠"]
      when 'trade_success_refund'
        info_array = ["订单实付金额", "订单总价", "交易成功后退款", "优惠"]
      when 'base_service_fee'
        info_array = ["订单实付金额", "基础服务费"]
      when 'store_service_award'
        info_array = ["订单实付金额", "店铺服务奖励"]
      when 'staff_award'
        info_array = ["订单实付金额", "店员奖励"]
      when 'taobao_cost'
        info_array = ["订单实付金额", "淘宝费用"]
      when 'collecting_postfee'
        seller_post_fee = nil  ##not defined, later
        info_array = ["订单实付金额", "订单总价", "代收运费"]
      when 'adjust_amount'
        info_array = ["订单实付金额", "调整金额"]
    end
    info_array
  end

	def judge_money_type_td(trade, money_type)
    info_array = []
    case money_type
      when 'alipay_revenue'
        info_array = [trade.payment, (trade.total_fee + trade.post_fee), trade.point_fee, (trade.total_fee + trade.post_fee - trade.payment)]
      when 'postfee_revenue'
        info_array = [trade.post_fee, (trade.total_fee + trade.post_fee), trade.point_fee, (trade.total_fee + trade.post_fee - trade.payment)]
      when 'trade_success_refund'
        refund_fee = calculate_refund_fee(trade)
        discount = (trade.payment - trade.post_fee)/trade.total_fee
        info_array = [trade.payment, (trade.total_fee + trade.post_fee), refund_fee, (trade.total_fee + trade.post_fee - trade.payment)]
      when 'base_service_fee'
        refund_fee = calculate_refund_fee(trade)
        base_service_point = 0.08 ##not defined, later
        info_array = [trade.payment, ((trade.payment - trade.post_fee - refund_fee)*base_service_point).round(2)]
      when 'store_service_award'
        refund_fee = calculate_refund_fee(trade)
        store_service_point = 0.04 ##not defined, later
        info_array = [trade.payment, ((trade.payment - trade.post_fee - refund_fee)*store_service_point).round(2)]
      when 'staff_award'
        refund_fee = calculate_refund_fee(trade)
        staff_award_point = 0.02 ##not defined, later
        info_array = [trade.payment, ((trade.payment - trade.post_fee - refund_fee)*staff_award_point).round(2)]
      when 'taobao_cost'
        taobao_cost_point = 0.02 ##not defined, later
        info_array = [trade.payment, (trade.payment*taobao_cost_point).round(2)]
      when 'collecting_postfee'
        seller_post_fee = 0  ##not defined, later
        info_array = [trade.payment, (trade.total_fee + trade.post_fee), seller_post_fee]
      when 'adjust_amount'
        info_array = [trade.payment, trade.modify_payment]
    end
    info_array
  end

  def judge_money_type_total(trades, money_type)
    info_array = []
    total_real_payment = trades.try(:sum, :payment) || 0
    total_post_fee = trades.try(:sum, :post_fee) || 0
    total_showed_payment = (trades.try(:sum, :total_fee) || 0) + total_post_fee
    total_point_fee = trades.try(:sum, :point_fee) || 0
    total_discount = total_showed_payment - total_real_payment
    total_refund = trades.inject(0) {|sum, trade| sum + calculate_refund_fee(trade) }
    total_income = total_real_payment - total_post_fee - total_refund
    total_modify_payment = trades.try(:sum, :modify_payment) || 0

    case money_type
      when 'alipay_revenue'
        info_array = [total_real_payment, total_showed_payment, total_point_fee, total_discount]
      when 'postfee_revenue'
        info_array = [total_post_fee, total_showed_payment, total_point_fee, total_discount]
      when 'trade_success_refund'
        info_array = [total_real_payment, total_showed_payment, total_refund, total_discount]
      when 'base_service_fee'
        base_service_point = 0.08 ##not defined, later
        info_array = [total_real_payment, total_income*base_service_point]
      when 'store_service_award'
        store_service_point = 0.04 ##not defined, later
        info_array = [total_real_payment, total_income*store_service_point]
      when 'staff_award'
        staff_award_point = 0.02 ##not defined, later
        info_array = [total_real_payment, total_income*staff_award_point]
      when 'taobao_cost'
        taobao_cost_point = 0.02 ##not defined, later
        info_array = [total_real_payment, total_real_payment*taobao_cost_point]
      when 'collecting_postfee'
        seller_post_fee = 0  ##not defined, later
        info_array = [total_real_payment, total_showed_payment, seller_post_fee]
      when 'adjust_amount'
        info_array = [total_real_payment, total_modify_payment]
    end
    info_array
  end

  def calculate_refund_fee(trade)
    discount = (trade.payment - trade.post_fee)/trade.total_fee
    refund_orders = trade.orders.where(refund_status: "SUCCESS")
    if refund_orders
      refund_fee = refund_orders.inject(0) { |sum, order| sum + order.total_fee*discount }
    else
      refund_fee = 0
    end    
  end
end