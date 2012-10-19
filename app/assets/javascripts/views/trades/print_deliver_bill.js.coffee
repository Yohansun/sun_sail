class MagicOrders.Views.TradesPrintDeliverBill extends Backbone.View

  template: JST['trades/print_deliver_bill']

  events:
    "click .button_print": 'print'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  print: (e) ->
    blocktheui()
    @model.save 'deliver_bill_printed_at', true, success: (model, response) =>    # 存储出货单最近一次的打印时间
      $.unblockUI()

      $('#trade_print_deliver_bill').modal('hide')
