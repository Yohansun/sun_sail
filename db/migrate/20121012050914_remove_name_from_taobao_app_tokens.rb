class RemoveNameFromTaobaoAppTokens < ActiveRecord::Migration
  def up
    remove_column :taobao_app_tokens, :name
  end

  def down
    add_column :taobao_app_tokens, :name
  end
end
