class CreateProducts < ActiveRecord::Migration
  def change
	  create_table "products" do |t|
      t.string   "name",               :limit => 100,                                :default => "",    :null => false
      t.string   "item_num",           :limit => 20,                                 :default => "",    :null => false
      t.string   "product_num",        :limit => 20,                                 :default => "",    :null => false
      t.string   "storage_num",        :limit => 20,                                 :default => "",    :null => false
      t.decimal  "price",                             :precision => 8,  :scale => 2, :default => 0.0,   :null => false
      t.string   "status"
      t.string   "class"
      t.string   "quantity"
      t.string   "category"
      t.string   "features"
      t.text     "technical_data"
      t.text     "note"
	  end
  end
end
