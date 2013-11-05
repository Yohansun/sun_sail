# == Schema Information
#
# Table name: third_parties
#
#  id                   :integer(4)      not null, primary key
#  user_id              :integer(4)
#  account_id           :integer(4)
#  name                 :string(255)
#  authentication_token :string(255)
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#

class ThirdParty < ActiveRecord::Base
  belongs_to :user
  belongs_to :account
  attr_accessible :account_id, :name, :user_id
  validates :name,:authentication_token,:presence => true
  validates :name,uniqueness: {scope: :account_id}
  attr_protected [:authentication_token,:account_id]

  scope :with_account, ->(account_id) { where(:account_id => account_id) }

  after_save do
    account.settings.third_party_wms = self.name if self.is_default?
  end

  after_destroy do
    account.settings.third_party_wms = nil if self.is_default?
  end

  def reset_authentication_token!
    generate_token
    save(:validate => false)
  end

  def generate_token
    token = friendly_token
    generate_token if self.class.exists?(:authentication_token => token)
    self.authentication_token = token
  end

  private
  require 'securerandom'
  def friendly_token
    SecureRandom.base64(20).tr('+/=lIO0', 'pqrsxyz')
  end
end
