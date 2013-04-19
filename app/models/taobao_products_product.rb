class TaobaoProductsProduct < ActiveRecord::Base
   attr_accessible :product_id, :taobao_product_id, :number
   belongs_to :product
   belongs_to :taobao_product
end
