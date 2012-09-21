class CreateFeatures < ActiveRecord::Migration
  def change
  	create_table :features do |t|
  		t.string "name"
      t.datetime "created_at"
    	t.datetime "updated_at"
 
      t.timestamps			
    end

    create_table :feature_product_relationships do |t|
	    t.integer  "product_id"
	    t.integer  "feature_id"
	    t.datetime "created_at"
	    t.datetime "updated_at"

	  t.timestamps
    end
  end
end