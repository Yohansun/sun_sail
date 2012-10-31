class MagicOrders.Views.TradesIndex extends Backbone.View

  template: JST['trades/index']

  events:

    'click .search': 'search'
    'click [data-type=loadMoreTrades]': 'forceLoadMoreTrades'
    'click .export_orders': 'exportOrders'
    'change #cols_filter input[type=checkbox]': 'filterTradeColumns'
    'click [data-trade-status]': 'selectSameStatusTrade'

    #visual effects
    'click #cols_filter input,label': 'keepColsFilterDropdownOpen'
    'click #advanced_btn': 'advancedSearch'
    'click .dropdown': 'dropdownTurnGray'

  initialize: (options) ->
    @trade_type = options.trade_type
    @identity = MagicOrders.role_key
    @offset = @collection.length
    @first_rendered = false

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
    if MagicOrders.trade_mode != 'deliver'
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
        $(@el).find("[data-type=loadMoreTrades]").replaceWith("<span data-type='loadMoreTrades'><b>当前无订单</b></span>")
      else
        $(@el).find("[data-type=loadMoreTrades]").replaceWith("<span data-type='loadMoreTrades'><b>当前为最后一条订单</b></span>")
    this

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
        $("[data-type=loadMoreTrades]").replaceWith("<a href='#' data-type='loadMoreTrades' class='btn'>加载更多订单</a>")
      else
        $(".get_offset").html($(".complete_offset").html())
        $("[data-type=loadMoreTrades]").replaceWith("<span data-type='loadMoreTrades'><b>当前为最后一条订单</b></span>")
      $("a[rel=popover]").popover(placement: 'left')
    else
      $(".complete_offset").html(0)
      $(".get_offset").html(0)
      $("[data-type=loadMoreTrades]").replaceWith("<span data-type='loadMoreTrades'><b>当前无订单</b></span>")
    $.unblockUI()

  appendTrade: (trade) =>
    if $("#trade_#{trade.get('id')}").length == 0
      view = new MagicOrders.Views.TradesRow(model: trade)
      $(@el).find("#trade_rows").append(view.render().el)

  renderNew: =>
    @collection.each(@prependTrade)
    $("a[rel=popover]").popover(placement: 'left')
    $.unblockUI()

  prependTrade: (trade) =>
    if $("#trade_#{trade.get('id')}").length == 0
      view = new MagicOrders.Views.TradesRow(model: trade)
      $(@el).find("#trade_rows").prepend(view.render().el)

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

  search: (e) ->
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
    @from_deliver_print_date = $(".print_start_date").val()
    @to_deliver_print_date = $(".print_end_date").val()
    @from_deliver_print_time = $(".print_start_time").val()
    @to_deliver_print_time = $(".print_end_time").val()

    @search_buyer_message = $("#search_buyer_message").is(':checked')
    @search_seller_memo = $("#search_seller_memo").is(':checked')
    @search_cs_memo = $("#search_cs_memo").is(':checked')
    @search_invoice = $("#search_invoice").is(':checked')
    @search_color = $("#search_color").is(':checked')

    @search_logistic = $("#search_logistic").val()

    return if (@search_option == '' or @search_value == '') and (@from_deliver_print_date == '' or @to_deliver_print_date == '') and @search_logistic == '' and @status_option == "" and @state_option == "" and @city_option == "" and @district_option == "" and @type_option == "" and (@search_start_date == '' or @search_end_date == '') and (@pay_start_date == '' or @pay_end_date == '') and @search_buyer_message == false and @search_seller_memo == false and @search_cs_memo == false and @search_color == false and @search_invoice == false

    @offset = 0
    blocktheui()
    $("#trade_rows").html('')

    @collection.fetch data: {trade_type: @trade_type, search: {@simple_search_option, @simple_search_value, @from_deliver_print_date, @to_deliver_print_date, @from_deliver_print_time, @to_deliver_print_time, @search_start_date, @search_start_time, @search_end_date, @pay_start_time, @pay_end_time, @pay_start_date, @pay_end_date, @search_end_time, @status_option, @type_option, @state_option, @city_option, @district_option, @search_buyer_message, @search_seller_memo, @search_cs_memo, @search_invoice, @search_color, @search_logistic}}, success: (collection) =>
      if collection.length >= 0
        @offset = @offset + 20
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
    @collection.fetch data: {trade_type: @trade_type, offset: @offset, search: {@simple_search_option, @simple_search_value, @from_deliver_print_date, @to_deliver_print_date, @from_deliver_print_time, @to_deliver_print_time, @search_start_date, @search_start_time, @search_end_date, @pay_start_time, @pay_end_time, @pay_start_date, @pay_end_date, @search_end_time, @status_option, @type_option, @state_option, @city_option, @district_option, @search_buyer_message, @search_seller_memo, @search_cs_memo, @search_invoice, @search_color, @search_logistic}}, success: (collection) =>
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
    @from_deliver_print_date = $(".print_start_date").val()
    @to_deliver_print_date = $(".print_end_date").val()
    @from_deliver_print_time = $(".print_start_time").val()
    @to_deliver_print_time = $(".print_end_time").val()

    @search_buyer_message = $("#search_buyer_message").is(':checked')
    @search_seller_memo = $("#search_seller_memo").is(':checked')
    @search_cs_memo = $("#search_cs_memo").is(':checked')
    @search_invoice = $("#search_invoice").is(':checked')
    @search_color = $("#search_color").is(':checked')

    @search_logistic = $("#search_logistic").val()

    window.open("/api/trades.xls?trade_type=#{@trade_type}&search%5Bsimple_search_option%5D=#{@simple_search_option}&search%5Bsimple_search_value%5D=#{@simple_search_value}&search%5Bfrom_deliver_print_date%5D=#{@from_deliver_print_date}&search%5Bto_deliver_print_date%5D=#{@to_deliver_print_date}&search%5Bfrom_deliver_print_time%5D=#{@from_deliver_print_time}&search%5Bto_deliver_print_time%5D=#{@to_deliver_print_time}&search%5Bsearch_start_date%5D=#{@search_start_date}&search%5Bsearch_start_time%5D=#{@search_start_time}&search%5Bsearch_end_date%5D=#{@search_end_date}&search%5Bsearch_end_time%5D=#{@search_end_time}&search%5Bpay_start_time%5D=#{@pay_start_time}&search%5Bpay_end_time%5D=#{@pay_end_time}&search%5Bpay_start_date%5D=#{@pay_start_date}&search%5Bpay_end_date%5D=#{@pay_end_date}&search%5Bstatus_option%5D=#{@status_option}&search%5Btype_option%5D=#{@type_option}&search%5Bstate_option%5D=#{@state_option}&search%5Bcity_option%5D=#{@city_option}&search%5Bdistrict_option%5D=#{@district_option}&search%5Bsearch_buyer_message%5D=#{@search_buyer_message}&search%5Bsearch_seller_memo%5D=#{@search_seller_memo}&search%5Bsearch_cs_memo%5D=#{@search_cs_memo}&search%5Bsearch_invoice%5D=#{@search_invoice}&search%5Bsearch_color%5D=#{@search_color}&search%5Bsearch_logistic%5D=#{@search_logistic}&limit=0&offset=0")

  selectSameStatusTrade: (e) =>
    e.preventDefault()
    $('.dropdown.open .dropdown-toggle').dropdown('toggle')
    @search_trade_status = $(e.target).data('trade-status')
    MagicOrders.trade_mode = $(e.target).data('trade-mode')
    Backbone.history.navigate('trades/' + "#{MagicOrders.trade_mode}-#{@search_trade_status}", true)

    MagicOrders.original_path = window.location.hash

    # 发货单打印时间筛选框只在deliver模式下显示
    if MagicOrders.trade_mode == 'deliver'
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