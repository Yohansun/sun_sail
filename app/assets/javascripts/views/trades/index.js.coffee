class MagicOrders.Views.TradesIndex extends Backbone.View

  template: JST['trades/index']

  events:
    'click [data-trade-type]': 'change_trade_type'
    'click .search': 'search'
    'click .search_time': 'search_time'

  initialize: (options) ->
    @trade_type = options.trade_type
    @search_option = null
    @search_value = null
    @search_start_date = null
    @search_end_date = null
    @search_start_time = null
    @search_end_time = null

    @offset = @collection.length
    @first_rendered = false

    @collection.on("reset", @render, this)
    @collection.on("fetch", @render_update, this)

  render: =>
    $("body").spin(false)
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
    $("body").spin(false)

  appendTrade: (trade) =>
    if $("#trade_#{trade.get('id')}").length == 0
      view = new MagicOrders.Views.TradesRow(model: trade)
      $(@el).find("#trade_rows").append(view.render().el)

  render_new: =>
    @collection.each(@prependTrade)
    $("a[rel=popover]").popover(placement: 'left')
    $("body").spin(false)

  prependTrade: (trade) =>
    if $("#trade_#{trade.get('id')}").length == 0
      view = new MagicOrders.Views.TradesRow(model: trade)
      $(@el).find("#trade_rows").prepend(view.render().el)

  search: (e) ->
    e.preventDefault()
    @search_option = $(".search_option").val()
    @search_value = $(".search_value").val()
    return if @search_option == '' or @search_value == ''
    $("body").spin()
    $("#trade_rows").html('')
    @collection.fetch data: {search: {option: @search_option, value: @search_value}, trade_type: @trade_type}

  search_time: (e) ->
    e.preventDefault()
    @search_start_date = $(".search_start_date").val()
    @search_end_date = $(".search_end_date").val()
    @search_start_time = $(".search_start_time").val()
    @search_end_time = $(".search_end_time").val()
    return if @search_start_date == '' or @search_end_date == '' or @search_start_time == '' or @search_end_time == ''
    $("body").spin()
    $("#trade_rows").html('')
    @collection.fetch data: {search_time: {@search_start_date, @search_start_time, @search_end_date, @search_end_time}}

  change_trade_type: (e) ->
    e.preventDefault()
    type = $(e.target).data('trade-type')
    Backbone.history.navigate('trades/' + type, true)

  fetch_new_trades: =>
    console.log $("#newTradesNotifer span").text()
    @collection.fetch add: true, data: {search: {option: @search_option, value: @search_value}, trade_type: @trade_type, offset: 0, limit: $("#newTradesNotifer span").text()}, success: (collection) =>
      @render_new()
      $("#newTradesNotifer").hide()

  fetch_more_trades: (event, direction) =>
    if direction == 'down'
      $("footer").waypoint('remove');
      $("body").spin()
      @collection.fetch add: true, data: {search: {option: @search_option, value: @search_value}, trade_type: @trade_type, offset: @offset, search_time: {@search_start_date, @search_start_time, @search_end_date, @search_end_time}}, success: (collection) =>
          @offset = @offset + 20
          @render_update()
          $('#trades_bottom').waypoint @fetch_more_trades, {offset: '100%'}
