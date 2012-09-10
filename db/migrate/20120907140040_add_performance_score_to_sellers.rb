class AddPerformanceScoreToSellers < ActiveRecord::Migration
  def change
  	add_column :sellers, :performance_score, :integer, default: 0
  end
end
