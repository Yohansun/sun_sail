class CreateSales < ActiveRecord::Migration
  def change
  	create_table :sales do |t|
      t.string   :name
      t.float    :earn_guess
      t.datetime :start_at
      t.datetime :end_at
      t.timestamps
    end
  end
end