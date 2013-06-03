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
#  permissions   :text
#  account_id    :integer(4)      not null
#

class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true
  belongs_to :account
#  validates :byname ,:presence => true  ,:uniqueness => {:if => proc {|attr| Role.exists?(:byname => attr['byname'] ,:account_id => attr[:account_id])} }
#  validates :name   ,:presence => true  ,:uniqueness => {:if => proc {|attr| Role.exists?(:name   => attr['name']   ,:account_id => attr[:account_id])} }
  validates :name   ,:presence => true ,:uniqueness => {:scope => :account_id}
  validates :account_id,:presence => true
  attr_accessible :name
  serialize :permissions, Hash
  
  
  def add_all_permissions
    per =  Hash.new {|k,v| k[v] = []}
    MagicOrder::AccessControl.permissions.group_by{|x| x.project_module}.each do |project_name,permissions| 
      permissions.each do |permission|
        permission.actions.each do |action|
          per[project_name.to_s] << action
        end
      end
    end
    self.permissions = per
    self.save!
  end


  def role_s
    case name
    when 'super_admin'
      '超级管理员'
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
      '物流公司'
    end
  end
end
