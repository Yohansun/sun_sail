class MagicOrders.Views.TradesColor extends Backbone.View

  template: JST['trades/color']

  events:
    'click .save': 'save'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  save: ->
    $("body").spin()

    order_color_nums = {}
    for item in $(".order_color_num")
      order_id = $(item).data("order-id")
      order_color_num = $(item).val()
      order_color_nums[order_id] = order_color_num

    orders = @model.get('orders')
    for order, i in orders
      orders[i].color_num = order_color_nums[order.id]

    @model.set("orders", orders)

    @model.save {'color': $("#color_text").val()}, success: (model, response) =>
      $("body").spin(false)
      $('#trade_color').modal('hide')
      window.history.back()