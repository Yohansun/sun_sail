class CreateTaobaoAppTokens < ActiveRecord::Migration
  def change
    create_table :taobao_app_tokens do |t|
      t.integer :account_id
      t.string :access_token
      t.string :taobao_user_id
      t.string :taobao_user_nick
      t.string :refresh_token

      t.timestamps
    end
  end
end
