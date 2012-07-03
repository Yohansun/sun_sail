class AddTypeAndZipToAreas < ActiveRecord::Migration
  def change
    add_column :areas, :area_type, :integer
    add_column :areas, :zip, :string
  end
end
