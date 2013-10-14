class ThirdParty < ActiveRecord::Base
  belongs_to :user
  belongs_to :account
  attr_accessible :account_id, :name, :user_id
  validates :name,:authentication_token,:presence => true,:uniqueness => true

  scope :with_account, ->(account_id) { where(:account_id => account_id) }


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
