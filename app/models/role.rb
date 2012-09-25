#-*- encoding :utf-8 -*-

class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true
  
  scopify

  def role_s
    case name
    when 'admin'
      '管理员'
    when 'seller'
      '经销商'
	  when 'support'
	  	'售后服务'
	  when 'interface'
	  	'销售部联络人'
	  when 'stock_admin'
	  	'仓库管理'
    end
  end
end
