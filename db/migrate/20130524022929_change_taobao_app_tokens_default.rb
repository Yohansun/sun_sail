class ChangeTaobaoAppTokensDefault < ActiveRecord::Migration
  def change
	change_column :taobao_app_tokens, :need_refresh, :boolean, :default => true
  end
end
