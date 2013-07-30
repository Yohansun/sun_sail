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

  def self.sync_from_taobao
    Area.skip_callback :save
    response = TaobaoQuery.get({
      method: "taobao.areas.get",
      fields: 'id, type, name, parent_id, zip'},nil
    )

    areas = response['areas_get_response']['areas']['area']
    areas.each do |taobao_area|
      taobao_area['parent_id'] = nil if taobao_area['parent_id'] == 0
      area = Area.find(taobao_area['id'].to_i)
      if area
        area.area_type = taobao_area['type']
        area.parent_id = taobao_area['parent_id']
        area.zip = taobao_area['zip']
        area.name = taobao_area['name']
        area.save
      else
        area = Area.new(name: taobao_area['name'],
          area_type: taobao_area['type'], parent_id: taobao_area['parent_id'],
          zip: taobao_area['zip'])
        area.id = taobao_area['id']
        area.save
      end
    end
    Area.rebuild!
  end

  def self.sync_seller_ids
    lines = open(File.join(Rails.root, 'tmp', 'areas.csv')).readlines.map { |e| e.strip.split(",") }
    lines.each do |row|
      city = row[1]
#      p city
#      p city.size
#      p city[1]
      if city.size < 3 && city[1] != '市'
        city = city + '市'
      end
      parent = Area.find_by_name city
      area = parent.areas.where(name: row[0]).first
      area.seller_id = row[2]
      area.save
    end
  end
end
