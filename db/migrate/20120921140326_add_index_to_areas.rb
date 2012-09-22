class AddIndexToAreas < ActiveRecord::Migration
  def change
  	add_index :areas, :parent_id
  	add_index :areas, :name
  end
end
