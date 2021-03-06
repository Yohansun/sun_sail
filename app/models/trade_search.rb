# -*- encoding:utf-8 -*-
class TradeSearch
  include Mongoid::Document
  include MagicEnum

  ENABLED_TRUE = true
  ENABLED_FALSE = false

  enum_attr :enabled,[["启用",ENABLED_TRUE],["禁用",ENABLED_FALSE]],:not_valid => true
  enum_attr :show_in_tabs,[["是",true],["否",false]],:not_valid => true



  field :account_id, type: Integer
  field :name, type: String
  field :html, type: String
  field :enabled,  type: Boolean,   :default=>true
  field :show_in_tabs,  type: Boolean
  field :show_in_simple_model,  type: Boolean
  field :trade_mode,  type: String
  field :trade_type,  type: String
  field :search_hash, type: Hash
end
