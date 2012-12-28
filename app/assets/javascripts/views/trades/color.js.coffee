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

    @model.set "operation", "申请调色"
    @model.save {},
      success: (model, response) =>
        $.unblockUI()

        view = new MagicOrders.Views.TradesRow(model: model)
        $("#trade_#{model.get('id')}").replaceWith(view.render().el)
        $("a[rel=popover]").popover({placement: 'left', html:true})

        $('#trade_color').modal('hide')

      error: (model, error, response) =>
        $.unblockUI()
        alert("色号不存在")

