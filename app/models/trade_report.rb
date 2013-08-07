# -*- encoding : utf-8 -*-
class TradeReport
  include ActionView::Helpers::NumberHelper
  include BaseHelper
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :user
  field :account_id,     type: Integer
  field :conditions, type: Hash
  field :export_name, type: String
  field :batch_export_ids, type: String
  field :user_id, type: Integer
  field :performed_at, type:DateTime
  field :request_at, type:DateTime

  def fetch_account
    Account.find_by_id(account_id)
  end

  def fetch_user
    User.find_by_id(user_id)
  end

  def export_report
    if self.conditions
      if self.conditions['search']['_type'] == "JingdongTrade"
        JingdongTradeReporter.perform_async(id)
      else
        TaobaoTradeReporter.perform_async(id)
      end
    end
  end

  def username
    fetch_user.try(:name)
  end

  def status
    if performed_at && File.exist?(url) && !File.zero?(url)
      "可用"
    else
      "不可用"
    end
  end

  def trades_conditions
    recursive_symbolize_keys! conditions
  end  

  def keys
    trades_conditions.keys
  end

  def deep_searched?
    (keys - [:trade_type]).present?
  end

  def only_trade_type_filtered?
    (keys - [:trade_type]).blank?
  end
  
  def adjust
    if only_trade_type_filtered?
      st = (Time.now - 1.month).strftime("%Y-%m-%d %H:%M")
      et = Time.now.strftime("%Y-%m-%d %H:%M")
      self.conditions['search'] = {}
      self.conditions['search']['created'] = "#{st};#{et}"
      self.save
    end    
  end

  def trades
    Trade.filter(fetch_account, fetch_user, trades_conditions)
  end  

  def url
    "#{Rails.root}/data/#{id}.xls"
  end

  def size
    if performed_at && File.exist?(url) && !File.zero?(url)
      number_to_human_size(File.size(url))
    else
      "未知"
    end
  end

  def ext_name
    if performed_at && File.exist?(url) && !File.zero?(url)
      File.extname url
    else
      "未知"
    end
  end

  def performed_time
    if performed_at && File.exist?(url) && !File.zero?(url)
      performed_at.to_s(:db)
    else
      "还未生成"
    end
  end

end
