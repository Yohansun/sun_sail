class MagicOrders.Views.LogisticBillsPrintLogisticBill extends Backbone.View

  template: JST['logistic_bills/print_logistic_bill']

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this
