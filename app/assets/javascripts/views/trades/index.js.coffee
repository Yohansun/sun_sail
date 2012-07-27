class MagicOrders.Views.TradesIndex extends Backbone.View

  template: JST['trades/index']

  events:
    'click [data-trade-type]': 'change_trade_type'
    'click .search': 'search'

  initialize: (options) ->
    @trade_type = options.trade_type
    @search_option = null
    @search_value = null

    @offset = 0
    @first_rendered = false

    @collection.on("reset", @render, this)

  render: ->
    $("body").spin(false)
    if !@first_rendered
      $(@el).html(@template(trade_type: @trade_type, search_value: @search_value))
      navs = {'all': '所有订单', 'taobao': '淘宝订单', 'taobao_fenxiao': '淘宝分销采购单', 'jingdong': '京东商城订单', 'shop': '官网订单'}
      $(@el).find(".trade_nav").text(navs[@trade_type])

    @first_rendered = true
    @collection.each(@appendTrade)
    this

  appendTrade: (trade) =>
    view = new MagicOrders.Views.TradesRow(model: trade)
    $(@el).find("#trade_rows").append(view.render().el)

  search: (e) ->
    e.preventDefault()
    @search_option = $(".search_option").val()
    @search_value = $(".search_value").val()
    return if @search_option == '' or @search_value == ''
    $("body").spin()
    $("#trade_rows").html('')
    @collection.fetch data: {search: {option: @search_option, value: @search_value}, trade_type: @trade_type}

  change_trade_type: (e) ->
    e.preventDefault()
    type = $(e.target).data('trade-type')
    Backbone.history.navigate('trades/' + type, true)

  fetch_more_trades: (event, direction) =>
    if direction == 'down'
      $("body").spin()
      @offset = @offset + 20
      @collection.fetch data: {search: {option: @search_option, value: @search_value}, trade_type: @trade_type, offset: @offset}