# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: trade_sources
#
#  id                  :integer(4)      not null, primary key
#  account_id          :integer(4)
#  name                :string(255)
#  app_key             :string(255)
#  secret_key          :string(255)
#  session             :string(255)
#  created_at          :datetime        not null
#  updated_at          :datetime        not null
#  trade_type          :string(255)
#  fetch_quantity      :integer(4)      default(20)
#  fetch_time_circle   :integer(4)      default(15)
#  high_pressure_valve :boolean(1)      default(FALSE)
#  sid                 :integer(4)
#  cid                 :integer(4)
#  created             :datetime
#  modified            :datetime
#  bulletin            :string(255)
#  title               :string(255)
#  description         :string(255)
#  jushita_sync        :boolean(1)      default(FALSE)
#  enabled_checker     :boolean(1)      default(FALSE)
#

class TradeSource < ActiveRecord::Base
  include FinderCache
  include RailsSettings
  include MagicEnum
  attr_accessible :account_id,
                  :app_key,
                  :name,
                  :secret_key,
                  :session,
                  :sid,
                  :cid,
                  :bulletin,
                  :title,
                  :description,
                  :created,
                  :modified,
                  :trade_type,
                  :enabled_checker
  belongs_to :account,:inverse_of => :trade_sources
  has_one :taobao_app_token
  has_one :jingdong_app_token
  has_one :yihaodian_app_token

  enum_attr :trade_type,[%w(淘宝 Taobao),%w(京东 Jingdong), %w(一号店 Yihaodian)],not_valid: true

  validates :name, presence: true, uniqueness: true

  def jingdong_query_conditions
    return if jingdong_app_token.nil?
    {"access_token" => jingdong_app_token.access_token,"app_key" => TradeSetting.jingdong_app_key,"secret_key" => TradeSetting.jingdong_app_secret}
  end

  def yihaodian_query_conditions
    return if yihaodian_app_token.nil?
    {"access_token" => yihaodian_app_token.access_token,"app_key" => TradeSetting.yihaodian_app_key,"secret_key" => TradeSetting.yihaodian_app_secret}
  end

  # 激活聚石塔数据同步 (前提条件是聚石塔已激活此用户)
  def enable_jsync
    update_attribute(:jushita_sync, true)
  end

  # 关闭聚石塔数据同步
  def lock_jsync
    update_attribute(:jushita_sync, false)
  end
end
