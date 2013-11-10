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
#  superadmin             :boolean(1)      default(FALSE), not null
#  can_assign_trade       :boolean(1)
#  trade_percent          :integer(4)
#

class User < ActiveRecord::Base
  include RailsSettings
  include MagicEnum
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

  devise :database_authenticatable, :lockable,:registerable,
         :recoverable, :rememberable, :trackable#, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :username, :active, :can_assign_trade, :percent
  attr_protected :cs, :cs_read, :seller, :interface, :stock_admin, :admin
  attr_accessor :current_account_id
  # attr_accessible :title, :body

  EMAIL_FORMAT = /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}\z/
  validates :email,
            format: { with: EMAIL_FORMAT, message: "填写格式不正确"},
            uniqueness: {message: "该邮箱已有人使用"},
            presence: {message: "输入信息不能为空"},
            allow_blank: true

  PHONE_FORMAT = /^(\w){11}$/
  validates :phone,
            format: { with: PHONE_FORMAT, message: "请输入有效的手机号码"},
            uniqueness: {message: "该手机号码已有人使用"},
            allow_blank: true

  validates_presence_of :password, on: :create
  validates :username ,
            uniqueness: {message: "该用户名已有人使用"},
            presence: true
#            format: { with: /\A[A-Za-z0-9]{4,9}\z/, message: "填写4-9位数字或者字母"}

  validate :has_phone_or_email?

  before_save :set_pseudo_username

  enum_attr :active, [["生效",true],["禁用",false]]

  def set_pseudo_username
    unless username
      last_user = User.last
      if last_user.present?
        last_id = last_user.id
      else
        last_id = 0
      end
      self.username = "user#{last_id+1}"
    end
  end

  def permissions
    @trade_pops = {}
    raise "用户所属店铺为空" if self.account_ids.blank?
    condis = @current_account_id || self.account_ids
    roles.where(:account_id => condis).each {|x | @trade_pops.merge!(x.permissions) {|key,firth,lath| firth | lath} }
    @trade_pops
  end

  def allow_read?(control,action="index")
    return true if self.superadmin?
    return true if MagicOrder::DefaultAccesses.any?{|c,actions| c == control.to_s && actions.include?(action.to_s)}
    arys = parsed_permission[control.to_s] & MagicOrder::ActionDelega.keys
    MagicOrder::ActionDelega.slice(*arys).any?{|x,y| y.include?(action.to_s)}
  end

  def display_name
    if self.name.present?
      self.name
    elsif self.username.present?
      self.username
    else
      self.email
    end
  end

  def allowed_to?(control,action)
    allow_read?(control,action) || parsed_permission[control.to_s].include?(action.to_s)
  end

  def superadmin!
    self.superadmin = true
    self.save!
  end

  def remove_superadmin!
    self.superadmin = false
    self.save!
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
      errors.add(:email, "至少输入手机号或者邮箱") if errors[:email].blank?
      errors.add(:phone, "至少输入手机号或者邮箱") if errors[:phone].blank?
    end
  end


  # override rolify , because right now , roles depend on accounts, not a uniq name
  def add_role(role_name, resource = nil)
    added_roles = []
    accounts.each{|account|
      role = account.roles.find_by_name(:admin)
      if !roles.include?(role)
        self.class.define_dynamic_method(role_name, resource) if Rolify.dynamic_shortcuts
        self.class.adapter.add(self, role)
        added_roles << role
      end
    }

    added_roles
  end

end
