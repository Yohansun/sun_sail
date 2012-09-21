class ChangeLevelCategoryQuantityColumnInProduct < ActiveRecord::Migration
  def change
  	change_column :products, :category_id, :integer
  	change_column :products, :quantity_id, :integer
  	change_column :products, :level_id, :integer
  end
end
