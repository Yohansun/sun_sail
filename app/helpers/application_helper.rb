# -*- encoding : utf-8 -*-

module ApplicationHelper
  def user_stock_path
    return '#' unless current_user
    if current_user.has_role? :admin
      "/stocks"
    else
      if current_user.seller
        "/sellers/#{current_user.seller_id}/stocks"
      else
        '#'
      end
    end
  end

  def top_nav_name
    case controller_name
    when 'stocks'
      '仓库管理'
    when 'sellers'
      '经销商管理'
    when 'products'
      '商品管理'
    when 'logistics', 'users', 'areas'
      '系统设置'
    else
      ''
    end
  end
end