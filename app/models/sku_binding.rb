class SkuBinding < ActiveRecord::Base
  attr_accessible :sku_id, :taobao_sku_id, :number
  belongs_to :taobao_sku
  belongs_to :sku
end
