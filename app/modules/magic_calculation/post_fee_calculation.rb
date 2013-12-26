module MagicCalculation
  module PostFeeCalculation

    def post_fee(obj, product_weight)
      extra_weight = product_weight - obj.basic_post_weight
      if extra_weight <= 0
        return obj.basic_post_fee
      else
        begin
          return obj.basic_post_fee + extra_weight / obj.extra_post_weight * obj.extra_post_fee
        rescue ZeroDivisionError
          # 如果额外重量为0，则所有重量都按基本费用计算
          return obj.basic_post_fee
        end
      end
    end

    def area_post_fee(area, logistic, product_weight)
      logistic_area = logistic.logistic_areas.find_by_area_id(area.id)
      if logistic_area && logistic_area.has_full_post_fee_info
        return post_fee(logistic_area, product_weight)
      else
        return post_fee(logistic, product_weight)
      end
    end
  end
end