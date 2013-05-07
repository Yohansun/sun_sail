# -*- encoding:utf-8 -*-
class CategoryProperty < ActiveRecord::Base

  include MagicEnum

  enum_attr :value_type,[["单选",1],["多选",2],["输入",3]]
  enum_attr :status,[["启用",1],["禁用",0]]

  attr_accessor :value_text
  attr_accessible :name, :status, :value_type, :value_text, :values_attributes
  
  has_many    :values,    :class_name=>"CategoryPropertyValue", :dependent=>:destroy
  accepts_nested_attributes_for :values, :allow_destroy => true
  
  
  before_save :init_values
  
  def value_text
    @value_text ||= values.map(&:value)*"\n"
  end
  
  def init_values
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
