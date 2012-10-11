class AddCodeToLogistics < ActiveRecord::Migration
  def change
    add_column :logistics, :code, :string
  end
end
