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
    blocktheui()

    order_color_nums = {}
    for item in $(".order_color_num")
      order_id = $(item).data("order-id")
      order_color_num = $(item).val()
      order_color_nums[order_id] = order_color_num

    orders = @model.get('orders')
    for order, i in orders
      orders[i].color_num = order_color_nums[order.id]

    @model.save {'orders': orders},
      success: (model, response) =>
        $.unblockUI()

        view = new MagicOrders.Views.TradesRow(model: model)
        $("#trade_#{model.get('id')}").replaceWith(view.render().el)
        $("a[rel=popover]").popover(placement: 'left', trigger:'hover')

        $('#trade_color').modal('hide')
      
      error: (model, error, response) =>
        $.unblockUI()
        alert("色号不存在")