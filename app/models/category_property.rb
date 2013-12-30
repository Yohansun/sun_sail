# -*- encoding:utf-8 -*-
# == Schema Information
#
# Table name: category_properties
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  value_type :integer(4)
#  taobao_id  :integer(4)
#  status     :integer(4)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  account_id :integer(4)
#


class CategoryProperty < ActiveRecord::Base

  STATUS_ENABLED = 1
  STATUS_DISABLED = 0

  VALUE_TYPE_SINGLE = 1
  VALUE_TYPE_MULTIPLE = 2
  VALUE_TYPE_INPUT = 3

  include MagicEnum

  enum_attr :value_type,[["多选",VALUE_TYPE_MULTIPLE],["单选",VALUE_TYPE_SINGLE],["文本",VALUE_TYPE_INPUT]]
  enum_attr :status,[["启用",STATUS_ENABLED],["禁用",STATUS_DISABLED]]

  attr_accessor :value_text
  attr_accessible :name, :status, :value_type, :value_text, :values_attributes

  has_many    :values,    :class_name=>"CategoryPropertyValue", :dependent=>:destroy
  accepts_nested_attributes_for :values, :allow_destroy => true


  before_save :init_values

  scope :name_eq, ->(name){ where(["category_properties.name = ?",name])}

  def value_text
    Array.wrap(values_name)*"\n"
  end

  def values_name
    @value_text ||= values.map(&:value)
  end


  # 保存属性值(CategoryPropertyValue)列表
  # 如果是文本属性值，默认values添加一条文本
  def init_values
    if value_type == 3
      self.attributes = {:values_attributes=>[{value: "文本"}]}
    else
      old_values = []
      old_values_map = {}
      values.each{|v| old_values << v.value; old_values_map[v.value] = v.id;}

      # build params hash
      lines = self.value_text.split("\n")
      values_attributes = []
      lines.each{|line|
        line.strip!
        next if line.blank?
        # set values which not changed
        if old_values.include?(line)
          values_attributes << {value: line,:id=>old_values_map[line]}
          # delete no change values
          old_values.delete(line)
        else
        # set new values
          values_attributes << {value: line}
        end
      }
      # set removed values
      old_values.each{|value|
        values_attributes << {id:old_values_map[value],_destroy:true}
      }
      self.attributes = {:values_attributes=>values_attributes}
    end
  end

end
