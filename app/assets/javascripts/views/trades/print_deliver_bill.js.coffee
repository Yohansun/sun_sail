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
      print_body = $(@el).find(".modal-body")
      print_body.wrapInner('<div class="print_content"></div>')
      print_body.children('.print_content').printArea()

      $('#trade_print_deliver_bill').modal('hide')
