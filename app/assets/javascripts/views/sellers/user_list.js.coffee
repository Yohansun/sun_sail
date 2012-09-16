class MagicOrders.Views.SellersUserList extends Backbone.View

  template: JST['sellers/user_list']

  initialize: ->
    @collection.on("reset", @render, this)

  render: ->
    $(@el).html(@template(users: @collection))
    this