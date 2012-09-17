# -*- encoding : utf-8 -*-
class Product < ActiveRecord::Base
  
  attr_accessible :name, :iid, :taobao_id, :storage_num, :price, :status, :level, :quantity, :category, :features, :technical_data, :description

end