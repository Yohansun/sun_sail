class MagicOrders.Views.TradesBarcode extends Backbone.View

  template: JST['trades/barcode']

  events:
    'click .save': 'save'
    'keydown #input_barcode input': 'enter_replace_tab'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  enter_replace_tab: (e) ->
    if $(e.currentTarget).next("input").length == 0
      if $(e.currentTarget).parents("tr").next().find("input:first").length == 0
        input = $(e.currentTarget).parents("tr").next().next().find("input:first")
      else
        input = $(e.currentTarget).parents("tr").next().find("input:first")
    else
      input = $(e.currentTarget).next("input")
    if e.which == 13
      e.preventDefault()
      if input.length > 0
        input.focus()
      else
        $(e.currentTarget).blur()
        $(".save").click()

  save: ->
    blocktheui()

    for order in @model.get('orders')
      barcode = []

      for count in [0...order.num]
        tmp = []
        for item in $(".barcode_" + order.item_id + '_' + count)
          if (/^[0-9]{0,16}$/.test($(item).val())) is true
            tmp.push $(item).val()
          else
            invalid = true
            break

        barcode.push tmp

      order.barcode = barcode

    if invalid is true
      $.unblockUI()
      alert("格式不正确,只能为16位数字")
      return
    @model.set "operation", "输入唯一码"
    @model.save {},
      success: (model, response) =>
        $.unblockUI()

        view = new MagicOrders.Views.TradesRow(model: model)
        $("#trade_#{model.get('id')}").replaceWith(view.render().el)
        view.reloadOperationMenu()
        $("a[rel=popover]").popover({placement: 'left', html:true})
        $('#trade_barcode').modal('hide')

      error: (model, error, response) =>
        $.unblockUI()
        alert("输入错误")