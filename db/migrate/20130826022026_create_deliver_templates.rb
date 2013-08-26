class CreateDeliverTemplates < ActiveRecord::Migration
  def change
    create_table :deliver_templates do |t|
      t.string :name
      t.string :xml
      t.string :image
      t.string :account_id
      t.timestamps
    end
  end
end
