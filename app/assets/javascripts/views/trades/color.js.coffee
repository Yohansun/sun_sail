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

    for order in @model.get('orders')
      color_num = []

      for count in [0...order.num]
        tmp = []
        for item in $(".color_num_" + order.item_id + '_' + count)
          tmp.push $(item).val()

        color_num.push tmp

      order.color_num = color_num

    new_model = new MagicOrders.Models.Trade(id: @model.id)
    new_model.save {operation: "申请调色", orders: @model.orders},
      success: (model, response) =>
        $.unblockUI()

        view = new MagicOrders.Views.TradesRow(model: model)
        $("#trade_#{model.get('id')}").replaceWith(view.render().el)
        view.reloadOperationMenu()


        $('#trade_color').modal('hide')

      error: (model, error, response) =>
        $.unblockUI()
        alert("色号不存在")

