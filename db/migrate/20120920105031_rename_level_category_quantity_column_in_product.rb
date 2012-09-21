class RenameLevelCategoryQuantityColumnInProduct < ActiveRecord::Migration
  def change
  	rename_column :products, :category, :category_id
  	rename_column :products, :quantity, :quantity_id
  	rename_column :products, :level, :level_id
  end
end
