class CreateDistributors < ActiveRecord::Migration
  def change
    create_table :distributors do |t|
      t.integer :trade_source_id
      t.string  :name                     
      t.string  :trade_type, :string, :default => 'Taobao'                     

      t.timestamps
    end
  end
end
