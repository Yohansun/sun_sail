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

  initialize: ->

  render: ->
    $(@el).html(@template(trade: @model))
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
  