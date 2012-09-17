class RenameThreeColumnInProduct < ActiveRecord::Migration
  def change
  	rename_column :products, :item_num, :iid
  	rename_column :products, :product_num, :taobao_id
  	rename_column :products, :note, :description 
  end
end
