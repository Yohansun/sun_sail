class MagicOrders.Views.TradesIndex extends Backbone.View

  template: JST['trades/index']

  events:
    'click [data-trade-type]': 'changeTradeType'
    'click [data-trade-mode]': 'changeTradeMode'
    'click .search': 'search'
    'click .search_all': 'searchAll'
    'click #advanced_btn': 'advancedSearch'
    'click [data-type=loadMoreTrades]': 'forceLoadMoreTrades'
    'click .export_orders': 'exportOrders'
    'click #cols_filter input,label': 'keepColsFilterDropdownOpen'
    'change #cols_filter input[type=checkbox]': 'filterTradeColumns'

  initialize: (options) ->
    @trade_type = options.trade_type
    @search_option = null
    @search_value = null
    @status_option = null
    @type_option = null
    @search_start_date = null
    @search_end_date = null
    @search_start_time = null
    @search_end_time = null

    @offset = @collection.length
    @first_rendered = false

    # @collection.on("reset", @render, this)
    @collection.on("fetch", @renderUpdate, this)

  render: =>
    $.unblockUI()
    if !@first_rendered
      $(@el).html(@template(trade_type: @trade_type, search_value: @search_value, search_start_date: @search_start_date, search_end_date: @search_end_date, search_start_time: @search_start_time, search_end_time: @search_end_time))
      navs = {'all': '所有订单', 'taobao': '淘宝订单', 'taobao_fenxiao': '淘宝分销采购单', 'jingdong': '京东商城订单', 'shop': '官网订单'}
      $(@el).find(".trade_nav").text(navs[@trade_type])

      # check column filters
      $(@el).find("#cols_filter input[type=checkbox]").attr("checked", "checked")
      for col in MagicOrders.trade_cols_hidden
        $(@el).find("#trades_table (th,td)[data-col=#{col}]").hide()
        $(@el).find("#cols_filter input[value=#{col}]").attr("checked", false)

    @first_rendered = true
    @collection.each(@appendTrade)
    $("a[rel=popover]").popover(placement: 'left')

    this

  renderUpdate: =>
    @collection.each(@appendTrade)
    $("a[rel=popover]").popover(placement: 'left')
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
      $("#trades_table (th,td)[data-col=#{$(col).val()}]").show()
      MagicOrders.trade_cols_hidden = _.without(MagicOrders.trade_cols_hidden, $(col).val())
    else
      $("#trades_table (th,td)[data-col=#{$(col).val()}]").hide()
      MagicOrders.trade_cols_hidden.push($(col).val())

    MagicOrders.trade_cols_hidden = _.uniq(MagicOrders.trade_cols_hidden)
    $.cookie('trade_cols_hidden', MagicOrders.trade_cols_hidden.join(","))

  search: (e) ->
    e.preventDefault()
    @search_option = $(".search_option").val()
    @search_value = $(".search_value").val()
    return if @search_option == '' or @search_value == ''

    $("#trades_bottom").waypoint('destroy')
    blocktheui()
    $("#trade_rows").html('')
    @collection.fetch data: {search: {option: @search_option, value: @search_value}, trade_type: @trade_type}, success: (collection) =>
      @renderUpdate()
      $.unblockUI()

  searchAll: (e) ->
    e.preventDefault()
    @status_option = $("#status_option").val()
    @type_option = $("#type_option").val()

    @search_start_date = $(".search_start_date").val()
    @search_end_date = $(".search_end_date").val()
    @search_start_time = $(".search_start_time").val()
    @search_end_time = $(".search_end_time").val()

    @search_buyer_message = $("#search_buyer_message").is(':checked')
    @search_seller_memo = $("#search_seller_memo").is(':checked')
    @search_cs_memo = $("#search_cs_memo").is(':checked')

    @search_invoice = $("#search_invoice").is(':checked')
    @search_color = $("#search_color").is(':checked')

    return if @status_option == "null" and @type_option == "null" and (@search_start_date == '' or @search_end_date == '') and @search_buyer_message == false and @search_seller_memo == false and @search_cs_memo == false and @search_color == false and @search_invoice == false

    @offset = 0
    blocktheui()
    $("#trade_rows").html('')

    if @search_start_date == '' or @search_end_date == ''    #权宜之计
      @search_start_date = 'null'
      @search_end_date = 'null'
      @search_start_time = 'null'
      @search_end_time = 'null'

    @collection.fetch data: {search: {option: @search_option, value: @search_value}, trade_type: @trade_type, search_all: {@search_start_date, @search_start_time, @search_end_date, @search_end_time, @status_option, @type_option, @search_buyer_message, @search_seller_memo, @search_cs_memo, @search_invoice, @search_color}}, success: (collection) =>
      if collection.length > 0
        @offset = @offset + 20
        @renderUpdate()
        $("#trades_bottom").waypoint('destroy')
        $('#trades_bottom').waypoint @fetchMoreTrades, {offset: '100%'}
      else
        $.unblockUI()

  changeTradeType: (e) ->
    e.preventDefault()
    type = $(e.target).data('trade-type')
    Backbone.history.navigate('trades/' + type, true)

  changeTradeMode: (e) ->
    e.preventDefault()
    @trade_mode = $(e.target).data('trade-mode')
    $(@el).find(".trade_mode").text(MagicOrders.trade_modes[@trade_mode])
    # hide some cols
    visible_cols = MagicOrders.trade_cols_visible_modes[@trade_mode]
    MagicOrders.trade_cols_hidden = _.difference(MagicOrders.trade_cols_keys, visible_cols)
    for col in MagicOrders.trade_cols_keys
      if col in MagicOrders.trade_cols_hidden
        $("#trades_table (th,td)[data-col=#{col}]").hide()
      else
        $("#trades_table (th,td)[data-col=#{col}]").show()

    # reset cols filter checker
    $(@el).find("#cols_filter input[type=checkbox]").attr("checked", "checked")
    for col in MagicOrders.trade_cols_hidden
      $(@el).find("#trades_table (th,td)[data-col=#{col}]").hide()
      $(@el).find("#cols_filter input[value=#{col}]").attr("checked", false)

  fetch_new_trades: =>
    @collection.fetch add: true, data: {search: {option: @search_option, value: @search_value}, trade_type: @trade_type, offset: 0, limit: $("#newTradesNotifer span").text()}, success: (collection) =>
      @renderNew()
      $("#newTradesNotifer").hide()

  forceLoadMoreTrades: (event) =>
    event.preventDefault()

    $("#trades_bottom").waypoint('destroy')
    blocktheui()
    @collection.fetch data: {search: {option: @search_option, value: @search_value}, trade_type: @trade_type, offset: @offset, search_all: {@search_start_date, @search_start_time, @search_end_date, @search_end_time, @status_option, @type_option, @search_buyer_message, @search_seller_memo, @search_cs_memo, @search_invoice, @search_color}}, success: (collection) =>
      if collection.length > 0
        @offset = @offset + 20
        @renderUpdate()
        $('#trades_bottom').waypoint @fetchMoreTrades, {offset: '100%'}
      else
        $.unblockUI()

  fetchMoreTrades: (event, direction) =>
    if direction == 'down'
      @forceLoadMoreTrades(event)

  advancedSearch: (e) ->
    e.preventDefault()
    $("#advanced_btn i").toggleClass 'icon-arrow-down'
    $("#advanced_btn i").toggleClass 'icon-arrow-up'
    $("#search_toggle").toggle()

  exportOrders: (e) =>
    e.preventDefault()
    window.open "/api/trades.xls?trade_type=#{@trade_type}&search%5Bvalue%5D=#{@search_value}&search%5Boption%5D=#{@search_option}&search%5Bvalue%5D=#{@search_value}&trade_type=#{@trade_type}&search_all%5Bsearch_start_date%5D=#{@search_start_date}&search_all%5Bsearch_start_time%5D=#{@search_start_time}&search_all%5Bsearch_end_date%5D=#{@search_end_date}&search_all%5Bsearch_end_time%5D=#{@search_end_time}&search_all%5Bstatus_option%5D=#{@status_option}&search_all%5Btype_option%5D=#{@type_option}&search_all%5Bsearch_buyer_message%5D=#{@search_buyer_message}&search_all%5Bsearch_seller_memo%5D=#{@search_seller_memo}&search_all%5Bsearch_cs_memo%5D=#{@search_cs_memo}&search_all%5Bsearch_invoice%5D=#{@search_invoice}&search_all%5Bsearch_color%5D=#{@search_color}&limit=1000000&offset=0"