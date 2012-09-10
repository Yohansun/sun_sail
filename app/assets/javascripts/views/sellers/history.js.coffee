class MagicOrders.Views.SellersHistory extends Backbone.View

  template: JST['sellers/history']

  initialize: ->
    @model.on("fetch", @render, this)
      
  render: ->
    $(@el).html(@template(seller: @model))
    this