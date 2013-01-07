# -*- encoding:utf-8 -*-

module NioHelper
	
	# = Nio code helper
	# 提供一些公用方法
	def readable_color(colors)
		tmp = {}
		result = ''
    colors.flatten.each do |color|
      next if color.blank?

      if tmp.has_key? color
        tmp["#{color}"][0] += 1
      else
        tmp["#{color}"] = [1, Color.find_by_num(color).try(:name)]
      end
    end

    tmp.each do |key, value|
    	result << "#{value[0]}桶#{value[1]}\r\n"
    end

    result
	end
end