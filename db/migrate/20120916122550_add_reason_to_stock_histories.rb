class AddReasonToStockHistories < ActiveRecord::Migration
  def change
    add_column :stock_histories, :reason, :string
    add_column :stock_histories, :note, :string
  end
end
