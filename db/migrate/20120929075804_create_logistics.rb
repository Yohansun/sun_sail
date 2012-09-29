class CreateLogistics < ActiveRecord::Migration
  def change
    create_table :logistics do |t|
      t.string :name
      t.string :options
      t.timestamps
    end
  end

  def self.down
    drop_table :logistics
  end
end
