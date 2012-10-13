# encoding : utf-8 -*-
desc "设置多乐士经销商数据"
task :fill_data_for_dulux => :environment do
  Seller.update_all(performance_score: 10, email: 'magic-notifer@networking.io', mobile: '13564675757')

  seller = Seller.find_by_name '多乐士经销商'
  return unless seller
  seller.update_attribute('performance_score', 8)

  p "经销商总数：#{Seller.count}"
  p "绩效10总数：#{Seller.where(performance_score: 10).count}"
  p "绩效8总数：#{Seller.where(performance_score: 8).count}"
  p "-------------------------------------------------"
  p "邮箱正确：#{Seller.where(email: 'magic-notifer@networking.io').count}"
  p "手机正确：#{Seller.where(mobile: '13564675757').count}"
end
