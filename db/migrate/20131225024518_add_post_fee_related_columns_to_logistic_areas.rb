class AddPostFeeRelatedColumnsToLogisticAreas < ActiveRecord::Migration
  def change
    add_column :logistic_areas, :basic_post_weight, :float
    add_column :logistic_areas, :extra_post_weight, :float
    add_column :logistic_areas, :basic_post_fee,    :float
    add_column :logistic_areas, :extra_post_fee,    :float
  end
end
