#encoding: utf-8
class JingdongProduct < ActiveRecord::Base
  include MagicEnum
  # attr_accessible :title, :body
  has_many :jingdong_skus, :class_name => "JingdongSku", :foreign_key => "ware_id",:primary_key => "ware_id"
  enum_attr :ware_status,          [["从未上架","NEVER_UP"],["自主下架","CUSTORMER_DOWN"],["系统下架","SYSTEM_DOWN"],["在售","ON_SALE"],["待审核","AUDIT_AWAIT"],["审核不通过","AUDIT_FAIL"]]
  enum_attr :status,               [["删除","DELETE"],["无效","INVALID"],["有效","VALID"]]
  enum_attr :ware_big_small_model, [["免费",0],["超大件",1],["超大件半件",2],["大件",3],["大件半件",4],["中件",5],["中件半件",6],["小件",7],["超小件",8]],:not_valid => true
  enum_attr :ware_pack_type,       [["普通商品",1],["易碎品",2],["裸瓶液体",3],["带包装液体",4],["按原包装出库",5]],:not_valid => true
  scope :with_account, ->(account_id){ where(account_id: account_id) }
end
