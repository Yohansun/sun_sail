class AddInterfaceToSellers < ActiveRecord::Migration
  def change
    add_column :sellers, :interface, :string
  end
end
