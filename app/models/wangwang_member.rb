# -*- encoding : utf-8 -*-
class WangwangMember
  include Mongoid::Document
  field :user_id, type: String
  field :name,    type: String
  field :decs,    type: String
  validates_uniqueness_of :user_id
  validates_presence_of :user_id

  def service_staff_id
  	"cntaobao" + user_id
  end

  def short_id
    name || user_id.gsub("立邦漆官方旗舰店:","")
  end

  def self.find_with_service_staff_id(service_staff_id)
  	user_id = service_staff_id.gsub("cntaobao", "")
  	where(user_id: user_id).first
  end

  def chatpeers(start_date, end_date)
    WangwangChatpeer.where(user_id: service_staff_id).where(:date.gte => start_date, :date.lt => end_date).map(&:buyer_nick)
  end
end