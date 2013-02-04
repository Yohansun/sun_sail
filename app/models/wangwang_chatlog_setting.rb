# -*- encoding : utf-8 -*-
class WangwangChatlogSetting
  include Mongoid::Document
  
  field :self_buyer_filter,         type: Boolean,  default: false
  #field :chitu_buyer_filter,       type: Boolean,  default: false
  #field :chitu_list,               type: Array
  #field :e_buyer_filter,           type: Boolean,  default: false
  field :wangwang_account_filter,   type: Boolean,  default: false
  field :wangwang_list,             type: Hash,     default: {}
  field :ad_filter,                 type: Boolean,  default: false
  field :ad_msg,                    type: String
  field :ad_chat_length,            type: Integer
  field :main_account_filter,       type: Boolean,  default: false
  field :main_account_list,         type: Array,    default: []
  field :main_account_msg,          type: String
  field :one_word_filter,           type: Boolean,  default: false
  field :one_word_chat_length,      type: Integer
  field :mass_msg_filter,           type: Boolean,  default: false
  field :wangwang_solo_filter,      type: Boolean,  default: false

end
