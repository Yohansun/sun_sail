# -*- encoding : utf-8 -*-
class WangwangChatlog
  include Mongoid::Document
  
  field :account_id,     type: Integer
  field :user_id,     type: String
  field :buyer_nick,  type: String
  field :date,        type: Integer
  field :start_time,  type: DateTime
  field :end_time,    type: DateTime
  field :usable,      type: Boolean,  default: true
  field :special_log, type: Boolean,  default: false

  embeds_many :wangwang_chatmsgs

  def chatlog_filter
  	self.adjust_wangwang_solo & self.adjust_mass_msg & self.adjust_one_word & self.adjust_main_account & self.adjust_ad & self.adjust_wangwang_account & self.adjust_self_buyer
  end

  def adjust_self_buyer
  	if WangwangMember.all.map(&:user_id).include?(self.buyer_nick)
      p self._id
      p "adjust_self_buyer"
      p self.special_log = true
      p WangwangChatlogSetting.first.self_buyer_filter ? self.usable = false : self.usable = true
      self.save
    end
  end

  def adjust_wangwang_account
    WangwangChatlogSetting.first.wangwang_list.keys.each do |key|
      if WangwangMember.where(_id: key).first.user_id == self.buyer_nick
        p self._id
        p "adjust_wangwang_account"
        p WangwangChatlogSetting.first.wangwang_account_filter ? self.usable = false : self.usable = true
        self.save
        break
      end
    end
  end

  def adjust_ad
    self.wangwang_chatmsgs.each do |msg|
      if WangwangChatlogSetting.first.ad_msg == msg.content && self.wangwang_chatmsgs.count < WangwangChatlogSetting.first.ad_chat_length
        p self._id
        p "adjust_ad"
        p self.special_log = true
        p WangwangChatlogSetting.first.ad_filter ? self.usable = false : self.usable = true
        self.save
        break
      end
    end
  end

  def adjust_main_account
    self.wangwang_chatmsgs.each do |msg|
      if WangwangChatlogSetting.first.main_account_msg == msg.content
        p self._id
        p "adjust_main_account"
        p self.special_log = true
        p WangwangChatlogSetting.first.main_account_filter ? self.usable = false : self.usable = true
        self.save
        break
      end
    end
  end

  def adjust_one_word
    if self.wangwang_chatmsgs.where(direction: 1).count == 1 && self.wangwang_chatmsgs.count < WangwangChatlogSetting.first.one_word_chat_length
      p self._id
      p "adjust_one_word"
      p self.special_log = true
      p WangwangChatlogSetting.first.one_word_filter ? self.usable = false : self.usable = true
      self.save
    end
  end

  def adjust_mass_msg
  	self.wangwang_chatmsgs.each do |msg|
  	  if (/^@/ =~ msg.content) == 0
        p self._id
        p "adjust_mass_msg"
      	p self.special_log = true
        p WangwangChatlogSetting.first.mass_msg_filter ? self.usable = false : self.usable = true
        self.save
        break
      end
    end
  end

  def adjust_wangwang_solo
    if self.wangwang_chatmsgs.where(direction: 0).count == self.wangwang_chatmsgs.count
      p self._id
      p "adjust_wangwang_solo"
      p self.special_log = true
      p WangwangChatlogSetting.first.wangwang_solo_filter ? self.usable = false : self.usable = true
      self.save
    end
  end

  # def adjust_chitu_buyer
  #   WangwangChatlog.each do |log|
  #     WangwangChatlogSetting.first.chitu_list.each do |chitu|
  #       if chitu == log.buyer_nick
  #         WangwangChatlogSetting.first.chitu_buyer_filter ? log.usable = false : log.usable = true
  #         log.save
  #         break
  #       end
  #     end
  #   end
  # end

  # def adjust_e_buyer
  # end

end
