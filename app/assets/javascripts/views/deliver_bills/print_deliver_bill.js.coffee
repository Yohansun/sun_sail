class MagicOrders.Views.DeliverBillsPrintDeliverBill extends Backbone.View

  template: JST['deliver_bills/print_deliver_bill']

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(bill: @model))
    this