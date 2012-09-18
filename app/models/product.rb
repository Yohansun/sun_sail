# -*- encoding : utf-8 -*-
class Product < ActiveRecord::Base
    
  attr_accessible :name, :iid, :taobao_id, :storage_num, :price, :status, :level, :quantity, :category, :features, :technical_data, :description
  
  validates_presence_of :name, :iid, :taobao_id, :storage_num, :price
  validates_uniqueness_of :name, :iid, :taobao_id, :storage_num

  validates_presence_of :iid

end