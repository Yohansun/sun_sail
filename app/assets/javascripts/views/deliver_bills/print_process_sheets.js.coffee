class MagicOrders.Views.DeliverBillsPrintProcessSheets extends Backbone.View

  template: JST['deliver_bills/print_process_sheets']

  initialize: ->
    @collection.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(bills: @collection))
    this