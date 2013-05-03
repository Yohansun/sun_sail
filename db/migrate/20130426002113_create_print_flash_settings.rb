class CreatePrintFlashSettings < ActiveRecord::Migration
  def change
    create_table :print_flash_settings do |t|
      t.text :xml_hash
      t.integer :account_id
      t.integer :logistic_id
      t.timestamps
    end
  end
end