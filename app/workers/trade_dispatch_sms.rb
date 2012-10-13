# -*- encoding : utf-8 -*-
class TradeDispatchSms
  include Sidekiq::Worker
  sidekiq_options :queue => :sms

  def perform(id, notify_kind)
    content = nil
    object = Trade.find id
    trade = TradeDecorator.decorate(object)
    seller = trade.seller 
    tid = trade.tid
    trade_from = trade.trade_source
    area_name = seller.interface_name
    area_full_name = trade.receiver_full_address
    trade_info = "您好，#{area_name}有#{trade_from}新订单（订单号#{tid}）"
    if notify_kind == 'new'
      if seller
        if trade.has_wrong_arguments_address?
          content = "#{trade_info}。提示：系统检测到该订单所填写的收货地址有误，请与网上订单信息核实后确定买家地址！"
        else
          content = "#{trade_info}，买家地址为#{area_full_name}，请及时通知经销商发货。"
        end
      end
    else
      content = "#{trade_info}调整，买家地址为#{area_full_name}，请及时通知经销商发货。"
    end
    sms = Sms.new(content, seller.interface_mobile)
    sms.transmit
  end
end