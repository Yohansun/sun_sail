class MagicOrders.Views.SellersRow extends Backbone.View

  tagName: 'tr'

  template: JST['sellers/row']

  events:
    'click [data-type=seller_area]': 'show_seller_area'

  initialize: ->

  render: ->
    $(@el).attr("id", "seller_#{@model.get('id')}")
    $(@el).html(@template(seller: @model))
    this

  show_seller_area: (e) ->
    e.preventDefault()
    Backbone.history.navigate('sellers/' + @model.get("id") + '/seller_area', true)
  
