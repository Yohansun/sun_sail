class AddDefalutCodeToLogistics < ActiveRecord::Migration
  def change
  	change_column :logistics, :code, :string, :default => 'OTHER'
  end
end
