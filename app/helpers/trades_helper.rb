# -*- encoding:utf-8 -*-
module TradesHelper
  def get_package(order)
    tmp = []
    if order.sku_bindings.present?
      order.sku_bindings.each do |binding|
        sku = Sku.find_by_id(binding.sku_id)
        next unless sku
        product = sku.product
        next unless product
        number = binding.number
        tmp << {
          name: product.name,
          number: number,
          sku_id: binding.sku_id,
          sku_title: sku.title
        }
      end
    elsif order.local_skus.present?
      order.local_skus.each do |sku|
        next unless sku
        product = sku.product
        next unless product
        tmp << {
          name: product.name,
          number: 1,
          sku_id: sku.id,
          sku_title: sku.title
        }
      end
    end
    tmp
  end

  def can_change_logistic(trade)
    trade.status == 'WAIT_SELLER_SEND_GOODS'
  end

  def summary_analysis
    start_at = Time.now.beginning_of_day
    end_at = Time.now.end_of_day
    today_summary = calculate_infos(start_at, end_at)
    start_at = Time.now.beginning_of_month
    end_at = Time.now.end_of_month
    month_summary = calculate_infos(start_at, end_at)
    [today_summary,month_summary]
  end

  def calculate_infos(start_at, end_at)

    trades = Trade.where(account_id: current_account.id).between(created: start_at..end_at)

    #订单总数
    trades_count = trades.count

    #下单订单总额
    trades_money = trades.sum(:payment) || 0

    #未付款订单总数
    unpaid_trades_count = trades.where(status: "WAIT_BUYER_PAY").count

    #已付款订单数
    paid_trades_count = trades.where(:pay_time.ne => nil).count


    #付款订单总额
    unpaid_trades_money = trades.where(pay_time: nil).sum(:payment) || 0
    paid_trades_money = trades_money - unpaid_trades_money

    #退货订单总额
    refund_trades = trades.where(:taobao_orders.elem_match => {:refund_status.ne => "NO_REFUND"})
    finished_refund_trades = trades.where(:ref_batches.elem_match => {ref_type: "return_ref"})
    taobao_refund_money = 0
    ref_return_money = 0
    refund_trades.each do |trade|
      trade.taobao_orders.each do |order|
        if order.refund_status != "NO_REFUND"
          taobao_refund_money += order.payment
        end
      end
    end
    finished_refund_trades.each do |trade|
      trade.ref_batches.where(ref_type: "return_ref").each do |ref|
        ref_return_money += ref.ref_payment
      end
    end
    refund_trades_money = taobao_refund_money + ref_return_money

    #完成订单总额
    finished_trades_money = trades.where(:end_time.ne => nil).sum(:payment) || 0

    #取消订单总额
    canceled_trades_money = trades.where(:status.in => ["TRADE_CLOSED","TRADE_CLOSED_BY_TAOBAO", "ALL_CLOSED"]).sum(:payment) || 0

    #计算部分退款订单数，全额退款订单数
    refund_trades = trades.where(:taobao_orders.elem_match => {refund_status: "NO_REFUND"})
    partially_refund_count = 0
    total_refund_count = 0
    refund_trades.each do |trade|
      is_refund = trade.taobao_orders.inject(false){|status,el| status || (el.refund_status == "NO_REFUND" ? false : true) }
      if is_refund
        if trade.taobao_orders.map(&:refund_status).include?("NO_REFUND")
          partially_refund_count += 1
        else
          total_refund_count += 1
        end
      end
    end
    #部分退款订单包括交易完成的多退少补订单，部分退款的交易未完成订单
    partially_refund_count += finished_refund_trades.count

    [trades_count,
     unpaid_trades_count,
     paid_trades_count,
     partially_refund_count,
     total_refund_count,
     finished_trades_money.round(2),
     trades_money.round(2),
     paid_trades_money.round(2),
     refund_trades_money.round(2),
     canceled_trades_money.round(2)]

  end

end