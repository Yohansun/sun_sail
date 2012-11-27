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
        trade_info = "您好，#{area_name}有#{trade_from}新订单（订单号#{tid}）"
      else
        area_name = seller.interface_name
        mobiles = seller.interface_mobile
        mobiles += ",13761949153" if object._type == "TaobaoPurchaseOrder"
        trade_info = "您好，#{seller.interface_name}有#{trade_from}新订单（订单号#{tid}）"
      end

      area_full_name = trade.receiver_full_address

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
      response = sms.transmit.parsed_response
      sms_operation = "发送短信"
      if response == '0'
        if mobiles.present?
          sms_operation += "到#{mobiles}"
        else
          sms_operation  += "失败，经销商没有绑定手机号"
        end
      else
        sms_operation += "失败，请检查短信平台是否正常连接"
      end

      trade.operation_logs.create(operated_at: Time.now, operation: sms_operation)
    end
  end
end
