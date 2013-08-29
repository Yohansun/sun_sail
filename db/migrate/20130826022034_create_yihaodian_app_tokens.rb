class CreateYihaodianAppTokens < ActiveRecord::Migration
  def change
    create_table :yihaodian_app_tokens do |t|
      t.integer     :account_id
      t.string      :access_token
      t.string      :refresh_token
      t.integer     :yihaodian_user_id
      t.string      :yihaodian_user_nick
      t.integer     :trade_source_id
      t.integer     :isv_id
      t.integer     :merchant_id
      t.string      :user_code
      t.integer     :user_type

      t.timestamps
    end
  end
end
