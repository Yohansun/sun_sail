class CreateJingdongAppTokens < ActiveRecord::Migration
  def change
    create_table :jingdong_app_tokens do |t|
      t.integer :account_id
      t.string :access_token
      t.string :refresh_token
      t.string :jingdong_user_id
      t.string :jingdong_user_nick
      t.integer :trade_source_id

      t.timestamps
    end
  end
end

