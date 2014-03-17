# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: distributors
#
#  id              :integer(4)      not null, primary key
#  trade_source_id :integer(4)
#  name            :string(255)
#  trade_type      :string(255)     default("Taobao")
#  string          :string(255)     default("Taobao")
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

class Distributor < ActiveRecord::Base
  include MagicEnum
  acts_as_nested_set :counter_cache => :children_count

  attr_accessible :trade_source_id, :name,
                  :trade_type

  belongs_to :trade_source

  enum_attr :trade_type, [["淘宝", "Taobao"],["京东", "Jingdong"],["一号店", "Yihaodian"]]

  scope :with_trade_source, lambda {|trade_source_id| where(trade_source_id: trade_source_id)}

  validates :name, presence: true, uniqueness: { scope: :trade_source_id }
  validates :trade_type, presence: true


end
