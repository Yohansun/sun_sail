class AddDefaultPostFeeRelatedColumnsToLogistics < ActiveRecord::Migration
  def change
    add_column :logistics, :basic_post_weight,  :float, default: 0
    add_column :logistics, :extra_post_weight,  :float, default: 0
    add_column :logistics, :basic_post_fee,     :float, default: 0
    add_column :logistics, :extra_post_fee,     :float, default: 0
  end
end
