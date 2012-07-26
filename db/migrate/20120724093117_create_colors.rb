 # -*- encoding : utf-8 -*-
class CreateColors < ActiveRecord::Migration
  def self.up
    create_table :colors do |t|
      t.string :hexcode
      t.string :name
      t.string :num

      t.timestamps
    end
    add_index :colors, :num
  end

  def self.down
    drop_table :colors
  end
end
