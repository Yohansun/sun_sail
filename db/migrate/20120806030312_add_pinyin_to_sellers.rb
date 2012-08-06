class AddPinyinToSellers < ActiveRecord::Migration
  def change
    add_column :sellers, :pinyin, :string
  end
end
