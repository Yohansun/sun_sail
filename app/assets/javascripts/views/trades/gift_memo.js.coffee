class MagicOrders.Views.TradesGiftMemo extends Backbone.View

  template: JST['trades/gift_memo']

  events:
    'click .save': 'save'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  save: ->
    blocktheui()

    @model.set "operation", "赠品备注"
    @model.set "gift_memo", $("#gift_memo_text").val()

    @model.save {},
      success: (model, response) =>
        $.unblockUI()

        view = new MagicOrders.Views.TradesRow(model: model)
        $("#trade_#{model.get('id')}").replaceWith(view.render().el)
        $("a[rel=popover]").popover(placement: 'left')
        $('#trade_gift_memo').modal('hide')

      error: (model, error, response) =>
        $.unblockUI()
        alert("输入错误")