# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: logistics
#
#  id                :integer(4)      not null, primary key
#  name              :string(255)
#  options           :string(255)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  code              :string(255)     default("OTHER")
#  print_image       :string(255)
#  account_id        :integer(4)
#  basic_post_weight :float           default(0.0)
#  extra_post_weight :float           default(0.0)
#  basic_post_fee    :float           default(0.0)
#  extra_post_fee    :float           default(0.0)
#

require 'hashie'
class Logistic < ActiveRecord::Base
  include FinderCache
  mount_uploader :print_image, LogisticImageUploader
  belongs_to :account
  has_many :logistic_areas
  has_many :areas, through: :logistic_areas ,:dependent => :destroy
  has_many :users
  has_one :print_flash_setting, :dependent => :destroy
  accepts_nested_attributes_for :print_flash_setting

  attr_accessible :name,
                  :code,
                  :print_image,
                  :basic_post_weight,
                  :basic_post_fee,
                  :extra_post_weight,
                  :extra_post_fee
  validates :name, presence: true, uniqueness: { scope: :account_id }

  validates_presence_of :code

  scope :with_account, ->(account_id) { where(:account_id => account_id)}

  alias default_print_flash_setting print_flash_setting

  def print_flash_setting
    self.default_print_flash_setting || (self.build_print_flash_setting && self.save)
    self.default_print_flash_setting
  end

  def self.three_mostly_used

    map = %Q{
      function() {
        if(this.logistic_id != null){
          emit(this.logistic_id, {num: 1});
        }
      }
    }

    reduce = %Q{
      function(key, values) {
        var result = {num: 0};
        values.forEach(function(value) {
          result.num += value.num;
        });
        return result;
      }
    }

    map_reduce_info = Trade.between(created: (Time.now - 3.months)..Time.now).ne(logistic_id: nil).map_reduce(map, reduce).out(inline: true).sort{|a, b| b['value']['num'] <=> a['value']['num']}
    ids = [].tap do |id|
      map_reduce_info.each_with_index do |info, i|
        id << info["_id"].to_i if i <= 2
      end
    end
    ids
  end

  def cache
    Rails.cache
  end

  def fetch_cache(name)
    cache.fetch(name,expires_in: 1.hour,namespace: self.class.name) { yield }
  end
  # 缓存淘宝所有物流商
  def taobao_logistics(trade_source_id)
    response = fetch_cache("taobao") do
      TaobaoQuery.get({method: "taobao.logistics.companies.get", fields: 'id,code,name,reg_mail_no'},trade_source_id)
    end
    logistics_company = response["logistics_companies_get_response"]["logistics_companies"]["logistics_company"] rescue []
  end
  # 缓存京东所有物流商
  def jingdong_logistics(trade_source_id)
    response = fetch_cache("jingdong") do
      api_paramters = TradeSource.find(trade_source_id).jingdong_query_conditions
      JingdongQuery.get({method: '360buy.delivery.logistics.get'},api_paramters)
    end
    logistics_list = response["delivery_logistics_get_response"]["logistics_companies"]["logistics_list"] rescue []
  end
  # 缓存一号店所有物流商
  def yihaodian_logistics(trade_source_id)
    response = fetch_cache("yihaodian") do
      api_paramters = TradeSource.find(trade_source_id).yihaodian_query_conditions
      YihaodianQuery.post({method: 'yhd.logistics.deliverys.company.get'},api_paramters)
    end
    logistics_info = response["response"]["logisticsInfoList"]["logisticsInfo"] rescue []
  end
  #获取当前物流对应淘宝物流商的ID
  def taobao_logistic_id(trade_source_id)
    taobao_logistics = taobao_logistics(trade_source_id)
    m = Hashie::Mash.new taobao_logistics.find {|u| matched?(u["name"])}
    m.id
  end
  #获取当前物流对应京东物流商的ID
  def jingdong_logistic_id(trade_source_id)
    jingdong_logistics = jingdong_logistics(trade_source_id)
    m = Hashie::Mash.new jingdong_logistics.find {|u| matched?(u["logistics_name"])}
    m.logistics_id
  end
  #获取当前物流对应一号店物流商的ID
  def yihaodian_logistic_id(trade_source_id)
    yihaodian_logistics = yihaodian_logistics(trade_source_id)
    m = Hashie::Mash.new yihaodian_logistics.find {|u| matched?(u["companyName"])}
    m.id
  end

  def matched?(sname)
    sname =~ /^#{name.to(1)}/
  end
end
