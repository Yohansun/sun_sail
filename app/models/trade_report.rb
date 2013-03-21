# -*- encoding : utf-8 -*-
class TradeReport
  include ActionView::Helpers::NumberHelper
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :user
  field :account_id,     type: Integer
  field :conditions, type: Hash
  field :export_name, type: String
  field :user_id, type: Integer
  field :performed_at, type:DateTime
  field :request_at, type:DateTime

  def fetch_account
    Account.find_by_id(self.account_id)
  end

  def export_report
    if self.fetch_account.key == "dulux"
      DuluxTaobaoTradeReporter.perform_async(self.id)
    elsif self.fetch_account.key == 'brands'
      BrandsTaobaoTradeReporter.perform_async(self.id)  
    elsif self.fetch_account.key == "nippon"
      if conditions.fetch("search").fetch("type_option").present? && conditions.fetch("search").fetch("type_option") == "TaobaoTrade"
        NipponTaobaoTradeReporter.perform_async(self.id)
      else
        NipponOtherTradeReporter.perform_async(self.id)
      end
    else
      #普通淘宝品牌使用立邦报表模板即可
      NipponTaobaoTradeReporter.perform_async(self.id)
    end
  end

  def username
    user = User.find_by_id self.user_id
    user.try(:name)
  end

  def status
    if self.performed_at && File.exist?(self.url) && !File.zero?(self.url)
      "可用"
    else
      "不可用"
    end
  end

  def url
    "#{Rails.root}/data/#{self.id}.xls"
  end

  def size
    if self.performed_at && File.exist?(self.url) && !File.zero?(self.url)
      number_to_human_size(File.size(self.url))
    else
      "未知"
    end
  end

  def ext_name
    if self.performed_at && File.exist?(self.url) && !File.zero?(self.url)
      File.extname self.url
    else
      "未知"
    end
  end

  def performed_time
    if self.performed_at && File.exist?(self.url) && !File.zero?(self.url)
      self.performed_at.to_s(:db)
    else
      "还未生成"
    end
  end

end
