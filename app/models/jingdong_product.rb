#encoding: utf-8
# == Schema Information
#
# Table name: jingdong_products
#
#  id                   :integer(4)      not null, primary key
#  ware_id              :integer(8)      not null
#  spu_id               :string(255)
#  cid                  :integer(4)
#  vender_id            :integer(4)
#  shop_id              :integer(4)
#  ware_status          :string(255)
#  title                :string(255)
#  item_num             :string(255)
#  upc_code             :string(255)
#  transport_id         :integer(4)
#  online_time          :string(255)
#  offline_time         :string(255)
#  attribute_s          :string(255)
#  desc                 :text
#  producter            :string(255)
#  wrap                 :string(255)
#  cubage               :string(255)
#  pack_listing         :string(255)
#  service              :string(255)
#  cost_price           :integer(10)
#  market_price         :integer(10)
#  jd_price             :integer(10)
#  stock_num            :integer(4)
#  logo                 :string(255)
#  creator              :string(255)
#  status               :string(255)
#  weight               :integer(4)
#  created              :datetime
#  modified             :datetime
#  outer_id             :string(255)
#  shop_categorys       :string(255)
#  is_pay_first         :boolean(1)
#  is_can_vat           :boolean(1)
#  is_imported          :boolean(1)
#  is_health_product    :boolean(1)
#  is_shelf_life        :boolean(1)
#  shelf_life_days      :integer(4)
#  is_serial_no         :boolean(1)
#  is_appliances_card   :boolean(1)
#  is_special_wet       :boolean(1)
#  ware_big_small_model :integer(4)
#  ware_pack_type       :integer(4)
#  account_id           :integer(4)
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  trade_source_id      :integer(4)
#  shop_name            :string(255)
#

class JingdongProduct < ActiveRecord::Base
  include MagicEnum
  # attr_accessible :title, :body
  has_many :jingdong_skus, :class_name => "JingdongSku", :foreign_key => "ware_id",:primary_key => "ware_id", dependent: :destroy
  enum_attr :ware_status,          [["从未上架","NEVER_UP"],["自主下架","CUSTORMER_DOWN"],["系统下架","SYSTEM_DOWN"],["在售","ON_SALE"],["待审核","AUDIT_AWAIT"],["审核不通过","AUDIT_FAIL"]]
  enum_attr :status,               [["删除","DELETE"],["无效","INVALID"],["有效","VALID"]]
  enum_attr :ware_big_small_model, [["免费",0],["超大件",1],["超大件半件",2],["大件",3],["大件半件",4],["中件",5],["中件半件",6],["小件",7],["超小件",8]],:not_valid => true
  enum_attr :ware_pack_type,       [["普通商品",1],["易碎品",2],["裸瓶液体",3],["带包装液体",4],["按原包装出库",5]],:not_valid => true
  scope :with_account, ->(account_id){ where(account_id: account_id) }
  belongs_to :account

  def has_bindings
    status = "未绑定"
    jingdong_skus.each do |sku|
      if sku.sku_bindings.present?
        status = "已绑定"
      else
        status = "部分绑定" and break if status == "已绑定"
      end
    end
    return status
  end
end
