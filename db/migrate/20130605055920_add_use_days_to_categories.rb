class AddUseDaysToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :use_days, :integer,:default => 0, :null => false
  end
end
