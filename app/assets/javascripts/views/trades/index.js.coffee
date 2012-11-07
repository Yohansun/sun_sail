class MagicOrders.Views.TradesIndex extends Backbone.View

  template: JST['trades/index']

  events:

    'click .search': 'search'
    'click [data-type=loadMoreTrades]': 'forceLoadMoreTrades'
    'click .export_orders': 'exportOrders'
    'change #cols_filter input[type=checkbox]': 'filterTradeColumns'
    'change #search_option' : 'changeInputFrame'
    'click [data-trade-status]': 'selectSameStatusTrade'
    'click #checkbox_all': 'optAll'
    'click .print_delivers': 'printDelivers'
    'click .print_logistics': 'printLogistics'
    'click .return_logistics': 'returnLogistics'
    'click .confirm_return': 'confirmReturn'
    'click .confirm_logistics': 'confirmLogistics'
    'click .batch_deliver': 'batchDeliver'
    'click .confirm_batch_deliver': 'confirmBatchDeliver'

    #visual effects
    'click #cols_filter input,label': 'keepColsFilterDropdownOpen'
    'click #advanced_btn': 'advancedSearch'
    'click .dropdown': 'dropdownTurnGray'

  initialize: ->
    @trade_type = MagicOrders.trade_type
    @identity = MagicOrders.role_key
    @offset = @collection.length
    @first_rendered = false
    @trade_number = 0

    # @collection.on("reset", @render, this)
    @collection.on("fetch", @renderUpdate, this)

  render: =>
    $.unblockUI()
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
    $("a[rel=popover]").popover(placement: 'left')
    @render_select_state()
    @render_select_print_time()
    $(@el).find("#search_logistic").hide()
    if MagicOrders.trade_mode != 'deliver' && MagicOrders.trade_mode != 'logistics'
      $(@el).find('#select_print_time').hide()
    if @identity == 'seller'
      $(@el).find(".trade_nav").text("未发货订单")
    if @identity == 'logistic'
      $(@el).find(".trade_nav").text("物流单")
    if @identity == 'cs' or @identity == 'admin'
      $(@el).find(".trade_nav").text("未分流订单")
    $(@el).find(".get_offset").html(@offset)
    if parseInt($(@el).find(".complete_offset").html()) == @offset
      if @offset == 0
        $(@el).find("#bottom_line").replaceWith("<span id='bottom_line'><b>当前无订单</b></span>")
      else
        $(@el).find("#bottom_line").replaceWith("<span id='bottom_line'><b>当前为最后一条订单</b></span>")
    this

  optAll: (e) ->
    if $('#checkbox_all')[0].checked
      $('.trade_check').attr('checked', 'checked')
    else
      $('.trade_check').removeAttr('checked')

  render_select_state: ->
    view = new MagicOrders.Views.AreasSelectState()
    $(@el).find('#select_state').html(view.render().el)

  render_select_print_time: ->
    view = new MagicOrders.Views.TradesSelectPrintTime()
    $(@el).find('#select_print_time').html(view.render().el)

  renderUpdate: =>
    if @collection.length != 0
      @collection.each(@appendTrade)
      $(".complete_offset").html(@collection.at(0).get("trades_count"))
      unless parseInt($(".complete_offset").html()) <= @offset
        $(".get_offset").html(@offset)
        $("[data-type=loadMoreTrades]").replaceWith("<a href='#' data-type='loadMoreTrades' id='bottom_line' class='btn'>加载更多订单</a>")
        $("#bottom_line").replaceWith("<a href='#' data-type='loadMoreTrades' id='bottom_line' class='btn'>加载更多订单</a>")
      else
        $(".get_offset").html($(".complete_offset").html())
        $("[data-type=loadMoreTrades]").replaceWith("<span id='bottom_line'><b>当前为最后一条订单</b></span>")
      $("a[rel=popover]").popover(placement: 'left')
    else
      $(".complete_offset").html(0)
      $(".get_offset").html(0)
      $("[data-type=loadMoreTrades]").replaceWith("<span id='bottom_line'><b>当前无订单</b></span>")
    $.unblockUI()

  appendTrade: (trade) =>
    if $("#trade_#{trade.get('id')}").length == 0
      MagicOrders.cache_trade_number = 0
      @trade_number += 1
      view = new MagicOrders.Views.TradesRow(model: trade)
      $(@el).find("#trade_rows").append(view.render().el)
      $(@el).find("#trade_#{trade.get('id')} td:first").html("#{@trade_number}")

  renderNew: =>
    @collection.each(@prependTrade)
    $("a[rel=popover]").popover(placement: 'left')
    $.unblockUI()

  prependTrade: (trade) =>
    if $("#trade_#{trade.get('id')}").length == 0
      MagicOrders.cache_trade_number = 0
      @trade_number += 1
      view = new MagicOrders.Views.TradesRow(model: trade)
      $(@el).find("#trade_rows").prepend(view.render().el)
      $(@el).find("#trade_#{trade.get('id')} td:first").html("#{@trade_number}")

  keepColsFilterDropdownOpen: (event) ->
    event.stopPropagation()

  changeInputFrame: ->
    if $(".search_option").val() == "logistic"
      $("#search_logistic").show()
      $(".search_value").hide()
    else
      $("#search_logistic").hide()
      $(".search_value").show()

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

  search: (e) ->
    e.preventDefault()

    @simple_search_option = $(".search_option").val()
    @simple_search_value = $(".search_value").val()
    @search_logistic = $("#search_logistic").val()

    @status_option = $("#status_option").val()
    @type_option = $("#type_option").val()
    @state_option = $("#state_option").val()
    @city_option = $("#city_option").val()
    @district_option = $("#district_option").val()

    @search_start_date = $(".search_start_date").val()
    @search_end_date = $(".search_end_date").val()
    @search_start_time = $(".search_start_time").val()
    @search_end_time = $(".search_end_time").val()
    @pay_start_date = $(".pay_start_date").val()
    @pay_end_date = $(".pay_end_date").val()
    @pay_start_time = $(".pay_start_time").val()
    @pay_end_time = $(".pay_end_time").val()
    @from_deliver_print_date = $("#deliver_print_start_date").val()
    @to_deliver_print_date = $("#deliver_print_end_date").val()
    @from_deliver_print_time = $("#deliver_print_start_time").val()
    @to_deliver_print_time = $("#deliver_print_end_time").val()
    @from_logistic_print_date = $("#logistic_print_start_date").val()
    @to_logistic_print_date = $("#logistic_print_end_date").val()
    @from_logistic_print_time = $("#logistic_print_start_time").val()
    @to_logistic_print_time = $("#logistic_print_end_time").val()

    @search_buyer_message = $("#search_buyer_message").is(':checked')
    @search_seller_memo = $("#search_seller_memo").is(':checked')
    @search_cs_memo = $("#search_cs_memo").is(':checked')
    @search_cs_memo_void = $("#search_cs_memo_void").is(':checked')
    @search_invoice = $("#search_invoice").is(':checked')
    @search_color = $("#search_color").is(':checked')
    @search_color_void = $("#search_color_void").is(':checked')

    return if (@search_option == '' or @search_value == '') and (@from_deliver_print_date == '' or @to_deliver_print_date == '') and (@from_logistic_print_date == '' or @to_logistic_print_date == '') and @search_logistic == '' and @status_option == "" and @state_option == "" and @city_option == "" and @district_option == "" and @type_option == "" and (@search_start_date == '' or @search_end_date == '') and (@pay_start_date == '' or @pay_end_date == '') and @search_buyer_message == false and @search_seller_memo == false and @search_cs_memo == false and @search_color == false and @search_invoice == false and @search_cs_memo_void == false and @search_color == false

    @offset = 0
    blocktheui()
    $("#trade_rows").html('')

    @collection.fetch data: {trade_type: @trade_type, search: {@simple_search_option, @simple_search_value, @from_deliver_print_date, @to_deliver_print_date, @from_deliver_print_time, @to_deliver_print_time, @from_logistic_print_date, @to_logistic_print_date, @from_logistic_print_time, @to_logistic_print_time, @search_start_date, @search_start_time, @search_end_date, @pay_start_time, @pay_end_time, @pay_start_date, @pay_end_date, @search_end_time, @status_option, @type_option, @state_option, @city_option, @district_option, @search_buyer_message, @search_seller_memo, @search_cs_memo, @search_cs_memo_void, @search_invoice, @search_color, @search_color_void, @search_logistic}}, success: (collection) =>
      if collection.length >= 0
        @offset = @offset + 20
        @trade_number = 0
        @renderUpdate()
      else
        $.unblockUI()

  fetch_new_trades: =>
    @collection.fetch add: true, data: {trade_type: @trade_type, offset: 0, limit: $("#newTradesNotifer span").text()}, success: (collection) =>
      @renderNew()
      $("#newTradesNotifer").hide()

  forceLoadMoreTrades: (event) =>
    event.preventDefault()
    blocktheui()

    @collection.fetch data: {trade_type: @trade_type, offset: @offset, search: {@simple_search_option, @simple_search_value, @from_deliver_print_date, @to_deliver_print_date, @from_deliver_print_time, @to_deliver_print_time, @from_logistic_print_date, @to_logistic_print_date, @from_logistic_print_time, @to_logistic_print_time, @search_start_date, @search_start_time, @search_end_date, @pay_start_time, @pay_end_time, @pay_start_date, @pay_end_date, @search_end_time, @status_option, @type_option, @state_option, @city_option, @district_option, @search_buyer_message, @search_seller_memo, @search_cs_memo, @search_cs_memo_void, @search_invoice, @search_color, @search_color_void, @search_logistic}}, success: (collection) =>
      if collection.length >= 0
        @offset = @offset + 20
        @renderUpdate()
      else
        $.unblockUI()

  fetchMoreTrades: (event, direction) =>
    if direction == 'down'
      @forceLoadMoreTrades(event)

  advancedSearch: (e) ->
    e.preventDefault()
    $("#search_toggle").toggle()
    $("#simple_search_button").toggleClass 'simple_search'

  dropdownTurnGray: (e) ->
    e.preventDefault()
    $click_li_dropdown = $("#overview").find("li.dropdown li")
    $click_li_dropdown.click ->
      $(this).parents(".dropdown").siblings().removeClass "active"
      $(this).parents(".dropdown").addClass "active"

  exportOrders: (e) =>
    e.preventDefault()

    @simple_search_option = $(".search_option").val()
    @simple_search_value = $(".search_value").val()

    @status_option = $("#status_option").val()
    @type_option = $("#type_option").val()
    @state_option = $("#state_option").val()
    @city_option = $("#city_option").val()
    @district_option = $("#district_option").val()

    @search_start_date = $(".search_start_date").val()
    @search_end_date = $(".search_end_date").val()
    @search_start_time = $(".search_start_time").val()
    @search_end_time = $(".search_end_time").val()
    @pay_start_date = $(".pay_start_date").val()
    @pay_end_date = $(".pay_end_date").val()
    @pay_start_time = $(".pay_start_time").val()
    @pay_end_time = $(".pay_end_time").val()
    @from_deliver_print_date = $("#deliver_print_start_date").val()
    @to_deliver_print_date = $("#deliver_print_end_date").val()
    @from_deliver_print_time = $("#deliver_print_start_time").val()
    @to_deliver_print_time = $("#deliver_print_end_time").val()
    @from_logistic_print_date = $("#logistic_print_start_date").val()
    @to_logistic_print_date = $("#logistic_print_end_date").val()
    @from_logistic_print_time = $("#logistic_print_start_time").val()
    @to_logistic_print_time = $("#logistic_print_end_time").val()

    @search_buyer_message = $("#search_buyer_message").is(':checked')
    @search_seller_memo = $("#search_seller_memo").is(':checked')
    @search_cs_memo = $("#search_cs_memo").is(':checked')
    @search_cs_memo_void = $("#search_cs_memo_void").is(':checked')
    @search_invoice = $("#search_invoice").is(':checked')
    @search_color = $("#search_color").is(':checked')
    @search_color_void = $("#search_color_void").is(':checked')

    @search_logistic = $("#search_logistic").val()
    $('.export_orders').addClass('export_orders_disabled disabled').removeClass('export_orders')
    $.get("/api/trades/export?trade_type=#{@trade_type}&search%5Bsimple_search_option%5D=#{@simple_search_option}&search%5Bsimple_search_value%5D=#{@simple_search_value}&search%5Bfrom_logistic_print_date%5D=#{@from_logistic_print_date}&search%5Bto_logistic_print_date%5D=#{@to_logistic_print_date}&search%5Bfrom_logistic_print_time%5D=#{@from_logistic_print_time}&search%5Bto_logistic_print_time%5D=#{@to_logistic_print_time}&search%5Bfrom_deliver_print_date%5D=#{@from_deliver_print_date}&search%5Bto_deliver_print_date%5D=#{@to_deliver_print_date}&search%5Bfrom_deliver_print_time%5D=#{@from_deliver_print_time}&search%5Bto_deliver_print_time%5D=#{@to_deliver_print_time}&search%5Bsearch_start_date%5D=#{@search_start_date}&search%5Bsearch_start_time%5D=#{@search_start_time}&search%5Bsearch_end_date%5D=#{@search_end_date}&search%5Bsearch_end_time%5D=#{@search_end_time}&search%5Bpay_start_time%5D=#{@pay_start_time}&search%5Bpay_end_time%5D=#{@pay_end_time}&search%5Bpay_start_date%5D=#{@pay_start_date}&search%5Bpay_end_date%5D=#{@pay_end_date}&search%5Bstatus_option%5D=#{@status_option}&search%5Btype_option%5D=#{@type_option}&search%5Bstate_option%5D=#{@state_option}&search%5Bcity_option%5D=#{@city_option}&search%5Bdistrict_option%5D=#{@district_option}&search%5Bsearch_buyer_message%5D=#{@search_buyer_message}&search%5Bsearch_seller_memo%5D=#{@search_seller_memo}&search%5Bsearch_cs_memo%5D=#{@search_cs_memo}&search%5Bsearch_cs_memo_void%5D=#{@search_cs_memo_void}&search%5Bsearch_invoice%5D=#{@search_invoice}&search%5Bsearch_color%5D=#{@search_color}&search%5Bsearch_color_void%5D=#{@search_color_void}&search%5Bsearch_logistic%5D=#{@search_logistic}&limit=0&offset=0")
    
  selectSameStatusTrade: (e) =>
    e.preventDefault()
    $('.dropdown.open .dropdown-toggle').dropdown('toggle')
    @search_trade_status = $(e.target).data('trade-status')
    MagicOrders.trade_mode = $(e.target).data('trade-mode')
    Backbone.history.navigate('trades/' + "#{MagicOrders.trade_mode}-#{@search_trade_status}", true)

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

    logistics = []
    $.get '/trades/deliver_list', {ids: tmp}, (data) ->
      for trade in data
        logistics.push trade.logistic_name unless trade.logistic_name in logistics

      if logistics.length > 1
        alert('只能选择同一家物流商的订单批量设置物流')
      else
        $('#ord_logistics_billnum_mult .logistic_name').val(logistics[0])
        $('#ord_logistics_billnum_mult').modal('show')

  confirmReturn: ->
    begin = $('.logistic_begin').val()
    end = $('.logistic_end').val()
    unless /^\w+$/.test(begin) and /^\w+$/.test(end)
      alert('输入单号不符合规则')
      return

    begin_pre = begin.slice(0, -4)
    begin_last_number = begin.slice(-4) * 1
    end_pre = end.slice(0, -4)
    end_last_number = end.slice(-4) * 1
    if (end_last_number - begin_last_number + 1) != MagicOrders.idCarrier.length
      alert('物流单号与选中产品个数不匹配')
      return

    $.get '/trades/deliver_list', {ids: MagicOrders.idCarrier}, (data) ->
      html = ''
      for trade, i in data
        html += '<tr>'
        html += '<td class="tid">' + trade.tid + '</td>'
        html += '<td>' + trade.name + '</td>'
        html += '<td>' + trade.address + '</td>'
        html += '<td class="logistic_bill">' + begin_pre + (begin_last_number + i) + '</td></tr>'

      $('#ord_logistics_billnum_mult2 tbody').html(html)
      $('#ord_logistics_billnum_mult').modal('hide')
      $('#ord_logistics_billnum_mult2').modal('show')

  confirmLogistics: ->
    bb = []
    a = $('#ord_logistics_billnum_mult2 tbody tr')
    a.each (i)->
      tid = $(a[i]).find('td.tid').html()
      logistic = $(a[i]).find('td.logistic_bill').html()
      h = {tid: tid, logistic: logistic}
      bb.push(h)

    $.get '/trades/setup_logistics', {data: bb, logistic_name: $('#ord_logistics_billnum_mult .logistic_name').val()}, (data)->
      if data.isSuccess == true
        $('#ord_logistics_billnum_mult2').modal('hide')
      else
        alert('失败')

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
        html += '<td>' + trade.name + '</td>'
        html += '<td>' + trade.address + '</td>'
        html += '<td>' + trade.logistic_name + '</td>'
        html += '<td>' + trade.logistic_waybill + '</td></tr>'
        flag = false if trade.logistic_name == '' or trade.logistic_waybill == ''

      $('.deliver_count').html(data.length)
      $('#batch_deliver tbody').html(html)
      unless flag == true
        alert('部份订单无物流信息，无法发货') 
        $('#batch_deliver .confirm_batch_deliver').hide()
      else
        $('#batch_deliver .confirm_batch_deliver').show()
      $('#batch_deliver').modal('show')

  confirmBatchDeliver: ->
    $.get '/trades/batch_deliver', {ids: MagicOrders.idCarrier}, (data)->
      if data.isSuccess == true
        $('#batch_deliver').modal('hide')
      else
        alert('失败')
