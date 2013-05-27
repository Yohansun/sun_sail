# -*- encoding:utf-8 -*-
require "csv"

desc "给地区匹配物流公司"
task :add_logistic_to_areas => :environment do
  CSV.foreach "#{Rails.root}/lib/data_source/logic_to_areas_20121022.csv" do |row|
    state = row[0]
    city = row[1]
    dist = row[2]

    # logistic = Logistic.find 5
    area = get_area(state, city, dist)

    if area.blank?
      puts "#{state}--#{city}--#{dist}"
      next
    end

    leaves = area.leaves || []
    leaves << area if leaves.blank?

    leaves.each do |leaf|
      leaf.logistic_ids = [5]
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
