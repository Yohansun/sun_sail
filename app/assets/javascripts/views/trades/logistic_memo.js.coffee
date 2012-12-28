class MagicOrders.Views.TradesLogisticMemo extends Backbone.View

  template: JST['trades/logistic_memo']

  events:
    'click .save': 'save'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  save: ->
    blocktheui()

    @model.set "operation", "物流单备注"
    @model.set "logistic_memo", $("#logistic_memo_text").val()

    @model.save {},
      success: (model, response) =>
        $.unblockUI()

        view = new MagicOrders.Views.TradesRow(model: model)
        $("#trade_#{model.get('id')}").replaceWith(view.render().el)
        $("a[rel=popover]").popover({placement: 'left', html:true})
        $('#trade_logistic_memo').modal('hide')

      error: (model, error, response) =>
        $.unblockUI()
        alert("输入错误")