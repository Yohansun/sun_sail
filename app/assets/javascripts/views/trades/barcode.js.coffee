class MagicOrders.Views.TradesBarcode extends Backbone.View

  template: JST['trades/barcode']

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
      barcode = []
      for item in $(".barcode_" + order.item_id)
        if (/^[0-9]*$/.test($(item).val())) is true  ##{0,13}
          barcode.push $(item).val()
        else
          invalid = true
          break
      order.barcode = barcode

    if invalid is true
      $.unblockUI()
      alert("格式不正确,只能为数字")
      return

    @model.save {},
      success: (model, response) =>
        $.unblockUI()

        view = new MagicOrders.Views.TradesRow(model: model)
        $("#trade_#{model.get('id')}").replaceWith(view.render().el)
        $("a[rel=popover]").popover(placement: 'left')
        $('#trade_barcode').modal('hide')
      
      error: (model, error, response) =>
        $.unblockUI()
        alert("输入错误")