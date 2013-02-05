class AddSeveralColumnsToTradeSource < ActiveRecord::Migration
  def change
  	add_column :trade_sources, :sid, :integer
  	add_column :trade_sources, :cid, :integer
  	add_column :trade_sources, :created, :datetime
  	add_column :trade_sources, :modified, :datetime
  	add_column :trade_sources, :bulletin, :string
  	add_column :trade_sources, :title, :string
  	add_column :trade_sources, :description, :string
  end
end
