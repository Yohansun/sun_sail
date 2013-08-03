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

  ##Navigation Helper
  # {:用户管理 => users_path,:订单管理 => trades_path}.each do |name, url|
  # <li class="<%= current_controller?(url,:assert_true => 'active') %>"> <%= name %> </li>
  # end
  #
  # request.fullpath  => /users/1
  #
  # current_controller?("/users/1/edit")                        => true
  # current_controller?("/users/1/edit",:assert_true => "yes")  => "yes"
  # current_controller?("/trades")                              => false
  # current_controller?("/trades",:assert_false => "no")        => "no"
  def current_controller?(*args)
    options = args.extract_options!
    url = args.shift
    options[:assert_true] ||= true
    options[:assert_false] ||= false
    url_parameters = Rails.application.routes.recognize_path url
    request[:controller] == url_parameters[:controller] ? options[:assert_true] : options[:assert_false]
  end

  def current_page?(url)
    url_parameters = Rails.application.routes.recognize_path url
    (request[:controller] == url_parameters[:controller]) && (request[:action] == url_parameters[:action])
  end
  
  def format_url(var)
    url = request.fullpath
    url.include?('?') ? url.gsub('?',".#{var}?") : (url.to_s << ".#{var}?") 
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
  
  def display?(control_name,name,action_names=[])
    matched = nil
    matched = params[:controller] =~ /#{control_name.is_a?(Array) ? control_name.join('|') : control_name}/
    if action_names.present?
      matched = matched && params[:action] =~ /#{action_names.is_a?(Array) ? action_names.join('|') : action_names}/
    end
    matched ? name : ""
  end

  # Support seletor.js.coffee :target_url
  # Same as link_to syntax
  def link_to_authorize(*args,&block)
    html_options = args.second
    options = args.dup.extract_options!
    options.stringify_keys!

    if /^#/.match(html_options) && options.key?("target_url")
      html_options = options["target_url"]
    end

    if html_options.is_a?(String)
      method_id = options["request"] || :get
      html_options = Rails.application.routes.recognize_path(html_options,:method => method_id)
    end

    link_to(*args,&block) if current_user.allowed_to?(html_options[:controller],html_options[:action])
  end

  def flash_message
    if flash[:error].present?
      content_tag :div,flash[:error],:class => "alert alert-error"
    elsif flash[:notice].present?
      content_tag :div,flash[:notice],:class => "alert alert-success"
    end
  end
end
