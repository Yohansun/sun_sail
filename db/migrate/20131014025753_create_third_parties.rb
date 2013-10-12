class CreateThirdParties < ActiveRecord::Migration
  def change
    create_table :third_parties do |t|
      t.integer :user_id
      t.integer :account_id
      t.string :name
      t.string :authentication_token

      t.timestamps
    end
  end
end
