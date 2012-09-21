# -*- encoding : utf-8 -*-
class FeatureProductRelationship < ActiveRecord::Base
  belongs_to :product, :class_name => "Product", :foreign_key => "product_id"
  belongs_to :feature, :class_name => "Feature", :foreign_key => "feature_id"
end