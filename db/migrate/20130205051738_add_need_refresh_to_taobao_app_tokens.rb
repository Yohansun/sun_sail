class AddNeedRefreshToTaobaoAppTokens < ActiveRecord::Migration
  def change
    add_column :taobao_app_tokens, :need_refresh, :boolean, :default => false
  end
end
