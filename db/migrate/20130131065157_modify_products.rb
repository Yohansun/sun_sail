class ModifyProducts < ActiveRecord::Migration
  def change
  	remove_column :products, :props_str
  	remove_column :products, :binds_str
  	add_column :products, :detail_url, :string
  	add_column :products, :cid, :string #商品所属的叶子类目 id
  	add_column :products, :num_iid, :integer, :limit => 8  #商品数字id
  	rename_column :products, :iid, :outer_id
  	rename_column :products, :taobao_id, :product_id
  end
end
