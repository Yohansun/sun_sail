# -*- encoding : utf-8 -*-
class WangwangChatmsg
  include Mongoid::Document
  field :account_id, type: Integer
  field :content,    type: String
  field :direction,  type: String
  field :time,       type: DateTime
  
  embedded_in :wangwang_chatlogs
end