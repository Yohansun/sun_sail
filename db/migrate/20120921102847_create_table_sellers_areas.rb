class CreateTableSellersAreas < ActiveRecord::Migration
  def change
  	create_table :sellers_areas do |t|
      t.integer "seller_id"
      t.integer "area_id"
      t.timestamps
    end

    add_index :sellers_areas, :seller_id
    add_index :sellers_areas, :area_id
  end
end
