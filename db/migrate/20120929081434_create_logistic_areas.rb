class CreateLogisticAreas < ActiveRecord::Migration
  def change
    create_table :logistic_areas do |t|
      t.integer "logistic_id"
      t.integer "area_id"
      t.timestamps
    end
    add_index :logistic_areas, :logistic_id
    add_index :logistic_areas, :area_id
  end

  def self.down
    drop_table :logistic_areas
  end
end
