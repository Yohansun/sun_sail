class MagicOrders.Views.DeliverBillsPrintProcessSheet extends Backbone.View

  template: JST['deliver_bills/print_process_sheet']

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(bill: @model))
    this