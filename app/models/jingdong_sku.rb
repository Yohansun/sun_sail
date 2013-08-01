#encoding: utf-8
class JingdongSku < ActiveRecord::Base
  include MagicEnum
  # attr_accessible :title, :body
  belongs_to :jingdong_product, :class_name => "JingdongProduct", :foreign_key => "ware_id",:primary_key => "ware_id"
  enum_attr :status ,[["有效","VALID"],["无效","INVALID"],["删除","DELETE"]]
  
end
