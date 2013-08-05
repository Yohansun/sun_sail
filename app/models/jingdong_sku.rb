#encoding: utf-8
class JingdongSku < ActiveRecord::Base
  include MagicEnum
  # attr_accessible :title, :body
  has_many :sku_bindings,:include => :sku, dependent: :destroy,:conditions => {:resource_type => "JingdongSku"},:foreign_key => :resource_id
  has_many :skus,:include => :product, through: :sku_bindings
  belongs_to :jingdong_product, :class_name => "JingdongProduct", :foreign_key => "ware_id",:primary_key => "ware_id"
  belongs_to :account
  enum_attr :status ,[["有效","VALID"],["无效","INVALID"],["删除","DELETE"]]

  def title
    "#{jingdong_product.try(:title)}#{name}"
  end

  def name
    #PENDING
    ""
  end

  def value
    #PENDING
    ""
  end

  def number(local_sku_id)
    sku_bindings.where(sku_id: local_sku_id).first.number
  end
end
