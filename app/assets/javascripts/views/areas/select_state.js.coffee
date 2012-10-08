class MagicOrders.Views.AreasSelectState extends Backbone.View

  template: JST['areas/select_state']
  
  initialize: ->
    @states = new MagicOrders.Collections.Areas()
    @states.fetch()
    @states.on("reset", @render, this)

  render: ->
    $(@el).html(@template(states: @states))
    this
