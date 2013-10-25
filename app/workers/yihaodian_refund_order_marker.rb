# -*- encoding : utf-8 -*-
class YihaodianRefundOrderMarker
  include Sidekiq::Worker
  sidekiq_options :queue => :yihaodian_refund_order_marker, unique: true, unique_job_expiration: 60

  def perform(account_id)
    start_time = 1.week.ago.strftime("%Y-%m-%d %H:%M:%S")
    end_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    query_conditions = Account.find(account_id).yihaodian_query_conditions
    response = YihaodianQuery.post({method: 'yhd.refund.get',
                                    startTime: start_time,
                                    endTime: end_time}, query_conditions).underscore_key

    if response["response"]['error_count'] > 0
      errors = response["response"]['err_info_list']['err_detail_info'].collect{|e| e['error_des']}.uniq
      if errors.include?("根据指定的参数查不到相应的退货信息!") && errors.count == 1
        return
      else
        Notifier.puller_errors(response, account_id).deliver
        return
      end
    else
      refund_info = response["response"]['refund_list']['refund']
      refund_info.each do |info|
        refund_trade = YihaodianTrade.where(order_id: info['order_id']).first
        if refund_trade
          refund_trade.apply_date = info['apply_date']
          refund_trade.refund_amount = info['refund_amount']
          refund_trade.refund_code = info['refund_code']
          refund_trade.refund_status = info['refund_status']
          info['refund_particular_list']['refund_particular'].each do |sub_info|
            refund_order = refund_trade.yihaodian_orders.where(order_item_id: sub_info['order_item_id']).first
            if refund_order
              refund_order.product_refund_num = sub_info['product_refund_num']
              refund_order.refund_status = sub_info['refund_status']
              refund_order.save!
            else
              Notifier.puller_errors("退款订单#{info['order_id']}子订单不存在", account_id).deliver
              return
            end
          end
          refund_trade.save!
        else
          Notifier.puller_errors("退款订单#{info['order_id']}不存在", account_id).deliver
          return
        end
      end
    end

  end
end