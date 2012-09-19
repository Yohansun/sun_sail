# -*- encoding : utf-8 -*-
class Product < ActiveRecord::Base
    
  attr_accessible :name, :iid, :taobao_id, :storage_num, :price, :status, :level, :quantity, :category, :features, :technical_data, :description
  
  validates_presence_of :name, :iid, :taobao_id, :storage_num, :price, message: "信息不能为空"
  validates_uniqueness_of :name, :iid, :taobao_id, :storage_num, message: "信息已存在"
  validates_numericality_of :iid, :taobao_id, :storage_num, :price, message: "所填项必须为数字"
  validates_length_of :name, :iid, :taobao_id, :storage_num, :price, maximum: 70, message: "内容过长"
  validates_length_of :technical_data, :description, maximum: 200, message: "内容过长"

  def select_quantity
  	[['5L', "5L"], ['10L', "10L"]]
  end

  def select_category
  	[['全部', "all"], ['网络特供商品', "web_only"],['内墙乳胶漆',"inner_wall"],['外墙乳胶漆',"outer_wall"],['木器漆',"wood"],['DIY色彩系列',"DIY"],['輔助材料',"accessary"]]
  end

  def select_features
  	[['净味功能', "dispell_odor"],['弹性抗裂功能',"resilience"]]
  end

  def select_quantity
  	[['5L', "5L"], ['10L', "10L"]]
  end
  
  def select_level
  	[['低档', "low"], ['中档', "middle"],['高档',"high"]]
  end

  def select_status
  	[['上架', "on_sale"], ['下架', "sold_out"]]
  end
end