class AddTaobaoProductIdToSkus < ActiveRecord::Migration
  def change
  	add_column :skus, :taobao_product_id, :integer
  	remove_column :skus, :product_id
  end
end