class AddExpiresInToTaobaoAppToken < ActiveRecord::Migration
  def change
    add_column :taobao_app_tokens, :re_expires_in, :integer, :limit => 8
    add_column :taobao_app_tokens, :r1_expires_in, :integer, :limit => 8
    add_column :taobao_app_tokens, :r2_expires_in, :integer, :limit => 8
    add_column :taobao_app_tokens, :w1_expires_in, :integer, :limit => 8
    add_column :taobao_app_tokens, :w2_expires_in, :integer, :limit => 8
  end
end
