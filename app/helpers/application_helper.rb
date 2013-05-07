# -*- encoding : utf-8 -*-

module ApplicationHelper
  def user_stock_path
    return '#' unless current_user
    if current_user.allow_read?(:stocks)
      "/stocks"
    else
      if current_user.seller
        "/sellers/#{current_user.seller_id}/stocks"
      else
        '#'
      end
    end
  end
  
  def authorize?(control=params[:controller],act=params[:action])
    current_user.allowed_to?(control,act)
  end
  
  def l_or_humanize(s, options={})
    k = "#{options[:prefix]}#{s}".to_sym
    ::I18n.t(k, :default => s.to_s.humanize)
  end

  def top_nav_name
    case controller_name
    when 'stocks'
      '仓库管理'
    when 'sellers'
      '经销商管理'
    when 'products'
      '商品管理'
    when 'logistics', 'users', 'areas', 'account_setups'
      '系统设置'
    else
      ''
    end
  end
  
  def breadcrumb
    @breadcrumb ||= [['Magic', root_path]]
    @breadcrumb
  end
end
