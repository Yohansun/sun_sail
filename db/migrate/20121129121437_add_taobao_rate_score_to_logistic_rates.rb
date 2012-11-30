class AddTaobaoRateScoreToLogisticRates < ActiveRecord::Migration
  def change
  	add_column :logistic_rates, :taobao_rate_score, :integer
  end
end
