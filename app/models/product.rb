# -*- encoding : utf-8 -*-

# == Schema Information
#
# Table name: products
#
#  id                :integer(4)      not null, primary key
#  name              :string(100)     default(""), not null
#  outer_id          :string(20)      default("")
#  product_id        :string(20)      default("")
#  storage_num       :string(20)      default("")
#  price             :decimal(8, 2)   default(0.0), not null
#  quantity_id       :integer(4)
#  category_id       :integer(4)
#  features          :string(255)
#  product_image     :string(255)
#  parent_id         :integer(4)
#  lft               :integer(4)      default(0)
#  rgt               :integer(4)      default(0)
#  good_type         :integer(4)
#  updated_at        :datetime
#  created_at        :datetime
#  cat_name          :string(255)
#  pic_url           :string(255)
#  detail_url        :string(255)
#  cid               :string(255)
#  num_iid           :integer(8)
#  account_id        :integer(4)
#  logistic_group_id :integer(4)
#  on_sale           :boolean(1)      default(TRUE)
#

class Product < ActiveRecord::Base
  belongs_to :account
  belongs_to :category
  has_many :skus, dependent: :destroy,:inverse_of => :product
  belongs_to :logistic_group
  has_many :feature_product_relationships, dependent: :destroy
  has_many :features, through: :feature_product_relationships
  has_many :colors_products, dependent: :destroy
  has_many :colors, through: :colors_products
  has_many :stock_products, dependent: :destroy
  accepts_nested_attributes_for :skus, :allow_destroy => true

  attr_accessible :name, :product_id, :outer_id, :storage_num, :price, :color_ids, :pic_url, :category_id, :features, :feature_ids, :cat_name, :detail_url, :num_iid, :cid, :account_id, :logistic_group_id, :on_sale,:skus_attributes

  validates :outer_id, presence: true, uniqueness: { scope: :account_id }

  validates_presence_of :name, :price, message: "信息不能为空"
  validates_numericality_of :price, message: "所填项必须为数字"
  validates_length_of :name, maximum: 100, message: "内容过长"
  scope :current_products, ->(current_account_id) { where(account_id: current_account_id) }

  def is_on_sale
    case on_sale
    when true
      "上架"
    when false
      "下架"
    end
  end

  def taobao_price
    taobao_product.try(:price)
  end

  def taobao_product
    TaobaoProduct.find_by_outer_id(outer_id) || TaobaoProduct.find_by_num_iid(num_iid)
  end

  def sku_names
    self.skus.map(&:name).join(",")
  end

  def skus_attributes
    @_skus_attributes = {}
    skus.each_with_index do |sku,index|
      @_skus_attributes.merge!({"#{index}" => sku.attributes})
    end
    @_skus_attributes
  end

  def category_property_names
    self.category.category_properties.map(&:name)*" | " if self.category
  end

   def self.confirm_import_from_csv(account, file_name)
    records = CsvMapper.import(file_name) do |csv|
      start_at_row 2
      [name, category_name, outer_id]
    end

    records.each do |record|
      if record.outer_id.present? && record.name.present?
        unless account.products.exists?(outer_id: record.outer_id)
          product = account.products.create(outer_id: record.outer_id, name: record.name)
          category = account.categories.where(name: record.category_name).first_or_create
          product.update_attributes(category_id: category.id)
          product.skus.create(account_id: account.id)
        end
      end
    end
  end

  def self.import_from_csv(account, file_name)
    records = CsvMapper.import(file_name) do |csv|
      start_at_row 2
      [name, category_name, outer_id, info, errors]
    end

    records.each do |record|
      if record.outer_id.present?
        if account.products.exists?(outer_id: record.outer_id)
          record.errors = "商品编码已存在, 跳过"
        else
          if record.name.blank?
            record.errors = "未输入商品名称, 跳过"
          else
            record.info = "正常导入"
          end
        end
      else
        record.errors = "未输入商品编码, 跳过"
      end
    end

    records
  end
end
