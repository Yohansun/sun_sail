# -*- encoding : utf-8 -*-
class ManualSmsOrEmail
  include Mongoid::Document
  include Mongoid::Timestamps

  field :notify_receiver,         type: String
  field :notify_sender,       type: String
  field :notify_theme,       type: String
  field :notify_type,     type: String
  field :notify_content,    type: String

  embedded_in :trades

  after_create :send_notify

  def send_notify
    seller = Seller.find_by_id self.trades.seller_id
    if notify_type == "sms"    
      if notify_receiver == "buyer"
        mobiles = TradeDecorator.decorate(self.trades).receiver_mobile
      end  
      if notify_receiver == "seller"  
        mobiles = seller.try(:mobile)
      end  
      if notify_receiver == "interface" 
        mobiles = seller.try(:interface_mobile)
      end  
      TradeManualSmsNotifier.perform_async(mobiles, notify_content) if (mobiles.present? && notify_content.present?)     
    else  
      if notify_receiver == "seller"
        emails = seller.try(:email).try(:split, ',') 
      end  
      if notify_receiver == "interface"
        emails = seller.try(:interface_email) 
      end  
      TradeManualEmailNotifier.perform_async(emails, notify_content, notify_theme_text) if (emails.present? && notify_content.present?)    
    end                        
  end

  def notify_theme_text
    "订单分流" if notify_theme == "dispatch"
    "修改客服备注" if notify_theme == "update_cs_memo" 
  end

end