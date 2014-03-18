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
    return Account.find(self.account_id) if self.account_id_change
    @account ||= Account.find(account_id)
  end

  def fetch_user
    User.find_by_id(user_id)
  end

  def export_report(current_user = nil )
    if self.conditions
      if self.conditions['search']['_type'] == "JingdongTrade"
        JingdongTradeReporter.perform_async(id)
      elsif self.conditions['search']['_type'] == "YihaodianTrade"
        YihaodianTradeReporter.perform_async(id)
      else
        TaobaoTradeReporter.perform_async(id, current_user)
      end
    else
      ids = self.batch_export_ids.split(",")
      trade_type = Trade.where(id: ids.first).first._type
      if trade_type == "JingdongTrade"
        JingdongTradeReporter.perform_async(id)
      elsif trade_type == "YihaodianTrade"
        YihaodianTradeReporter.perform_async(id)
      else
        TaobaoTradeReporter.perform_async(id, current_user)
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
      self.conditions['search']['created'] = "#{st};#{et}"
      self.save
    end
  end

  def adjust_merged_trade_search
    adapted_conditions = self.conditions
    types = adapted_conditions["search"]["_type"]
    if types.present?
      if types == ["Trade"]
        adapted_conditions['search']["merge_type"] = "export_merged"
        adapted_conditions['search']["_type"] = ["TaobaoTrade", "CustomTrade-handmade_trade"]
      else
        adapted_conditions['search']["_type"].delete("Trade")
      end
    end
    self.reload
    recursive_symbolize_keys! adapted_conditions
  end

  def change_scope
    scope = "scoped"
    self.conditions["search"]["_type"]
    if self.conditions["search"]["_type"]
      scope = "unscoped" if self.conditions["search"]["_type"].include?("Trade")
    end
    scope
  end

  def trades
    Trade.filter(fetch_account, fetch_user, self.adjust_merged_trade_search, change_scope)
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
