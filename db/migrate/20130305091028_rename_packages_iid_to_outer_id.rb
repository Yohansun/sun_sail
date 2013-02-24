class RenamePackagesIidToOuterId < ActiveRecord::Migration
  def change
  	rename_column :packages, :iid, :outer_id
  end
end
