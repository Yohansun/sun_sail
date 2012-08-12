class MagicOrders.Views.TradesIndex extends Backbone.View

  template: JST['trades/index']

  events:
    'click [data-trade-type]': 'change_trade_type'
    'click .search': 'search'
    'click #advanced_btn': 'advanced_btn'
    'click .search_all': 'search_all'
    'click [data-type=loadMoreTrades]': 'forceLoadMoreTrades'

  initialize: (options) ->
    @trade_type = options.trade_type
    @search_option = null
    @search_value = null
    @status_option = null
    @search_start_date = null
    @search_end_date = null
    @search_start_time = null
    @search_end_time = null
    @status_option = null

    @offset = @collection.length
    @first_rendered = false

    # @collection.on("reset", @render, this)
    @collection.on("fetch", @render_update, this)

  render: =>
    $.unblockUI()
    if !@first_rendered
      $(@el).html(@template(trade_type: @trade_type, search_value: @search_value, search_start_date: @search_start_date, search_end_date: @search_end_date, search_start_time: @search_start_time, search_end_time: @search_end_time))
      navs = {'all': '所有订单', 'taobao': '淘宝订单', 'taobao_fenxiao': '淘宝分销采购单', 'jingdong': '京东商城订单', 'shop': '官网订单'}
      $(@el).find(".trade_nav").text(navs[@trade_type])

    @first_rendered = true
    @collection.each(@appendTrade)
    $("a[rel=popover]").popover(placement: 'left')

    this

  render_update: =>
    @collection.each(@appendTrade)
    $("a[rel=popover]").popover(placement: 'left')
    $.unblockUI()

  appendTrade: (trade) =>
    if $("#trade_#{trade.get('id')}").length == 0
      view = new MagicOrders.Views.TradesRow(model: trade)
      $(@el).find("#trade_rows").append(view.render().el)

  render_new: =>
    @collection.each(@prependTrade)
    $("a[rel=popover]").popover(placement: 'left')
    $.unblockUI()

  prependTrade: (trade) =>
    if $("#trade_#{trade.get('id')}").length == 0
      view = new MagicOrders.Views.TradesRow(model: trade)
      $(@el).find("#trade_rows").prepend(view.render().el)

  search: (e) ->
    e.preventDefault()
    @search_option = $(".search_option").val()
    @search_value = $(".search_value").val()
    return if @search_option == '' or @search_value == ''

    $("#trades_bottom").waypoint 'remove'
    blocktheui()
    $("#trade_rows").html('')
    @collection.fetch data: {search: {option: @search_option, value: @search_value}, trade_type: @trade_type}, success: (collection) =>
      if collection.length > 0
        @render_update()
        $('#trades_bottom').waypoint @fetch_more_trades, {offset: '100%'}
        $.unblockUI()

  search_all: (e) ->
    e.preventDefault()
    @status_option = $("#status_option").val()

    @search_start_date = $(".search_start_date").val()
    @search_end_date = $(".search_end_date").val()
    @search_start_time = $(".search_start_time").val()
    @search_end_time = $(".search_end_time").val()

    @search_buyer_message = $("#search_buyer_message").is(':checked')
    @search_seller_memo = $("#search_seller_memo").is(':checked')
    @search_cs_memo = $("#search_cs_memo").is(':checked')

    @search_invoice = $("#search_invoice").is(':checked')
    @search_color = $("#search_color").is(':checked')

    return if @status_option == '' and (@search_start_date == '' or @search_end_date == '') and @search_buyer_message == false and @search_seller_memo == false and @search_cs_memo == false and @search_color == false and @search_invoice == false

    blocktheui()
    $("#trade_rows").html('')
    
    if @search_start_date == '' or @search_end_date == '' or @search_start_date = 'null' or @search_end_date = 'null'
      @search_start_date = 'null'
      @search_end_date = 'null'
      @search_start_time = 'null'
      @search_end_time = 'null'

    if @search_start_time = ''
      @search_start_time = 'null'
    if @search_end_time = ''
      @search_end_time = 'null'

    if @status_option == ''
      @status_option = 'null'

    @collection.fetch data: {search: {option: @search_option, value: @search_value}, trade_type: @trade_type, search_all: {@search_start_date, @search_start_time, @search_end_date, @search_end_time, @status_option, @search_buyer_message, @search_seller_memo, @search_cs_memo, @search_invoice, @search_color}}, success: (collection) =>
      if collection.length > 0
        @offset = @offset + 20
        @render_update()
        $('#trades_bottom').waypoint @fetch_more_trades, {offset: '100%'}
      else
        $.unblockUI()
  
  change_trade_type: (e) ->
    e.preventDefault()
    type = $(e.target).data('trade-type')
    Backbone.history.navigate('trades/' + type, true)

  fetch_new_trades: =>
    @collection.fetch add: true, data: {search: {option: @search_option, value: @search_value}, trade_type: @trade_type, offset: 0, limit: $("#newTradesNotifer span").text()}, success: (collection) =>
      @render_new()
      $("#newTradesNotifer").hide()

  forceLoadMoreTrades: (event) =>
    event.preventDefault()

    $("#trades_bottom").waypoint 'remove'
    blocktheui()
    @collection.fetch data: {search: {option: @search_option, value: @search_value}, trade_type: @trade_type, offset: @offset, search_all: {@search_start_date, @search_start_time, @search_end_date, @search_end_time, @status_option, @search_buyer_message, @search_seller_memo, @search_cs_memo, @search_invoice, @search_color}}, success: (collection) =>
      console.log "fetch_more_trades succ"
      console.log collection.length > 0
      if collection.length > 0
        @offset = @offset + 20
        @render_update()
        $('#trades_bottom').waypoint @fetch_more_trades, {offset: '100%'}
        console.log "waypoint start"
      else
        $.unblockUI()

  fetch_more_trades: (event, direction) =>
    if direction == 'down'
      @forceLoadMoreTrades(event)

  advanced_btn: (e) ->
    e.preventDefault()
    $("#advanced_btn i").toggleClass 'icon-arrow-down'
    $("#advanced_btn i").toggleClass 'icon-arrow-up'
    $("#search_toggle").toggle()


    
