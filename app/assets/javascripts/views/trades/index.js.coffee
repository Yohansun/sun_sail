class MagicOrders.Views.TradesIndex extends Backbone.View

  template: JST['trades/index']

  events:
    'click .export_orders': 'exportOrders'
    'click [data-trade-status]': 'selectSameStatusTrade'
    'click .print_delivers': 'printDelivers'
    'click .print_logistics': 'printLogistics'
    'click .return_logistics': 'returnLogistics'
    'click .batch_deliver': 'batchDeliver'
    'click .batch_check_goods': 'batchCheckGoods'
    'click .confirm_batch_deliver': 'confirmBatchDeliver'
    'click .deliver_bills li' : 'gotoDeliverBills'
    'click .index_pops li a[data-type]': 'show_type'

    # 加载更多订单相关
    'click [data-type=loadMoreTrades]': 'forceLoadMoreTrades'

    # 搜索相关
    'click .search': 'search'

    # index显示相关
    'click #checkbox_all': 'optAll'
    'click #cols_filter input,label': 'keepColsFilterDropdownOpen'
    'click .dropdown': 'dropdownTurnGray'
    'click .btn-group': 'addBorderToTr'
    'change #cols_filter input[type=checkbox]': 'filterTradeColumns'

  initialize: ->
    @trade_type = MagicOrders.trade_type
    @identity = MagicOrders.role_key
    @offset = @collection.length
    @first_rendered = false
    @trade_number = 0

    # @collection.on("reset", @render, this)
    @collection.on("fetch", @renderUpdate, this)

  render: =>

    if !@first_rendered
      $(@el).html(@template(trades: @collection))
      #initial mode=trades
      visible_cols = MagicOrders.trade_cols_visible_modes[MagicOrders.trade_mode]
      MagicOrders.trade_cols_hidden[MagicOrders.trade_mode] = []
      if $.cookie("trade_cols_hidden_#{MagicOrders.trade_mode}")
        MagicOrders.trade_cols_hidden[MagicOrders.trade_mode] = $.cookie("trade_cols_hidden_#{MagicOrders.trade_mode}").split(',')
      for col in MagicOrders.trade_cols_keys
        if col in visible_cols
          $(@el).find("#cols_filter li[data-col=#{col}]").show()
          $(@el).find("#trades_table th[data-col=#{col}]").show()
          $(@el).find("#trades_table td[data-col=#{col}]").show()
        else
          $(@el).find("#cols_filter li[data-col=#{col}]").hide()
          $(@el).find("#trades_table th[data-col=#{col}]").hide()
          $(@el).find("#trades_table td[data-col=#{col}]").hide()

      # check column & trades_table filters
      $(@el).find("#cols_filter input[type=checkbox]").attr("checked", "checked")
      for col in MagicOrders.trade_cols_hidden[MagicOrders.trade_mode]
        $(@el).find("#cols_filter input[value=#{col}]").attr("checked", false)
        $(@el).find("#trades_table th[data-col=#{col}]").hide()
        $(@el).find("#trades_table td[data-col=#{col}]").hide()

    @first_rendered = true
    @collection.each(@appendTrade)
    $("a[rel=popover]").popover({placement: 'left', html:true})
    if MagicOrders.trade_mode != 'deliver' && MagicOrders.trade_mode != 'logistics'
      $(@el).find('#select_print_time').hide()
    if @identity == 'seller'
      $(@el).find(".trade_nav").text("未发货订单")
    if @identity == 'logistic'
      $(@el).find(".trade_nav").text("物流单")
    if @identity == 'cs' or @identity == 'admin'
      $(@el).find(".trade_nav").text("未分流")
    $(@el).find(".get_offset").html(@offset)

    if parseInt($(@el).find(".complete_offset").html()) == @offset
      if @offset == 0
        $(@el).find(".trade_count_info").append("<span id='bottom_line'><b>当前无订单</b></span>")
      else
        $(@el).find(".trade_count_info").append("<span id='bottom_line'><b>当前为最后一条订单</b></span>")
    $(@el).find('a[data-trade-mode='+MagicOrders.trade_mode+'][data-trade-status="'+MagicOrders.trade_type+'"]').parents('li').addClass('active')
    $(@el).find(".index_pops li").hide()
    for pop in MagicOrders.trade_pops[MagicOrders.trade_mode]
      if MagicOrders.role_key == 'admin'
        $(@el).find(".index_pops li [data-type=#{pop}]").parent().show()
      else
        if pop in MagicOrders.trade_pops[MagicOrders.role_key]
          $(@el).find(".index_pops li [data-type=#{pop}]").parent().show()

    $.unblockUI()
    this

  optAll: (e) ->
    if $('#checkbox_all')[0].checked
      $('.trade_check').attr('checked', 'checked')
      $('#op-toolbar .dropdown-menu').parents('div.btn-group').css('display', 'none')
      $('#op-toolbar .batch_ops').show()
    else
      $('.trade_check').removeAttr('checked')
      $('#op-toolbar .dropdown-menu').parents('div.btn-group').removeAttr('style')

  keepColsFilterDropdownOpen: (event) ->
    event.stopPropagation()

  filterTradeColumns: (event) ->
    col = event.target
    if $(col).attr("checked") == 'checked'
      $("#trades_table th[data-col=#{$(col).val()}],td[data-col=#{$(col).val()}]").show()
      MagicOrders.trade_cols_hidden[MagicOrders.trade_mode] = _.without(MagicOrders.trade_cols_hidden[MagicOrders.trade_mode], $(col).val())
    else
      $("#trades_table th[data-col=#{$(col).val()}],td[data-col=#{$(col).val()}]").hide()
      MagicOrders.trade_cols_hidden[MagicOrders.trade_mode].push($(col).val())

    MagicOrders.trade_cols_hidden[MagicOrders.trade_mode] = _.uniq(MagicOrders.trade_cols_hidden[MagicOrders.trade_mode])
    $.cookie("trade_cols_hidden_#{MagicOrders.trade_mode}", MagicOrders.trade_cols_hidden[MagicOrders.trade_mode].join(","))

  show_type: (e) ->
    e.preventDefault()
    length = $('.trade_check:checked').parents('tr').length
    if length <= 1
      if length == 1
        trade_id = $('.trade_check:checked').parents('tr').attr('id').slice(6)
        type = $(e.target).data('type')
        MagicOrders.cache_trade_number = parseInt($('.trade_check:checked').parents('tr').children('td:first').html())
        Backbone.history.navigate('trades/' + trade_id + "/#{type}", true)
      else
        alert("请勾选要操作的订单。")

  batchCheckGoods: (e) ->
    e.preventDefault()
    length = $('.trade_check:checked').parents('tr').length
    if length < 1
      alert("请勾选要操作的订单。")
    else
      Backbone.history.navigate('trades/batch_check_goods', true)

  fetchMoreTrades: (event, direction) =>
    if direction == 'down'
      @forceLoadMoreTrades(event)

  dropdownTurnGray: (e) ->
    e.preventDefault()
    $click_li_dropdown = $("#overview").find("li.dropdown li")
    $click_li_dropdown.click ->
      $(this).parents(".dropdown").siblings().removeClass "active"
      $(this).parents(".dropdown").addClass "active"

  exportOrders: (e) =>
    e.preventDefault()

    search_hash = {}

    simple_search_option = $('.search_option').children('option:selected').val()
    simple_search_value = $(".search_value").val()
    search_logistic = $(".search_logistic").val()

    if simple_search_option != ''
      if simple_search_option == 'logistic_name'
        search_hash[simple_search_option] = search_logistic
      else
        if simple_search_value != ''
          search_hash[simple_search_option] = simple_search_value

    length = $('.search_tags_group').children().find('input').length
    if length != 0
      for num in [0..(length-1)]
        name = $('.search_tags_group').find("input:eq("+num+")").attr('name')
        value = $('.search_tags_group').find("input:eq("+num+")").val()
        search_hash[name] = value

    if @trade_type == "default"
      type_cache = "undispatched"
    else
      type_cache = @trade_type

    $('.export_orders').addClass('export_orders_disabled disabled').removeClass('export_orders')
    $.get("/api/trades/export", {trade_type: type_cache, search: search_hash})

  selectSameStatusTrade: (e) =>
    e.preventDefault()
    $('.dropdown.open .dropdown-toggle').dropdown('toggle')
    @search_trade_status = $(e.target).data('trade-status')
    MagicOrders.trade_mode = $(e.target).data('trade-mode')
    status = $(e.target).data('trade-status')
    Backbone.history.navigate("#{MagicOrders.trade_mode}/" + "#{MagicOrders.trade_mode}-#{status}", true)

    MagicOrders.original_path = window.location.hash

    # 发货单打印时间筛选框只在deliver模式下显示
    if MagicOrders.trade_mode == 'deliver' || MagicOrders.trade_mode == 'logistics'
      $(@el).find('#select_print_time').show()
    else
      $(@el).find('#select_print_time').hide()

    # reset operation
    $(@el).find(".trade_pops li").hide()
    for pop in MagicOrders.trade_pops[MagicOrders.trade_mode]
      unless MagicOrders.role_key == 'admin'
        if pop in MagicOrders.trade_pops[MagicOrders.role_key]
          $(@el).find(".trade_pops li [data-type=#{pop}]").parent().show()
      else
        $(@el).find(".trade_pops li [data-type=#{pop}]").parent().show()

  printDelivers: ->
    tmp = []
    length = $('.trade_check:checked').parents('tr').length

    if length < 1
      alert('未选择订单！')
      return

    if length > 300
      alert('请选择小于300个订单！')
      return

    $('.trade_check:checked').parents('tr').each (index, el) ->
      input = $(el).find('.trade_check')
      a = input[0]

      if a.checked
        trade_id = $(el).attr('id').replace('trade_', '')
        tmp.push trade_id

    MagicOrders.idCarrier = tmp

    $.get '/trades/deliver_list', {ids: tmp}, (data) ->
      html = ''
      for trade in data
        html += '<tr>'
        html += '<td>' + trade.tid + '</td>'
        html += '<td>' + trade.name + '</td>'
        html += '<td>' + trade.address + '</td></tr>'


      bind_swf(tmp, 'ffd', '')
      $('#logistic_select').hide()
      $('.deliver_count').html(data.length)
      $('#print_delivers_tbody').html(html)
      $('#print_delivers').on 'hidden', ()->
        if MagicOrders.hasPrint == true
          $.get '/trades/batch-print-deliver', {ids: MagicOrders.idCarrier}

        MagicOrders.hasPrint = false

      $('#print_delivers').modal('show')

  printLogistics: ->
    tmp = []
    logistics = {}
    length = $('.trade_check:checked').parents('tr').length

    if length < 1
      alert('未选择订单！')
      return

    if length > 300
      alert('请选择小于300个订单！')
      return

    $('.trade_check:checked').parents('tr').each (index, el) ->
      input = $(el).find('.trade_check')
      a = input[0]

      if a.checked
        trade_id = $(el).attr('id').replace('trade_', '')
        tmp.push trade_id

    MagicOrders.idCarrier = tmp

    $.get '/trades/deliver_list', {ids: tmp}, (data) ->
      html = ''
      for trade in data
        lname = trade.logistic_name
        lname = '无物流商' if lname == ''
        logistics[lname] = logistics[lname] || 0
        logistics[lname] += 1
        html += '<tr>'
        html += '<td>' + trade.tid + '</td>'
        html += '<td>' + trade.name + '</td>'
        html += '<td>' + trade.address + '</td></tr>'

      $.get '/logistics/logistic_templates', {}, (t_data)->
        html_options = ''
        for item in t_data
          html_options += '<option lid="' + item.id + '" value="' + item.xml + '">' + item.name + '</option>'

        $('#logistic_select').html(html_options)
        $('#logistic_select').show()
        bind_swf(tmp, 'kdd', $('#logistic_select').val())
        $('.deliver_count').html(data.length)
        $('#print_delivers_tbody').html(html)
        $('#print_delivers').on 'hidden', ()->
          if MagicOrders.hasPrint == true
            $.get '/trades/batch-print-logistic', {ids: MagicOrders.idCarrier, logistic: $("#logistic_select").find("option:selected").attr('lid')}

          MagicOrders.hasPrint = false

        flag = true
        notice = '其中'
        for key, value of logistics
          notice += key + value + '单， '
          flag = false if value == 20

        $('#print_delivers .notice').html(notice) if flag = true
        $('#print_delivers').modal('show')

  returnLogistics: ->
    tmp = []
    length = $('.trade_check:checked').parents('tr').length

    if length < 1
      alert('未选择订单！')
      return

    if length > 300
      alert('请选择小于300个订单！')
      return

    $('.trade_check:checked').parents('tr').each (index, el) ->
      input = $(el).find('.trade_check')
      a = input[0]

      if a.checked
        trade_id = $(el).attr('id').replace('trade_', '')
        tmp.push trade_id
    $('.logistic_count').html(length)
    MagicOrders.idCarrier = tmp

    logistics = {}
    $.get '/trades/deliver_list', {ids: tmp}, (data) ->
      for trade in data
        lname = trade.logistic_name
        lname = '无物流商' if lname == ''
        logistics[lname] = logistics[lname] || 0
        logistics[lname] += 1

      flag = ''
      notice = '其中'
      for key, value of logistics
        notice += key + value + '单'
        flag = key if value == tmp.length

      $.get '/logistics/logistic_templates', {type: 'all'}, (t_data)->
        html_options = ''
        for item in t_data
          html_options += '<option lid="' + item.id + '" value="' + item.xml + '">' + item.name + '</option>'

        $('#ord_logistics_billnum_mult .logistic_select').html(html_options)

        if flag == ''
          $('#ord_logistics_billnum_mult .info').html(notice)
        else
          $("#ord_logistics_billnum_mult option:contains('" + flag + "')").attr('selected', 'selected')

        $('#ord_logistics_billnum_mult').modal('show')

  batchDeliver: ->
    tmp = []
    length = $('.trade_check:checked').parents('tr').length

    if length < 1
      alert('未选择订单！')
      return

    if length > 300
      alert('请选择小于300个订单！')
      return

    $('.trade_check:checked').parents('tr').each (index, el) ->
      input = $(el).find('.trade_check')
      a = input[0]

      if a.checked
        trade_id = $(el).attr('id').replace('trade_', '')
        tmp.push trade_id

    MagicOrders.idCarrier = tmp
    flag = true
    $.get '/trades/deliver_list', {ids: tmp}, (data) ->
      html = ''
      for trade in data
        html += '<tr>'
        html += '<td>' + trade.tid + '</td>'
        html += "<td>#{trade.receiver_name}</td>"
        html += "<td>#{trade.receiver_state + trade.receiver_city + trade.receiver_district + trade.receiver_address}</td>"
        html += "<td>#{trade.logistic_name || ''}</td>"
        html += "<td>#{trade.logistic_waybill || ''}</td></tr>"
        flag = false if trade.logistic_name == null or trade.logistic_waybill == null

      $('.deliver_count').html(data.length)
      $('#batch_deliver tbody').html(html)
      unless flag == true
        $('#batch_deliver').on "shown", ()->
          alert('部份订单无物流信息，无法发货')

        $('#batch_deliver .confirm_batch_deliver').hide()
      else
        $('#batch_deliver .confirm_batch_deliver').show()

      $('#batch_deliver').modal('show')

  confirmBatchDeliver: ->
    $.get '/trades/batch_deliver', {ids: MagicOrders.idCarrier}, (data)->
      if data.isSuccess == true
        for id in MagicOrders.idCarrier
          model = new MagicOrders.Models.Trade(id: id)
          model.fetch success: (model, response) =>
            view = new MagicOrders.Views.TradesRow(model: model)
            $("#trade_#{model.get('id')}").replaceWith(view.render().el)
            $("a[rel=popover]").popover({placement: 'left', html:true})
        $('#batch_deliver').modal('hide')
      else
        alert('失败')

  gotoDeliverBills: ->
    Backbone.history.navigate('deliver_bills', true)

  addBorderToTr: (e)->
    e.preventDefault();
    $('tr').removeClass('notice_tr')
    $(e.target).parents('tr').addClass('notice_tr')

  # 新订单提醒
  renderNew: =>
    @collection.each(@prependTrade)
    $("a[rel=popover]").popover({placement: 'left', html:true})
    $.unblockUI()

  fetch_new_trades: =>
    @collection.fetch add: true, data: {trade_type: @trade_type, offset: 0, limit: $("#newTradesNotifer span").text()}, success: (collection) =>
      @renderNew()
      $("#newTradesNotifer").hide()

  prependTrade: (trade) =>
    if $("#trade_#{trade.get('id')}").length == 0
      MagicOrders.cache_trade_number = 0
      @trade_number += 1
      view = new MagicOrders.Views.TradesRow(model: trade)
      $(@el).find("#trade_rows").prepend(view.render().el)
      $(@el).find("#trade_#{trade.get('id')} td:first").html("#{@trade_number}")

  # 加载更多订单
  forceLoadMoreTrades: (e) =>
    e.preventDefault()
    blocktheui()

    MagicOrders.trade_reload_limit = parseInt $('#load_count').val()
    @collection.fetch data: {trade_type: @trade_type, limit: MagicOrders.trade_reload_limit, offset: @offset, search: @search_hash}, success: (collection) =>
      if collection.length >= 0
        @offset = @offset + MagicOrders.trade_reload_limit
        @renderUpdate()
        $(e.target).val('')
      else
        $.unblockUI()

  renderUpdate: =>
    @collection.each(@appendTrade)

    if @collection.length > 0
      $(".complete_offset").html(@collection.at(0).get("trades_count"))
      unless parseInt($(".complete_offset").html()) <= @offset
        $(".get_offset").html(@offset)
      else
        $(".get_offset").html($(".complete_offset").html())

      $("a[rel=popover]").popover({placement: 'left', html:true})

    $.unblockUI()

  appendTrade: (trade) =>
    if $("#trade_#{trade.get('id')}").length == 0
      MagicOrders.cache_trade_number = 0
      @trade_number += 1
      view = new MagicOrders.Views.TradesRow(model: trade)
      $(@el).find("#trade_rows").append(view.render().el)
      $(@el).find("#trade_#{trade.get('id')} td:first").html("#{@trade_number}")

  search: (e) ->
    e.preventDefault()

    @search_hash = {}
    @simple_search_option = $('.search_option').children('option:selected').val()
    @simple_search_value = $(".search_value").val()
    @search_logistic = $(".search_logistic").val()

    if @simple_search_option != ''
      if @simple_search_option == 'logistic_name'
        @search_hash[@simple_search_option] = @search_logistic
      else
        if @simple_search_value != ''
          @search_hash[@simple_search_option] = @simple_search_value

    length = $('.search_tags_group').children().find('input').length
    if length != 0
      for num in [0..(length-1)]
        name = $('.search_tags_group').find("input:eq("+num+")").attr('name')
        value = $('.search_tags_group').find("input:eq("+num+")").val()
        @search_hash[name] = value

    @offset = 0
    blocktheui()
    $("#trade_rows").html('')

    if @trade_type == "default"
      MagicOrders.trade_type = "undispatched"
      @trade_type = "undispatched"

    @collection.fetch data: {trade_type: @trade_type, search: @search_hash}, success: (collection) =>
      if collection.length > 0
        @offset = @offset + 20
        @trade_number = 0
        @renderUpdate()

      if collection.length == 0
        $(@el).find(".get_offset").html(@offset)
        $(@el).find(".complete_offset").html("0")
        $.unblockUI()
      else
        $.unblockUI()