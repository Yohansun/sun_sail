# encoding: utf-8
# == Schema Information
#
# Table name: users
#
#  id                     :integer(4)      not null, primary key
#  email                  :string(255)     default(""), not null
#  encrypted_password     :string(255)     default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer(4)      default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#  is_super_admin         :boolean(1)      default(FALSE)
#  name                   :string(255)
#  active                 :boolean(1)      default(TRUE)
#  seller_id              :integer(4)
#  username               :string(255)
#  logistic_id            :integer(4)
#  failed_attempts        :integer(4)
#  unlock_token           :string(255)
#  locked_at              :datetime
#  phone                  :string(255)
#

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
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :username, :active
  attr_protected :cs, :cs_read, :seller, :interface, :stock_admin, :admin
  # attr_accessible :title, :body

  EMAIL_FORMAT = /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}\z/
  validates :email, format: { with: EMAIL_FORMAT}, uniqueness: true, presence: true
  PHONE_FORMAT = /^(13[0-9]|15[012356789]|18[0236789]|14[57])[0-9]{8}$/
  validates :phone, format: { with: PHONE_FORMAT}, uniqueness: true, allow_blank: true

  validates_presence_of :password, on: :create
  validates :username , uniqueness: true, presence: true

  validate :has_phone_or_email?
 
  before_save :set_pseudo_username

  def set_pseudo_username
    unless username
      sudo_username = email || phone
      self.username = sudo_username 
    end
  end 
  
  #需要依赖http://wiki.networking.io/pages/viewpage.action?pageId=2555990 中的TradeSetting.trade_pops配置
  #此方法仅列出那样的格式进行替换key
  def permissions
    @trade_pops = {}
    roles.each do |x|
      h = x.permissions[x.name].dup rescue next
      h[x.name] = h.delete("trades")
      @trade_pops.merge!(h) {|a,b,c| b | c}
    end
    @trade_pops
  end
  
  def allow_read?(var)
    return true if has_role?(:admin)
    permission_manages[var.to_s].include?("detail") rescue false
  end
  
  def permission_manages
    @permission = {}
    roles.map(&:permissions).each do |permission|
      permission = permission.values.first
      next if !permission.is_a?(Hash)
      @permission.merge!(permission) {|key,firth,lath| firth | lath }
    end
    @permission
  end

  def display_name
    name || email
  end
  
  def allowed_to?(control,action)
    arys = permission_manages[control.to_s] & MagicOrder::ActionDelega.keys
    MagicOrder::ActionDelega.slice(*arys).any?{|x,y| y.include?(action)}
  end

  def status
    access_locked? ? '禁止' : '生效'
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

  def has_phone_or_email?
     if email.blank? && phone.blank?
        errors.add(:email, "至少输入手机号或者邮箱")
        errors.add(:phone, "至少输入手机号或者邮箱")
     end  
  end

end
