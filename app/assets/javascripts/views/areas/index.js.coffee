class MagicOrders.Views.AreasIndex extends Backbone.View

  template: JST['areas/index']

  events:
    'click .browse_children': 'browse_children'

  initialize: ->
    @collection.on("reset", @render, this)

  render: ->
    $(@el).html(@template(areas: @collection))
    this

  browse_children: (event) ->
    id = $(event.target).data("id")
    Backbone.history.navigate("areas/#{id}", true)