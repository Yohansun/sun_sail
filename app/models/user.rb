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
  include RailsSettings
  rolify
  belongs_to :area
  belongs_to :seller
  belongs_to :logistic
  has_many   :trade_reports
  has_and_belongs_to_many :accounts
  has_and_belongs_to_many :roles,:join_table =>  "users_roles"

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
  
  def permissions
    @trade_pops = {}
    raise "用户所属店铺为空" if self.account_ids.blank?
    roles.where(:account_id => self.account_ids).each {|x | @trade_pops.merge!(x.permissions) {|key,firth,lath| firth | lath} }
    @trade_pops
  end
  
  def allow_read?(control,action="index")
    arys = parsed_permission[control.to_s] & MagicOrder::ActionDelega.keys
    MagicOrder::ActionDelega.slice(*arys).any?{|x,y| y.include?(action)}
  end

  def display_name
    name || email
  end
  
  def allowed_to?(control,action)
    allow_read?(control,action) || parsed_permission[control.to_s].include?(action.to_s) 
  end
  
  #parse {:stocks => ["stock_in_bills#detail"],"detail"} to {:stocks => ["detail"],:stock_in_bills => ["detail"]}
  def parsed_permission
    @strip_permissions = []
    @parse_permission = Hash.new {|k,v| k[v] = [] }
    @format_permissions = @parse_permission.dup
    permissions.tap do |h| 
      h.each do |x , y | 
        t , h[x] =  y.partition {|v| /#/.match(v)}
       @strip_permissions += t
      end
      @format_permissions.merge!(h)
    end
    @strip_permissions.each do |x| 
      x = x.split(/#/)
      x.replace [x.first,[x.last]]
      @format_permissions.merge!(Hash[*(x)]) {|old,x,y| x | y}
    end
    
    @format_permissions
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
