class AddXmlToLogistics < ActiveRecord::Migration
  def change
    add_column :logistics, :xml, :string
  end
end
