# -*- encoding : utf-8 -*-
class TradeDispatchSms
  include Sidekiq::Worker

  def perform(id, notify_kind)
    content = nil
    object = Trade.find id
    trade = TradeDecorator.decorate(object)
    tid = trade.tid
    trade_from = trade.trade_source
    area_name = [trade.receiver_state, trade.receiver_city, trade.receiver_district, trade.receiver_address].join("-")
    trade_info = "您好，#{trade.seller.interface_name}有#{trade_from}新订单（订单号#{tid}）"
    if notify_kind == 'new'
      if trade.seller
        if trade.receiver_state.blank? || trade.receiver_city.blank? || trade.receiver_district.blank?
          content = "#{trade_info}。提示：系统检测到该订单所填写的收货地址有误，请与网上订单信息核实后确定买家地址！"
        else
          content = "#{trade_info}，买家地址为#{area_name}，请及时通知经销商发货。"
        end
      end
    else
      content = "#{trade_info}调整，买家地址为#{area_name}，请及时通知经销商发货。"
    end
    sms = Sms.new(content, trade.seller.interface_mobile)
    sms.transmit
  end
end