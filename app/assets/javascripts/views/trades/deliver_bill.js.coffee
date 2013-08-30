class MagicOrders.Views.TradesDeliverBill extends Backbone.View

  template: JST['trades/deliver_bill']

  events:
    "click .button_print": 'print'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  print: (e) ->
    blocktheui()
    new_model = new MagicOrders.Models.Trade(id: @model.id)
    new_model.save {operation: "打印发货单", deliver_bill_printed_at: true}, success: (model, response) =>
      $.unblockUI()
      print_body = $(@el).find(".modal-body")
      print_body.wrapInner('<div class="print_content"></div>')
      print_body.children('.print_content').printArea()

      $('#trade_print_deliver_bill').modal('hide')
