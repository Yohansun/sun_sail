# -*- encoding : utf-8 -*-
class Notify
  include Mongoid::Document
  include Mongoid::Timestamps

  field :account_id, 			type: Integer
  field :trade_id, 			  type: String
  field :notify_sender,  	type: String
  field :notify_contact, 	type: String
  field :notify_theme,		type: String
  field :notify_type,   	type: String
  field :notify_content,	type: String
  field :notify_time, 		type: DateTime

  scope :sms, ->(account_id) { where(:account_id => account_id, :notify_type => 'sms') }
  scope :email, ->(account_id) { where(:account_id => account_id, :notify_type => 'Email') }

  scope :search_date, ->(start_at, end_at) {where(:created_at.gt => start_at, :created_at.lt => end_at)}
	scope :order_desc, order_by("created_at desc")

  def fetch_account
    return Account.find_by_id(self.account_id) if self.account_id_change
    @account ||= Account.find_by_id(self.account_id)
  end

end