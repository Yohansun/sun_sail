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

  after_create :send_notify, :notify_info

  def notify_info
    mobiles = ''
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

      notify_contact = mobiles
    else  
      if notify_receiver == "seller"
        emails = seller.try(:email)
      end

      if notify_receiver == "interface"
        emails = seller.try(:interface_email) 
      end

      notify_contact = emails
    end

    Notify.create(
      :account_id     => account_id,
      :trade_id       => trades.id,
      :notify_sender  => self.notify_sender,
      :notify_contact => notify_contact,
      :notify_theme   => self.notify_theme,
      :notify_type    => self.notify_type,
      :notify_content => self.notify_content,
      :notify_time    => self.created_at,
      )

    logger.info "Notify: #{account_id}|#{trades.id}|#{self.notify_type}|#{self.notify_sender}|#{notify_contact}|#{self.notify_theme}|#{self.notify_content}|#{self.created_at}"
  end

  def account_id
    trades.account_id
  end  

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
      TradeManualSmsNotifier.perform_async(account_id, mobiles, notify_content) if (mobiles.present? && notify_content.present?)     
    else  
      if notify_receiver == "seller"
        emails = seller.try(:email).try(:split, ',') 
      end  
      if notify_receiver == "interface"
        emails = seller.try(:interface_email) 
      end  
      TradeManualEmailNotifier.perform_async(emails, notify_content, notify_theme, account_id) if (emails.present? && notify_content.present?)    
    end
  end
end