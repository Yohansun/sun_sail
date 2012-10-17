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
    @model.save data: {'deliver_bill_printed_at': true}          # 存储出货单最近一次的打印时间
    print_body = $(@el).find(".modal-body")
    print_body.wrapInner('<div class="print_content"></div>')
    print_body.children('.print_content').printArea()
