class CreateBbsTopics < ActiveRecord::Migration
  def change
    create_table :bbs_topics do |t|
      t.integer :bbs_category_id
      t.integer :user_id
      t.string  :title
      t.integer :read_count, default: 0
      t.integer :download_count, default: 0
      t.timestamps
    end
    add_index :bbs_topics, :bbs_category_id
    add_index :bbs_topics, :user_id
  end
end
