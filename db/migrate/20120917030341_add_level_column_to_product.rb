class AddLevelColumnToProduct < ActiveRecord::Migration
  def change
  	add_column :products, :level, :string
  	remove_column :products, :class
  end
end
