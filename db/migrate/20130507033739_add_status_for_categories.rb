class AddStatusForCategories < ActiveRecord::Migration
  def up
    add_column    :categories,    :status,    :integer,   :default=>1
    add_index     :categories,    :status
  end

  def down
    remove_column    :categories,    :status
  end
end
