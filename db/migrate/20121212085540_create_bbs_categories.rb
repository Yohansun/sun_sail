class CreateBbsCategories < ActiveRecord::Migration
  def change
    create_table :bbs_categories do |t|
      t.string  :name
      t.timestamps
    end
  end
end
