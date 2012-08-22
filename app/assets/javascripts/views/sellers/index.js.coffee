class MagicOrders.Views.SellersIndex extends Backbone.View

  template: JST['sellers/index']

  events:
    'click .browse_children': 'browse_children'
    'click .edit_seller': 'edit_seller'

  initialize: ->
    @collection.on("reset", @render, this)

  render: ->
    $(@el).html(@template(sellers: @collection))
    this

  browse_children: (event) ->
    event.preventDefault()
    id = $(event.target).data("id")
    Backbone.history.navigate("sellers/#{id}", true)

  edit_seller: (event) ->
    event.preventDefault()
    id = $(event.target).data("id")
    Backbone.history.navigate("sellers/#{id}/edit", true)    