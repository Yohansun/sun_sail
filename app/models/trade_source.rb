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
#

class TradeSource < ActiveRecord::Base
  attr_accessible :account_id, :app_key, :name, :secret_key, :session, :sid, :cid, :bulletin, :title, :description, :created, :modified, :trade_type
  belongs_to :account
  has_one :taobao_app_token
  has_one :jingdong_app_token
  has_one :yihaodian_app_token

  validates :name, presence: true, uniqueness: true
end
