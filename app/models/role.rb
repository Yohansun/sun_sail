#-*- encoding :utf-8 -*-

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