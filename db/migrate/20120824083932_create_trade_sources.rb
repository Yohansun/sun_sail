class CreateTradeSources < ActiveRecord::Migration
  def change
    create_table :trade_sources do |t|
      t.integer :account_id
      t.string :name
      t.string :app_key
      t.string :secret_key
      t.string :session

      t.timestamps
    end
  end
end
