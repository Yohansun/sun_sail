class AddTradeSourceIdToTaobaoAppTokens < ActiveRecord::Migration
  def change
    add_column :taobao_app_tokens, :trade_source_id, :integer
  end
end
