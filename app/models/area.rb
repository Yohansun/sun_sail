# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: areas
#
#  id             :integer(4)      not null, primary key
#  name           :string(255)
#  parent_id      :integer(4)
#  seller_id      :integer(4)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  active         :boolean(1)      default(TRUE)
#  is_1568        :boolean(1)      default(FALSE)
#  pinyin         :string(255)
#  children_count :integer(4)      default(0)
#  lft            :integer(4)      default(0)
#  rgt            :integer(4)      default(0)
#  sellers_count  :integer(4)      default(0)
#  area_type      :integer(4)
#  zip            :string(255)
#

require 'hz2py'

class Area < ActiveRecord::Base
  acts_as_nested_set counter_cache: :children_count
  attr_accessible :parent_id, :name, :is_1568, :area_type, :zip

  has_many :areas, foreign_key: :parent_id
  has_many :sellers_areas
  has_many :logistic_areas
  has_many :onsite_service_areas
  has_many :sellers, through: :sellers_areas
  has_many :logistics, through: :logistic_areas
  #Area.rebot(省ID,[市ID])
  #Area.rebot(3198,[3213]) or Area.rebot(3198)
  scope :robot, ->(s,q=[]) { where("parent_id in (?)",q.or(select(:id).where(:parent_id => s))) }

  before_save :set_pinyin

  def set_pinyin
    self.pinyin = Hz2py.do(name).split(" ").map { |name| name[0, 1] }.join
  end

  def onsite_service_areas(account_id)
    OnsiteServiceArea.where(area_id: leaves_areas, account_id: account_id)
  end

  def leaves_areas
    descendants.leaves
  end

  #查询卖家地址库
  def self.seller_address
    response = TaobaoQuery.get({
      method: "taobao.logistics.address.search",
      fields: 'addresses'},nil
    )
#    p response
  end

  def self.sync_from_taobao(trade_source_id)
    Area.skip_callback :save
    response = TaobaoQuery.get({
      method: "taobao.areas.get",
      fields: 'id, type, name, parent_id, zip'},trade_source_id
    )

    areas = response['areas_get_response']['areas']['area']
    2.times do
      areas.each do |taobao_area|
        next if taobao_area['parent_id'] == 0
        area = Area.find_by_id(taobao_area['id'].to_i) rescue nil
        if area
          next if Area.find_by_id(taobao_area['parent_id']).blank?
          area.area_type = taobao_area['type']
          area.parent_id = taobao_area['parent_id']
          area.zip = taobao_area['zip']
          area.name = taobao_area['name']
          area.save
        else
          next if taobao_area['parent_id'] > 1 && taobao_area['parent_id'] < 100000
          area = Area.new(
            name: taobao_area['name'],
            area_type: taobao_area['type'],
            zip: taobao_area['zip']
          )
          area.id = taobao_area['id']
          area.save
        end
      end
    end
    Area.rebuild!
  end

  def self.sync_seller_ids
    lines = open(File.join(Rails.root, 'tmp', 'areas.csv')).readlines.map { |e| e.strip.split(",") }
    lines.each do |row|
      city = row[1]
      if city.size < 3 && city[1] != '市'
        city = city + '市'
      end
      parent = Area.find_by_name city
      area = parent.areas.where(name: row[0]).first
      area.seller_id = row[2]
      area.save
    end
  end

  def fullname
    "#{parent.try(:parent).try(:name)} #{parent.try(:name)} #{name}"
  end

  def self.confirm_import_from_csv(account, file_name, set_interface_only)
    skip_lines_count = 3
    CSV.foreach(file_name, encoding: "UTF-8") do |csv|
      skip_lines_count -= 1
      next if skip_lines_count > 0
      next if csv.size == 0

      state_name = csv[0].try(:strip)
      city_name = csv[1].try(:strip)
      district_name = csv[2].try(:strip)
      seller_name = csv[3].try(:strip).try(:split, ';') || []

      state = Area.roots.find_by_name(state_name) if state_name.present?
      city = state.children.find_by_name(city_name) if city_name.present?
      district = city.children.find_by_name(district_name) if district_name.present?

      area = district || city || state

      seller = account.sellers.where(name: seller_name).first

      if area && seller && !areas.sellers.inlcude?(seller)
        area.sellers += [seller]
      end
    end
  end

  def self.import_from_csv(account, file_name)
    status_list = {}
    skip_lines_count = 3
    CSV.foreach(file_name, encoding: "UTF-8") do |csv|
      skip_lines_count -= 1
      next if skip_lines_count > 0
      next if csv.size == 0

      state_name = csv[0].try(:strip)
      city_name = csv[1].try(:strip)
      district_name = csv[2].try(:strip)
      seller_name_array = csv[3].try(:strip).try(:split, ';') || []

      state = Area.roots.find_by_name(state_name) if state_name.present?
      city = state.children.find_by_name(city_name) if state.present?
      district = city.children.find_by_name(district_name) if city.present?

      area = district || city || state
      area_name = "#{state_name}#{city_name}#{district_name}"
      status_list[area_name] = []

      if area
        original_seller_names = area.sellers.where(account_id: account.id).map(&:name)
      else
        original_seller_names = []
      end

      if (original_seller_names - seller_name_array) != (seller_name_array - original_seller_names)
        status_list[area_name] << "经销商: 修改前#{original_seller_names || '不存在'},修改后#{(seller_name_array == ['未设定'] || seller_name_array == []) ? '不存在' : seller_name_array}"
      end

      seller_name_array.each do |seller_name|
        seller = account.sellers.where(name: seller_name)
        unless seller
          status_list[area_name] << "经销商不存在: #{seller_name}"
        end
      end

      if state
        if city
          unless district
            status_list[area_name] << "地区不存在: #{area_name}"
          end
        else
          status_list[area_name] << "地区不存在: #{state_name}#{city_name}"
        end
      else
        status_list[area_name] << "地区不存在: #{state_name}"
      end
    end
    status_list
  end
end
