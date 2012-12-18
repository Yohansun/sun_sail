# == Schema Information
#
# Table name: feature_product_relationships
#
#  id         :integer(4)      not null, primary key
#  product_id :integer(4)
#  feature_id :integer(4)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

# -*- encoding : utf-8 -*-
class FeatureProductRelationship < ActiveRecord::Base
  belongs_to :product, :class_name => "Product", :foreign_key => "product_id"
  belongs_to :feature, :class_name => "Feature", :foreign_key => "feature_id"
end
