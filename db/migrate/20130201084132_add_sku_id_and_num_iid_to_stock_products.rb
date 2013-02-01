class AddSkuIdAndNumIidToStockProducts < ActiveRecord::Migration
  def change
  	add_column :stock_products, :sku_id, :integer, :limit => 8
  	add_column :stock_products, :num_iid, :integer, :limit => 8
  end
end
