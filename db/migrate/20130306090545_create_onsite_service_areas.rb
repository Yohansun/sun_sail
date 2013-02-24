class CreateOnsiteServiceAreas < ActiveRecord::Migration
  def change
    create_table :onsite_service_areas do |t|
      t.string :account_id
      t.integer :area_id
      t.timestamps
    end
  end
end
