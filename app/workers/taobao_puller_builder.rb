#encoding: utf-8
class TaobaoPullerBuilder
  include Sidekiq::Worker
  sidekiq_options :queue => :taobao_puller_builder, unique: true, unique_job_expiration: 86400

  def perform(trade_source_id)
    trade_source = TradeSource.find(trade_source_id)
    account = Account.find(trade_source.account_id)
    news_trades = TaobaoTrade.where(:trade_source_id => trade_source_id,account_id: account.id,news: 3)

    ids = news_trades.distinct(:id)
    fails = []

    news_trades.where(status: 'TRADE_FINISHED').distinct(:id).each do |id|
      begin
        SetAlipayDataWorker.perform_async(id)
      rescue Exception => e
        fails << id
        raise(e)
      end
    end

    ids.each do |id|
      begin
        SetForecastSellerWorker.perform_async(id)
        SetHasOnsiteServiceWorker.perform_async(id) if account.settings.enable_module_onsite_service == 1
        SetTradeOperator.perform_async(id)
        TradeTaobaoMemoFetcher.perform_async(nil,id: id)
        TradeTaobaoPromotionFetcher.perform_async(nil,id: id)
        if account.settings.auto_settings['auto_dispatch']
          result = account.can_auto_dispatch_right_now
          DelayAutoDispatch.perform_in((result == true ?  account.settings.auto_settings['dispatch_silent_gap'].to_i.hours : result), id)
        end
      rescue Exception => e
        fails << id
        raise(e)
      end
    end
  ensure
    news_trades.where(:id.nin => fails).update_all(news: 0)
  end
end
