# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: roles
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)
#  resource_id   :integer(4)
#  resource_type :string(255)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true

  scopify

  def role_s
    case name
    when 'admin'
      '系统管理员'
    when 'seller'
      '经销商'
    when 'cs'
      '客服'
    when 'cs_read'
      '客服（只读权限）'
    when 'interface'
      '销售部联络人'
    when 'stock_admin'
      '仓库管理员'
    when 'logistic'
      '物流商'
    end
  end
end
