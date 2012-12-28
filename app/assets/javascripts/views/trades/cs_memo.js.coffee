class MagicOrders.Views.TradesCsMemo extends Backbone.View

  template: JST['trades/cs_memo']

  events:
    'click .save': 'save'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  save: ->
    blocktheui()

    order_cs_memos = {}
    for item in $(".order_cs_memo")
      order_id = $(item).data("order-id")
      order_cs_memo = $(item).val()
      order_cs_memos[order_id] = order_cs_memo

    orders = @model.get('orders')
    for order, i in orders
      orders[i].cs_memo = order_cs_memos[order.id]

    @model.set("orders", orders)
    @model.set "operation", "客服备注"
    @model.save {'cs_memo': $("#cs_memo_text").val()}, success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesRow(model: model)
      $("#trade_#{model.get('id')}").replaceWith(view.render().el)
      $("a[rel=popover]").popover({placement: 'left', html:true})

      $('#trade_cs_memo').modal('hide')
      # window.history.back()