#encoding: utf-8
# == Schema Information
#
# Table name: jingdong_skus
#
#  id           :integer(4)      not null, primary key
#  sku_id       :integer(4)      not null
#  shop_id      :integer(4)
#  ware_id      :integer(4)
#  status       :string(255)
#  attribute_s  :string(255)
#  stock_num    :integer(4)
#  jd_price     :integer(10)
#  cost_price   :integer(10)
#  market_price :integer(10)
#  outer_id     :string(255)
#  created      :datetime
#  modified     :datetime
#  color_value  :string(255)
#  size_value   :string(255)
#  account_id   :integer(4)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

class JingdongSku < ActiveRecord::Base
  include MagicEnum
  # attr_accessible :title, :body
  has_many :sku_bindings,:include => :sku, dependent: :destroy,:conditions => {:resource_type => "JingdongSku"},:foreign_key => :resource_id
  has_many :skus,:include => :product, through: :sku_bindings
  belongs_to :jingdong_product, :class_name => "JingdongProduct", :foreign_key => "ware_id",:primary_key => "ware_id"
  belongs_to :account
  enum_attr :status ,[["有效","VALID"],["无效","INVALID"],["删除","DELETE"]]

  def title
    "#{jingdong_product.try(:title)} #{name}"
  end

  def name
    #PENDING 抓取分类名称的接口有待优化，先以value替代
    JingdongCategory.new(self).attvalue_names.join(",") rescue ""
  end

  def value
    JingdongCategory.new(self).attvalue_names.join(",") rescue ""
  end

  def number(local_sku_id)
    sku_bindings.where(sku_id: local_sku_id).first.number
  end
end
