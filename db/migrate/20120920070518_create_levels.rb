class CreateLevels < ActiveRecord::Migration
  def change
  	create_table :levels do |t|
  		t.string "name"
        t.datetime "created_at"
    	t.datetime "updated_at"

      t.timestamps			
    end
  end
end
