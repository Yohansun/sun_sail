# encoding : utf-8 -*-
class AlipayRevenuePuller
  class << self
    # Every 1 Day
    def create(start_time = nil, end_time = nil, trade_source_id)
      trade_source = TradeSource.find(trade_source_id)
      account_id = trade_source.account_id
      account = Account.find(account_id)
      page_no = 1

      if start_time.blank?
        if TradeRecord.where(trade_source_id: trade_source_id).count > 1
          latest_created_order = TradeRecord.only(:created, :trade_source_id).where(trade_source_id: trade_source_id).order_by(:created.desc).limit(1).first
          start_time = latest_created_order.created - 1.hour
        else
          start_time = Time.now - 1.month
        end
      end

      # 设置一个最早边界值，边界值之外的订单不能抓取。比如客户7月份之前下的订单不能出现在我们的系统。
      # sample: 2013-07-25 17:22:15 +0800
      # system timezone matters.
      created_boundary = account.settings.trade_record_created_boundary.to_time(:local) rescue nil
      if created_boundary.respond_to?(:to_time)
        if created_boundary > start_time
          start_time = created_boundary
        end
      end

      if end_time.blank?
        end_time = Time.now
      end

      begin
        response = TaobaoQuery.oauth_https_get({method: 'alipay.user.trade.search',
                    start_time: start_time.strftime("%Y-%m-%d %H:%M:%S"),
                    end_time: end_time.strftime("%Y-%m-%d %H:%M:%S"),
                    page_no: 1,
                    page_size: 50}, trade_source_id)

      unless response['alipay_user_trade_search_response']
        Notifier.puller_errors(response, account_id).deliver
        break
      end

      break unless response['alipay_user_trade_search_response']
      total_results = response['alipay_user_trade_search_response']['total_results']
      total_results = total_results.to_i
      total_pages = response['alipay_user_trade_search_response']['total_pages']
      next if total_results < 1

      trade_records = response['alipay_user_trade_search_response']['trade_records']['trade_record']
      trade_records.each do |trade_record|
        record = TradeRecord.new
        record.trade_source_id = trade_source_id
        record.account_id = account_id
        record.alipay_order_no = trade_record['alipay_order_no']
        record.merchant_order_no = trade_record['merchant_order_no']
        record.order_type = trade_record['order_type']
        record.order_status = trade_record['order_status']
        record.owner_user_id = trade_record['owner_user_id']
        record.owner_logon_id = trade_record['owner_logon_id']
        record.owner_name = trade_record['owner_name']
        record.opposite_user_id = trade_record['opposite_user_id']
        record.opposite_name = trade_record['opposite_name']
        record.order_title = trade_record['order_title']
        record.opposite_logon_id = trade_record['opposite_logon_id']
        record.total_amount = trade_record['total_amount']
        record.service_charge = trade_record['service_charge']
        record.order_from = trade_record['order_from']
        record.create_time = trade_record['create_time']
        record.in_out_type = trade_record['in_out_type']
        record.save
      end
      page_no += 1
      end until(page_no > total_pages || total_pages == 0)
    end
  end    
end   