class AddLastRefreshAtToTaobaoAppTokens < ActiveRecord::Migration
  def change
    add_column :taobao_app_tokens, :last_refresh_at, :datetime
  end
end
