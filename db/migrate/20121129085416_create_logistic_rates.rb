class CreateLogisticRates < ActiveRecord::Migration
  def change
  	create_table  :logistic_rates do |t|
      t.integer   :seller_id
      t.integer   :logistic_id
      t.integer   :score
      t.string    :mobile
      t.string    :tid
      t.datetime  :send_at
      t.timestamps
    end
  end
end