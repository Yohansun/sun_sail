class ChangeTableNameOfLevels < ActiveRecord::Migration
  def up
    rename_table :levels, :grades
  end

  def down
    rename_table :grades, :levels
  end
end
