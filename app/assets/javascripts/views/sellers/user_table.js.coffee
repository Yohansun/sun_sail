class MagicOrders.Views.SellersUserTable extends Backbone.View

  template: JST['sellers/user_table']

  tagName: 'table'
  className: 'table table-bordered table-striped pull-left w_55'

  initialize: ->
    @collection.on("reset", @render, this)

  render: ->
    $(@el).html(@template(users: @collection))
    this



