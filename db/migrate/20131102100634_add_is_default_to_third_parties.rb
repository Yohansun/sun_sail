class AddIsDefaultToThirdParties < ActiveRecord::Migration
  def change
    add_column :third_parties, :is_default, :boolean,default: 0
  end
end
