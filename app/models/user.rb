class User < ActiveRecord::Base
  belongs_to :area
  has_one :seller
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable

  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :role_level
  # attr_accessible :title, :body

  validates_uniqueness_of :name
  validates_presence_of :name
  validates_presence_of :password, on: :create
  validates_confirmation_of :password

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
    when 15
      'cs'
    end
  end
end