#encoding: utf-8
class TaobaoPullerBuilder
  include Sidekiq::Worker
  sidekiq_options :queue => :taobao_puller_builder, unique: true, unique_job_expiration: 120

  def perform(account_id)
    account = Account.find(account_id)
    news_trades = TaobaoTrade.where(:account_id => account_id,news: 3)
    tids = []
    news_trades.each do |trade|
      SetForecastSellerWorker.perform_async(trade.id)
      SetHasOnsiteServiceWorker.perform_async(trade.id) if account.settings.enable_module_onsite_service == 1
      SetAlipayDataWorker.perform_async(trade.id) if trade.status == "TRADE_FINISHED"
      SetTradeOperator.perform_async(trade.id)
      TradeTaobaoMemoFetcher.perform_async(trade.tid)
      TradeTaobaoPromotionFetcher.perform_async(trade.tid)
      trade.operation_logs.build(operated_at: Time.now, operation: '从淘宝抓取订单')

      if account.settings.auto_settings['auto_dispatch']
        result = account.can_auto_dispatch_right_now
        DelayAutoDispatch.perform_in((result == true ?  account.settings.auto_settings['dispatch_silent_gap'].to_i.hours : result), trade.id)
      end
      tids << trade.tid
    end
  ensure
    news_trades.where(:tid.in => tids).update_all(news: 0)
  end
end
