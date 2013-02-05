# == Schema Information
#
# Table name: users
#
#  id                   :integer(4)      not null, primary key
#  username             :string(255)     not null
#  name                 :string(255)
#  email                :string(255)     default(""), not null
#  encrypted_password   :string(128)     default(""), not null
#  password_salt        :string(255)     default(""), not null
#  reset_password_token :string(255)
#  remember_token       :string(255)
#  remember_created_at  :datetime
#  sign_in_count        :integer(4)      default(0)
#  current_sign_in_at   :datetime
#  last_sign_in_at      :datetime
#  current_sign_in_ip   :string(255)
#  last_sign_in_ip      :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  role                 :string(255)
#  role_level           :integer(4)      default(10)
#  sellers_count        :integer(4)      default(0)
#  parent_id            :integer(4)
#  children_count       :integer(4)      default(0)
#  lft                  :integer(4)      default(0)
#  rgt                  :integer(4)      default(0)
#  active               :boolean(1)      default(TRUE)
#  seller_id            :integer(4)
#  logistic_id          :integer(4)
#  failed_attempts      :integer(4)
#  unlock_token         :string(255)
#  locked_at            :datetime
#

# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  rolify
  belongs_to :area
  belongs_to :seller
  belongs_to :logistic
  has_many   :trade_reports
  has_and_belongs_to_many :accounts

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable

  devise :database_authenticatable, :lockable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :role_level, :username, :active
  attr_protected :cs, :cs_read, :seller, :interface, :stock_admin, :admin
  # attr_accessible :title, :body

  validates_presence_of :name, :email
  validates_presence_of :password, on: :create

  validates :username, presence: true

  def display_name
    name || email
  end

  class << self
    def find_for_database_authentication(conditions)
      user = find(:first, :conditions => conditions)
      if user.nil?
        find(:first, :conditions => {:username => conditions[:email]})
      else
        user
      end
    end
  end

  def magic_key
    Digest::MD5.hexdigest "magic_magic_#{self.username}"
  end

  def role_key
    case self.role_level
    when 0
      'admin'
    when 10
      'seller'
    when 12
      'interface'
    when 15
      'cs'
    end
  end

  def modify_role(role, type)
    if type == '1'
      add_role role.to_sym
    else
      remove_role role.to_sym
    end
  end

  def present_roles
    roles = self.roles.map {|r| r.role_s }.join(",")
  end

  def has_multiple_account?
    self.accounts.size > 1
  end
end
