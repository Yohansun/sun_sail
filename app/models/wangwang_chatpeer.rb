class WangwangChatpeer
  include Mongoid::Document  
  field :user_id,    type: String
  field :uid, type: String
  field :date,       type: DateTime

  def buyer_nick
  	uid.gsub("cntaobao", "")
  end

end