# -*- encoding:utf-8 -*-
require "csv"
desc "更新经销商管辖地区"
task :update_seller_for_area => :environment do
  CSV.foreach("#{Rails.root}/lib/data_source/seller_for_area_20121109.csv") do |row|
    state = row[0]
    city = row[1]
    dist = row[2]
    area = get_area(state, city, dist)

    if area.blank?
      puts "#{state}--#{city}--#{dist}"
      next
    end

    leaves = area.leaves || []
    leaves << area if leaves.blank?

    seller = Seller.find_by_name row[3]

    unless seller
      puts row[3] + 'not found'
      next
    end

    leaves.each do |l|
      l.seller_ids = [seller.id]
      logistic = Logistic.find_by_name row[4]
      l.logistics = [logistic]
      l.save
    end
  end
end

def get_area(state, city, dist)
  state = Area.find_by_name state

  return unless state

  if city == '*'
    return state
  end

  city = state.children.where(name: city).first

  return unless state

  if dist == '*'
    return city
  end

  city.children.where(name: dist).first
end
