class AddColsToTaobaoAppTokens < ActiveRecord::Migration
  def change
    add_column :taobao_app_tokens, :refresh_token_last_refresh_at, :datetime
  end
end
