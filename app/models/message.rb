#encoding: utf-8
#本来可以放到消息统计里面去, 但是做那个功能的人不想'扩展'.  我只能另添一个表了
class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  include MagicEnum
  
  field :recipients,  type: String
  field :send_type, type: String
  field :title,    type: String
  field :content,  type: String
  field :perator,  type: String
  field :ip       ,type: String
  field :account_id, type: Integer
  
  enum_attr :send_type, [["短信","sms"],["邮件","mail"]]
  
  validates :recipients,:account_id,:title,:content,:presence => true
  
  after_create do
    CustomerMessage.perform_async(self)
  end
  
  validate do
    errors.add(:recipients,"邮件格式不正确") if self.send_type_mail? && !self.recipients.split(/,|;/).all? {|x| /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.match(x)}
    errors.add(:recipients,"电话号码只能是数字")  if self.send_type_sms? && !self.recipients.split(/,|;/).all? {|x| /^\d+$/.match(x)}
  end
  
  def account
    Account.find(account_id)
  end
end