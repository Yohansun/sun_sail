class RenameLevelIdOfGrades < ActiveRecord::Migration
  def up
    change_table :products do |t|
      t.rename :level_id, :grade_id
    end
  end

  def down
    change_table :products do |t|
      t.rename :grade_id, :level_id
    end
  end
end
