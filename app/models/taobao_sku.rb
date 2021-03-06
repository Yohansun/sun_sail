# == Schema Information
#
# Table name: taobao_skus
#
#  id                :integer(4)      not null, primary key
#  sku_id            :integer(8)
#  taobao_product_id :integer(8)
#  num_iid           :integer(8)
#  properties        :string(255)     default("")
#  properties_name   :string(255)     default("")
#  quantity          :integer(4)
#  account_id        :integer(4)
#  trade_source_id   :integer(4)
#  shop_name         :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  property_alias    :string(255)
#

class TaobaoSku < ActiveRecord::Base
  attr_protected []
  has_many :sku_bindings,:include => :sku, dependent: :destroy,:conditions => {:resource_type => "TaobaoSku"},:foreign_key => :resource_id
  has_many :skus,:include => :product, through: :sku_bindings
  belongs_to :taobao_product, foreign_key: :num_iid,primary_key: :num_iid
  belongs_to :account

  has_paper_trail

  scope :is_binding, includes(:sku_bindings).where("sku_bindings.id is not null")
  scope :no_binding, includes(:sku_bindings).where("sku_bindings.id is null")
  scope :with_account, ->(account_id){ where(account_id: account_id) }
  def title
    "#{taobao_product.try(:name)}#{name}"
  end

  def name
    aliastr = property_alias && Hash[property_alias.scan(/(\d+:\d+:)(.*?)(?:;|$)/)]
    properties_name && properties_name.gsub(/(\d+:\d+:)([\u4e00-\u9fa5|\w]+:)(.*?)(;|$)/) { |match|  $2 + (aliastr && aliastr[$1] || $3) + $4 }
  end

  def value
    value = ''
    if properties_name.present?
      properties = properties_name.split(';')
      properties.each do |property|
        sku_values = property.split(':')
        sku_value =  sku_values[3]
        value = sku_value + ' '
      end
    end
    value
  end

  def number(local_sku_id)
    sku_bindings.where(sku_id: local_sku_id).first.number
  end
end
