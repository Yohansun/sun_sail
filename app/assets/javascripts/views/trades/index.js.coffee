class MagicOrders.Views.TradesIndex extends Backbone.View

  template: JST['trades/index']

  events:
    'click [data-trade-type]': 'change_trade_type'
    'click .search': 'search'
    'click [data-type=detail]': 'show_detail'
    'click [data-type=seller]': 'show_seller'
    'click [data-type=deliver]': 'show_deliver'
    'click [data-type=cs_memo]': 'show_cs_memo'
    'click [data-type=color]': 'show_color'

  initialize: (options) ->
    @trade_type = options.trade_type
    @search_option = null
    @search_value = null
    @collection.on("reset", @render, this)

  render: ->
    $(@el).html(@template(trades: @collection, trade_type: @trade_type, search_value: @search_value))
    navs = {'all': '所有订单', 'taobao': '淘宝订单', 'taobao_fenxiao': '淘宝分销采购单', 'jingdong': '京东商城订单', 'shop': '官网订单'}
    $(@el).find(".trade_nav").text(navs[@trade_type])
    this

  search: (e) ->
    e.preventDefault()
    @search_option = $(".search_option").val()
    @search_value = $(".search_value").val()
    return if @search_option == '' or @search_value == ''
    @collection.fetch data: {search: {option: @search_option, value: @search_value}, trade_type: @trade_type}

  change_trade_type: (e) ->
    e.preventDefault()
    type = $(e.target).data('trade-type')
    Backbone.history.navigate('trades/' + type, true)

  show_detail: (e) ->
    e.preventDefault()
    id = $(e.target).parents('[data-id]').data('id')
    Backbone.history.navigate('trades/' + id + '/detail', true)

  show_seller: (e) ->
    e.preventDefault()
    id = $(e.target).parents('[data-id]').data('id')
    Backbone.history.navigate('trades/' + id + '/seller', true)

  show_deliver: (e) ->
    e.preventDefault()
    id = $(e.target).parents('[data-id]').data('id')
    Backbone.history.navigate('trades/' + id + '/deliver', true)

  show_cs_memo: (e) ->
    e.preventDefault()
    id = $(e.target).parents('[data-id]').data('id')
    Backbone.history.navigate('trades/' + id + '/cs_memo', true)

  show_color: (e) ->
    e.preventDefault()
    id = $(e.target).parents('[data-id]').data('id')
    Backbone.history.navigate('trades/' + id + '/color', true)
