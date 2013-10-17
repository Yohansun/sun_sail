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

  after_commit :write_cache

  class << self
    # *ActiveRecord::Querying#find* cache.
    # Does not support to *ActiveRecord::Relation#find*
    # For example:
    #     TradeSource.find 1
    #     => TradeSource Load (0.4ms)  SELECT `trade_sources`.* FROM `trade_sources` WHERE `trade_sources`.`id` = 1 LIMIT 1
    #     =>  #<TradeSource id: 1,name: "foo",.....>
    #     TradeSource.find 1
    #     =>  #<TradeSource id: 1,name: "foo",.....>
    #     TradeSource.find(1).update_attributes(name: "bar")
    #     =>  #<TradeSource id: 1,name: "bar",.....>
    #     TradeSource.find 1
    #     =>  #<TradeSource id: 1,name: "bar",.....>
    def find_with_old(*args)
      cache.fetch(cache_key(*args)) { write_cache(*args) }
    end

    def write_cache(*args)
      cache.write(cache_key(*args),self.find_without_old(*args),expires_in: 24.hours)
      cache.read(cache_key(*args))
    end

    alias_method_chain :find,:old

    def cache_key(*args)
      prefix << args.join(":")
    end

    def prefix
      self.name << "- "
    end

    def cache
      Rails.cache
    end
  end

  def write_cache
    reg = /^#{self.class.prefix}.+[#{id}]+|all|first|last/
    Rails.cache.delete_matched(reg)
    self.class.write_cache(id)
  end
end
