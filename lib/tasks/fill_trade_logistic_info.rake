# -*- encoding : utf-8 -*-
task :fill_trade_logistic_info   => :environment do
  trades = TaobaoTrade.where(:logistic_id.exists => true)
	trades.each do |trade|
    p [trade.logistic_name , trade.logistic_code, trade.logistic_waybill ]
    logistic = Logistic.find_by_id trade.logistic_id
    trade.logistic_name = logistic.name
    trade.logistic_code = logistic.code
    trade.logistic_waybill = trade.tid
    trade.save!
    p [trade.logistic_name , trade.logistic_code, trade.logistic_waybill ]
  end  
end
task :fill_trade_delivered_status => :environment do
  # no need to judge trade.status
  trades = TaobaoTrade.where(status: "WAIT_SELLER_SEND_GOODS")
  trades.each do |trade|
    if trade.delivered_at
      TradeTaobaoDeliver.new.perform(trade.id)
      trade.update_attributes(status: "WAIT_BUYER_CONFIRM_GOODS")
      p "deliver #{trade.tid}"
    end  
  end  
end