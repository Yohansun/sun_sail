#encoding: utf-8

# == Schema Information
#
# Table name: sellers
#
#  id                :integer(4)      not null, primary key
#  name              :string(255)
#  fullname          :string(255)
#  address           :string(255)
#  mobile            :string(255)
#  phone             :string(255)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  parent_id         :integer(4)
#  lft               :integer(4)
#  rgt               :integer(4)
#  children_count    :integer(4)      default(0)
#  email             :text
#  telephone         :string(255)
#  cc_emails         :text
#  user_id           :integer(4)
#  pinyin            :string(255)
#  active            :boolean(1)      default(TRUE)
#  performance_score :integer(4)      default(0)
#  interface         :string(255)
#  has_stock         :boolean(1)      default(FALSE)
#  stock_opened_at   :datetime
#  account_id        :integer(4)
#  stock_name        :string(255)
#  stock_user_id     :integer(4)
#  trade_type        :string(255)
#


require 'hz2py'
require 'csv'

class Seller < ActiveRecord::Base
  include FinderCache
  include MagicEnum
  acts_as_nested_set :counter_cache => :children_count
  enum_attr :has_stock, [["启用",true],["禁用",false]]

  attr_accessible :has_stock, :stock_opened_at,:mobile, :telephone, :cc_emails, :email, :pinyin, :interface, :fullname, :name,
                  :parent_id, :address, :performance_score, :user_id,:stock_name,:stock_user_id,:areas, :active, :trade_type

  has_many :users
  has_many :sellers_areas, dependent: :destroy
  has_many :areas, through: :sellers_areas
  has_many :stock_products, dependent: :destroy
  has_many :stock_csv_files, dependent: :destroy
  has_one :stock
  belongs_to :user
  belongs_to :account

  enum_attr :trade_type, [["淘宝", "Taobao"],["京东", "Jingdong"],["一号店", "Yihaodian"]]

  scope :with_account, lambda {|account_id| where(account_id: account_id)}
  scope :order_with_parent_id, order(:parent_id)

  validates :name, presence: true, uniqueness: { scope: :account_id }
  validates :trade_type, presence: true

  before_save :set_pinyin_and_stock_name

  def set_pinyin_and_stock_name
    self.pinyin = Hz2py.do(name).split(" ").map { |name| name[0, 1] }.join
    self.stock_name = self.name if self.stock_name.blank?
  end

  def interface_mobile
    self.parent.mobile if self.parent
  end

  def interface_email
    self.parent.email if self.parent
  end

  def interface_name
    self.parent.name if self.parent
  end

  def products_ids
    @products_ids = self.stock_products.select("distinct stock_products.product_id").map(&:product_id)
  end

  def categories_ids
    products_ids = self.products_ids
    if products_ids.present?
      products = Product.where("products.id in (#{products_ids.join(',')})")
      @categories_ids = products.select("distinct category_id").map(&:category_id)
    else
      @categories_ids = []
    end
  end

  def product_name(id)
    StockProduct.find_by_id(id).try(:product).try(:name)
  end

  def self.has_available_rs
    self.find_each do |seller|
      return true if seller.next_month_rs_date.present?
    end
    false
  end

  def next_month_rs_date
    return nil if (active == false || parent_id == nil)
    return nil if (latest_rs && latest_rs.audited == false)
    if latest_rs == nil
      date = 1.month.ago.beginning_of_month
    else
      date = (latest_rs.audit_time + 1.month) if (calculate_month(latest_rs.audit_time) > 1)
    end
  end

  def calculate_month(an_ordinary_day)
    if an_ordinary_day.year < Time.now.year
      return ((Time.now.year - an_ordinary_day.year)*12 + Time.now.month) - an_ordinary_day.month
    elsif an_ordinary_day.year == Time.now.year
      return Time.now.month - an_ordinary_day.month
    end
  end

  def area_name(id)
    area = Area.find_by_id(id)
    area.self_and_ancestors.map(&:name).join('-') if area
  end

  def category_count
    Category.joins(:products).joins("right join stock_products on stock_products.product_id = products.id").where("stock_products.seller_id = #{self.id}").group("categories.id").length
  end

  def self.confirm_import_from_csv(account, file_name, set_interface_only)
    skip_lines_count = 3
    CSV.foreach(file_name, encoding: "UTF-8") do |csv|
      skip_lines_count -= 1
      next if skip_lines_count > 0
      next if csv.size == 0
      name = csv[0].try(:strip)
      fullname = csv[1].try(:strip)
      usernames = csv[2].try(:strip).try(:split, ';') || []
      interface_name = csv[3].try(:strip)
      mobile = csv[4].try(:strip).try(:gsub, ';', ',')
      email = csv[5].try(:strip).try(:gsub, ';', ',')
      cc_emails = csv[6].try(:strip).try(:gsub, ';', ',')
      seller_closed = csv[7].try(:strip)

      if set_interface_only
        seller = account.sellers.find_by_name(name)
        interface = account.sellers.find_by_name(interface_name)
        if interface_name && (interface_name != '' || interface_name != '未设定' || interface_name != nil) && !interface
          interface = account.sellers.create!(name: interface_name, fullname: interface_name)
        end
        seller.update_attributes!(parent_id: interface.try(:id))
      else
        if seller_closed == "是"
          seller_active_bool = false
        elsif seller_closed == "否"
          seller_active_bool = true
        end

        seller = account.sellers.find_by_name(name)
        if seller
          seller.update_attributes!(fullname: fullname, email: email, mobile: mobile, cc_emails: cc_emails, active: seller_active_bool)
        else
          seller = account.sellers.create!(name: name, fullname: fullname, email: email, mobile: mobile, cc_emails: cc_emails, active: seller_active_bool)
        end

        if User.where(email: email).exists?
          user_email = "seller_#{account.id}_#{seller.id}_#{Time.now.to_i}@doorder.com"
        else
          user_email = email
        end

        users = []
        if usernames.present?
          usernames.each do |username|
            user = account.users.find_by_username(username)
            if username && (username != '' || username != '未设定' || username != nil) && !user
              user = account.users.create!(name: name, username: username, email: user_email, password: '123456')
            end
            users << user
          end
        end
        seller.users = users
        seller.save!
      end
    end
  end

  def self.import_from_csv(account, file_name)
    status_list = {}
    skip_lines_count = 3
    CSV.foreach(file_name, encoding: "UTF-8")do |csv|
      skip_lines_count -= 1
      next if skip_lines_count > 0
      next if csv.size == 0
      name = csv[0].try(:strip)
      fullname = csv[1].try(:strip)
      usernames = csv[2].try(:strip).try(:split, ';') || []
      interface_name = csv[3].try(:strip)
      mobile = csv[4].try(:strip).try(:gsub, ';', ',')
      email = csv[5].try(:strip).try(:gsub, ';', ',')
      cc_emails = csv[6].try(:strip).try(:gsub, ';', ',')
      seller_closed = csv[7].try(:strip)
      seller = account.sellers.find_by_name(name)
      status_list[name] = []
      if seller
        if fullname.to_s != (seller.fullname || '').to_s
          status_list[name] << "全称: 修改前#{seller.fullname || '不存在'},修改后#{fullname || '不存在'}"
        end
        if mobile.to_s != (seller.mobile || '').to_s
          status_list[name] << "手机号: 修改前#{seller.mobile || '不存在'},修改后#{mobile || '不存在'}"
        end
        if email.to_s != (seller.email || '').to_s
          status_list[name] << "邮箱: 修改前#{seller.email || '不存在'},修改后#{email || '不存在'}"
        end
        if cc_emails.to_s != (seller.cc_emails || '').to_s
          status_list[name] << "抄送邮箱: 修改前#{seller.cc_emails || '不存在'},修改后#{cc_emails || '不存在'}"
        end
        interface = account.sellers.find_by_name(interface_name)
        if interface
          if interface != seller.parent
            status_list[name] << "上级经销商: 修改前#{seller.parent.try(:name) || '不存在'},修改后#{interface_name || '不存在'}"
          end
        else
          unless interface_name.nil?
            status_list[name] << "新建上级经销商: #{interface_name}"
          end
        end
        original_usernames = seller.users.map(&:username)
        disctinct_usernames = original_usernames & usernames
        if (disctinct_usernames - original_usernames) != (original_usernames - disctinct_usernames)
          status_list[name] << "登录账号: 修改前#{original_usernames || '不存在'},修改后#{(usernames == ['未设定'] || usernames == []) ? '不存在' : usernames}"
        end
        usernames.each do |username|
          user = account.users.find_by_username(username)
          if !user && username
            status_list[name] << "新建登录账号: #{username}"
          end
        end
        if (seller_closed == "是" && seller.active) || (seller_closed == "否" && !seller.active)
          status_list[name] << "经销商是否已关闭: 修改前#{seller.active ? '否' : '是'},修改后#{seller_closed}"
        end
      else
        status_list[name] << "新建经销商: #{name}"
      end
    end
    status_list
  end
end
