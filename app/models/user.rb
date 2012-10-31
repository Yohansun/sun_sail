# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  rolify
  belongs_to :area
  belongs_to :seller
  belongs_to :logistic
  has_many   :trade_reports

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable

  devise :database_authenticatable, :lockable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :role_level, :username, :active
  attr_protected :cs, :cs_read, :seller, :interface, :stock_admin, :admin
  # attr_accessible :title, :body

  validates_presence_of :name, :username, :email
  validates_presence_of :password, on: :create
  validates_uniqueness_of :username

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
end