# == Schema Information
#
# Table name: onsite_service_areas
#
#  id         :integer(4)      not null, primary key
#  account_id :string(255)
#  area_id    :integer(4)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

# -*- encoding : utf-8 -*-
class OnsiteServiceArea < ActiveRecord::Base
  attr_accessible :account_id, :area_id
  belongs_to :account
  belongs_to :area

  after_create :sync_on_service_status
  before_destroy :sync_on_service_status

  def sync_on_service_status
    Trade.where(area_id: area_id, account_id: account_id).each do |trade| 
      trade.set_has_onsite_service
      trade.save 
    end 
  end 
end
