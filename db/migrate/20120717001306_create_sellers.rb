class CreateSellers < ActiveRecord::Migration
  def change
    create_table :sellers do |t|
      t.string :name
      t.string :fullname
      t.string :address
      t.string :mobile
      t.string :phone

      t.timestamps
    end
  end
end
