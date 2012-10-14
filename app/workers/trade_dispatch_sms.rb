# -*- encoding : utf-8 -*-
class TradeDispatchSms
  include Sidekiq::Worker
  sidekiq_options :queue => :sms

  def perform(id, seller_id, notify_kind)
    content = nil
    object = Trade.find id
    trade = TradeDecorator.decorate(object)
    seller = Seller.find seller_id 
    if seller
      tid = trade.tid
      trade_from = trade.trade_source
      if TradeSetting.company == "dulux"
        area_name = trade.receiver_area_name
        mobiles = seller.mobile
      else  
        area_name = seller.interface_name
        mobiles = seller.interface_mobile
      end 
      area_full_name = trade.receiver_full_address
      trade_info = "您好，#{area_name}有#{trade_from}新订单（订单号#{tid}）"
      if notify_kind == 'new' 
        if trade.has_wrong_arguments_address?
          content = "#{trade_info}。提示：系统检测到该订单所填写的收货地址有误，请与网上订单信息核实后确定买家地址！"
        else
          content = "#{trade_info}，买家地址为#{area_full_name}，请及时发货。"
        end       
      else
        content = "#{trade_info}调整，买家地址为#{area_full_name}，请及时发货。"
      end
      sms = Sms.new(content, mobiles)
      sms.transmit
    end
  end
end