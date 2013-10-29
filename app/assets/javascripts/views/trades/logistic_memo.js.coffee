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

    new_model = new MagicOrders.Models.Trade(id: @model.id)
    new_model.save {operation: "物流单备注", logistic_memo: $("#logistic_memo_text").val()},
      success: (model, response) =>
        $.unblockUI()

        view = new MagicOrders.Views.TradesRow(model: model)
        $("#trade_#{model.get('id')}").replaceWith(view.render().el)
        view.reloadOperationMenu()

        $('#trade_logistic_memo').modal('hide')

      error: (model, error, response) =>
        $.unblockUI()
        alert("输入错误")