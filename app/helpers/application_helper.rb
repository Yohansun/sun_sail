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

  def column_humanize(name)
    I18n.t("activerecord.attributes.#{name}")
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

  def display_icon?(control_name,name,action_names=[])
    matched = nil
    matched = params[:controller] =~ /#{control_name.is_a?(Array) ? control_name.join('|') : control_name}/
    if action_names.present?
      matched = matched && params[:action] =~ /#{action_names.is_a?(Array) ? action_names.join('|') : action_names}/
    end
    matched ? name : "icon-plus"
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

  def nested_user_categories_options(append_item = [], skip_item = nil)
    unless skip_item.nil? || skip_item.is_a?(Category)
      skip_item = Category.find_by_id(skip_item.to_i)
    end
    append_item + nested_set_options(current_account.categories, skip_item){|i| "#{'-' * i.level}#{i.name}" }
  end

  def flash_message
    if flash[:error].present?
      content_tag :div,flash[:error],:class => "alert alert-error"
    elsif flash[:notice].present?
      content_tag :div,flash[:notice],:class => "alert alert-success"
    end
  end

  def li_tag(title, attributes = {})
    string_attributes = attributes.inject('') do |attrs, pair|
      unless pair.last.nil?
        attrs << %( #{pair.first}="#{CGI::escapeHTML(pair.last.to_s)}")
      end
      attrs
    end
    "<li#{string_attributes}>#{title}</li>"
  end

  def href_li_item(title, link_url = nil, attributes = {})
    link_url = params[:controller] if link_url.blank?
    title = %Q[<a href="/#{link_url}">#{title}</a><span class="divider">/</span>]
    li_tag(title, attributes)
  end

  def active_li_item(title, attributes = {})
    attributes = attributes.merge({:class => "active"})
    li_tag(title, {:class => "active"}.merge(attributes))
  end

  def page_brandcrumb
    items = []

    act_name = params[:action]
    case params[:controller]
    when "stocks"
      items << href_li_item("仓库管理")
      items << active_li_item("库存查询")
    when "warehouses"
      items << href_li_item("仓库管理", "stocks")
      items << active_li_item("所有仓库")
    when "stock_bills"
      items << href_li_item("仓库管理", "stocks")
      items << active_li_item("所有进销")
    when "sellers"
      items << href_li_item("经销商管理")
      items << active_li_item("经销商")
    when "areas"
      if ["sellers", "import"].include?(act_name)
        items << href_li_item("经销商管理", "sellers")
        active_li_item("地区经销商")
      else
        active_li_item("经销商管理")
      end
    when "refund_products"
      items << href_li_item("仓库管理", "stocks")
      items << case act_name
        when "new", "create"
          active_li_item("新建退货单")
        when "edit", "update"
          active_li_item("编辑退货单")
        else
          active_li_item("退货单")
        end
    when "stock_in_bills"
      items << href_li_item("仓库管理", "stocks")
      items << case act_name
        when "new", "create"
          active_li_item("新建入库单")
        when "edit", "update"
          active_li_item("编辑入库单")
        else
          active_li_item("入库单")
        end
    when "stock_out_bills"
      items << href_li_item("仓库管理", "stocks")
      items << case act_name
        when "new", "create"
          active_li_item("新建出库单")
        when "edit", "update"
          active_li_item("编辑出库单")
        else
          active_li_item("出库单")
        end
    when "stock_csv_files"
      items << href_li_item("仓库管理", "stocks")
      items << active_li_item("库存导入")
    when "products"
      items << href_li_item("商品管理")
      case act_name
      when "taobao_products"
        items <<  active_li_item("淘宝商品")
      when "taobao_product"
        items << href_li_item("淘宝商品", "products/taobao_products")
        items <<  active_li_item(@product.name)
      when "edit", "update"
        items << href_li_item("本地商品")
        items <<  active_li_item("编辑商品")
      when "import", "import_csv"
        items << href_li_item("本地商品")
        items <<  active_li_item("导入商品")
      when "new", "create"
        items << href_li_item("本地商品")
        items <<  active_li_item("新增商品")
      when "show"
        items << href_li_item("本地商品")
        title = @product.present? ? @product.name : "查看商品"
        items <<  active_li_item(title)
      when "sync_taobao_products"
        items <<  active_li_item("同步淘宝商品")
      else
        items <<  active_li_item("本地商品")
      end
    when "jingdong_products"
      items << href_li_item("商品管理")
      case act_name
      when "show"
        items << href_li_item("京东商品")
        title = @product.present? ? @product.title : "查看商品"
        items <<  active_li_item(title)
      when "sync"
        items << href_li_item("京东商品")
        items <<  active_li_item("同步结果")
      else
        items << active_li_item("京东商品")
      end
    when "yihaodian_products"
      items << href_li_item("商品管理")
      case act_name
      when "show"
        items << href_li_item("一号店商品")
        title = @product.present? ? @product.product_cname : "查看商品"
        items <<  active_li_item(title)
      when "sync"
        items << href_li_item("一号店商品")
        items <<  active_li_item("同步结果")
      else
        items << active_li_item("一号店商品")
      end
    when "customers"
      items << href_li_item("顾客管理")
      items <<  case act_name
                when "paid"
                  active_li_item("购买顾客")
                when "potential"
                  active_li_item("潜在顾客")
                when "around"
                  active_li_item("回头顾客")
                when "show"
                  title = @customer.present? ? @customer.name : ""
                  active_li_item(title)
                when "send_messages"
                  active_li_item("发送消息")
                else
                  active_li_item("所有顾客")
                end
    when "trade_reports"
      items << href_li_item("数据魔方", "sales/summary")
      case act_name
      when "index"
        items << active_li_item("报表下载")
      end
    when "trades"
      case act_name
      when "my_alerts"
        items << active_li_item("我的异常订单")
      end
    when "reconcile_statements"
      items << href_li_item("财务管理", "reconcile_statements")
      items << active_li_item("运营商对账")
    when "custom_trades"
      items << href_li_item("订单管理", "app#trades")
      case act_name
      when "new"
        items << active_li_item("新增订单")
      when "edit"
        items << active_li_item("编辑订单")
      end
    when "sales"
      items << href_li_item("数据魔方", "sales/summary")
      if ["summary", "product_analysis", "show", "edit"].include?(act_name)
        items << href_li_item("销售分析", "sales/summary")
        case act_name
        when "summary"
          items << active_li_item("概要")
        when "product_analysis"
          items << active_li_item("热销产品分析")
        when "show"
          sale_name = if @sale.present?
                    @sale.name
                  else
                    ""
                  end
          items << active_li_item("实时销售#{sale_name}")
          items << li_tag(link_to('设定', edit_sale_path), style: "position:absolute;right:30px;top:66px;")
        when "edit"
          sale_name = if @sale.present?
                    @sale.name
                  else
                    ""
                  end
          items << active_li_item("实时销售#{sale_name}")
        end
      elsif act_name =~ /_analysis$/
        items <<  href_li_item("买家分析", "sales/area_analysis")
        items <<  case act_name
                  when "area_analysis"
                    active_li_item("买家地域分析")
                  when "time_analysis"
                    active_li_item("购买时段分析")
                  when "price_analysis"
                    active_li_item("商品标价分析")
                  when "frequency_analysis"
                    active_li_item("购买频次分析")
                  when "univalent_analysis"
                    active_li_item("客单价分析")
                  end
      end
    when "users"
      case act_name
      when "sale_areas"
        items <<  active_li_item("绑定区域")
      end
    when "registrations"
      case act_name
      when "edit"
        items <<  active_li_item("个人设置")
      end
    end
    seller_name = Seller.find_by_id(params[:warehouse_id]).name if params[:warehouse_id]
    case seller_name
    when "gnc雍恒天猫专卖店"
      items.insert(1, href_li_item("gnc雍恒天猫专卖店", "warehouses/#{params[:warehouse_id]}/stock_in_bills"))
    when "gnc雍恒京东专卖店"
      items.insert(1, href_li_item("gnc雍恒京东专卖店", "warehouses/#{params[:warehouse_id]}/stock_in_bills"))
    when "gnc雍恒一号店专卖店"
      items.insert(1, href_li_item("gnc雍恒一号店专卖店","warehouses/#{params[:warehouse_id]}/stock_in_bills"))
    end
    items.join("")
  end
end