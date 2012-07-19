class AddChildrenCountToSellers < ActiveRecord::Migration
  def change
    add_column :sellers, :children_count, :integer, default: 0
    add_column :sellers, :email, :string
    add_column :sellers, :telephone, :string
  end
end
