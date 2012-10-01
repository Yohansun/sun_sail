class AddNameToTaobaoAppTokens < ActiveRecord::Migration
  def change
    add_column :taobao_app_tokens, :name, :string, :null => false
  end
end
