# encoding: utf-8
desc "重新绑定经销商"
task :reset_area_sellers => :environment do

  account = Account.find_by_name("多乐士官方旗舰店")
  p "删除所有经销商地域绑定数据"
  account.sellers.each do |seller|
    seller.sellers_areas.delete_all
  end

  p "---------------------------truncate logistic_areas----------------------------"
  p "清空地域"
  ActiveRecord::Base.connection.execute('truncate areas;')
  p "生成地域"
  Area.sync_from_taobao(account.taobao_sources.first.id)
  p "------------------------------------------------------------------------------"

  p "绑定所有针对三级经销区域"
  index = 0
  CSV.foreach("#{Rails.root}/lib/tasks/dulux/seller_area_relation_20140224.csv") do |row|
    index += 1
    next if index <= 2
    next if row[8] == "是"
    seller_name = row[6]
    state = row[0]
    city = row[2]
    district = row[4]

    if row[4].present?
      area = get_area(state, city, district)
      if area.blank?
        p state.to_s + "," + city.to_s + "," + district.to_s
      else
        seller = Seller.find_by_name(seller_name)
        if seller
          area.seller_ids |= [seller.id]
          area.save!
          p area.name + " 绑定 " + seller_name
        else
          p "#{seller_name} 经销商不存在！"
        end
      end
    end
  end

  p "绑定所有的省"
  index = 0
  CSV.foreach("#{Rails.root}/lib/tasks/dulux/seller_area_relation_20140224.csv") do |row|
    index += 1
    next if index <= 2
    next if row[8] == "是"
    seller_name = row[6]
    state = row[0]
    city = row[2]
    district = row[4]

    if row[4].blank?
      area = get_leaves(state, city, district)
      if area.blank?
        p state.to_s + "," + city.to_s + "," + district.to_s
      else
        leaves = area.leaves || []
        leaves << area if leaves.blank?
        seller = Seller.find_by_name(seller_name)
        if seller
          leaves.each do |leave|
            leave.seller_ids |= [seller.id]
            leave.save!
            p leave.name + " 绑定 " + seller_name
          end
        else
          p "#{seller_name} 经销商不存在！"
        end
      end
    end
    index += 1
  end
end

def get_leaves(state, city, dist)
  state = Area.find_by_name state

  return unless state

  if city.blank?
    return state
  end

  city = state.children.where(name: city).first

  return unless city

  if dist.blank?
    return city
  end

  city.children.where(name: dist).first
end