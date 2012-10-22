class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :iid
      t.integer :number, default: 1
      t.integer :product_id
      t.timestamps
    end

    add_index :packages, :iid
    add_index :packages, :product_id
  end

  def self.down
    drop_table :packages
  end
end
