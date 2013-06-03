# == Schema Information
#
# Table name: accounts
#
#  id                :integer(4)      not null, primary key
#  name              :string(255)
#  key               :string(255)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  seller_name       :string(255)
#  address           :string(255)
#  phone             :string(255)
#  deliver_bill_info :string(255)
#  point_out         :string(255)
#  website           :string(255)
#

#encoding: utf-8

# == Schema Information
#
# Table name: accounts
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  key        :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#
class Account < ActiveRecord::Base
  include RailsSettings

  attr_accessible :key, :name, :seller_name, :address, :deliver_bill_info, :phone, :website, :point_out 

  has_and_belongs_to_many :users

  has_many :bbs_categories
  has_many :bbs_topics
  has_many :categories
  has_many :colors
  has_many :packages
  has_many :products
  has_many :taobao_products
  has_many :quantities
  has_many :sales
  has_many :sellers
  has_many :settings
  has_many :stocks
  has_many :stock_histories
  has_many :stock_products
  has_many :features
  has_many :reconcile_statements
  has_many :logistics
  has_many :logistic_areas
  has_many :onsite_service_areas
  has_many :logistic_rates
  has_many :logistic_groups
  has_many :trade_sources
  has_many :roles, :dependent => :destroy
  has_many :skus
  has_many :taobao_skus
  has_one :trade_source

  validates :name, presence: true
  validates :key, presence: true, uniqueness: true

  def in_time_gap(start_at, end_at)
    if start_at != nil && end_at != nil
      if start_at < end_at
        start_time = (Time.now.to_date.to_s + " " + start_at).to_time(:local).to_i
        end_time = (Time.now.to_date.to_s + " " + end_at).to_time(:local).to_i
        time_now = Time.now.to_i
        if time_now >= start_time && time_now <= end_time
          return true
        elsif time_now < start_time
          return (start_time - time_now)
        elsif time_now > end_time
          return (86400 + start_time - time_now)
        end
      elsif start_at > end_at
        time_now = Time.now.strftime("%H:%M:%S")
        if time_now >= end_at && time_now <= start_at
          start_time = (Time.now.to_date.to_s + " " + start_at).to_time(:local).to_i
          time_now = (Time.now.to_date.to_s + " " + time_now).to_time(:local).to_i
          return (start_time - time_now)
        else
          return true
        end
      end
    else
      return true # default gap is all day
    end
  end

  def can_auto_preprocess_right_now
    return in_time_gap(self.settings.auto_settings["start_preprocess_at"], self.settings.auto_settings["end_preprocess_at"])
  end

  def can_auto_dispatch_right_now
    return in_time_gap(self.settings.auto_settings["start_dispatch_at"], self.settings.auto_settings["end_dispatch_at"])
  end

  def can_auto_deliver_right_now
    return in_time_gap(self.settings.auto_settings["start_deliver_at"], self.settings.auto_settings["end_deliver_at"])
  end
end
