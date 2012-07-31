class MagicOrders.Views.TradesRow extends Backbone.View

  tagName: 'tr'

  template: JST['trades/row']

  events:
    'click [data-type=detail]': 'show_detail'
    'click [data-type=seller]': 'show_seller'
    'click [data-type=deliver]': 'show_deliver'
    'click [data-type=cs_memo]': 'show_cs_memo'
    'click [data-type=color]': 'show_color'
    'click [data-type=invoice]': 'show_invoice'
    'click [data-type=seller_confirm_deliver]':'show_seller_confirm_deliver'
    'click [data-type=seller_confirm_invoice]':'show_seller_confirm_invoice'

  initialize: ->

  render: ->
    $(@el).attr("id", "trade_#{@model.get('id')}")
    $(@el).html(@template(trade: @model))
    unless MagicOrders.role_key == 'admin'
      $(@el).find(".trade_pops li").hide()
      for pop in MagicOrders.trade_pops[MagicOrders.role_key]
        $(@el).find(".trade_pops li [data-type=#{pop}]").parent().show()

    this

  show_detail: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trades/' + @model.get("id") + '/detail', true)

  show_seller: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trades/' + @model.get("id") + '/seller', true)

  show_deliver: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trades/' + @model.get("id") + '/deliver', true)

  show_cs_memo: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trades/' + @model.get("id") + '/cs_memo', true)

  show_color: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trades/' + @model.get("id") + '/color', true)

  show_invoice: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trades/' + @model.get("id") + '/invoice', true)

  show_seller_confirm_deliver: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trades/' + @model.get("id") + '/seller_confirm_deliver', true)

  show_seller_confirm_invoice: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trades/' + @model.get("id") + '/seller_confirm_invoice', true)

