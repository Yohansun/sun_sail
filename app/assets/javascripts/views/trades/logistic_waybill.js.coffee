 class MagicOrders.Views.TradesLogisticWaybill extends Backbone.View

  template: JST['trades/logistic_waybill']

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
    new_model.save {operation: "输入物流单号", logistic_waybill: $(".logistic_waybill").val()},
      success: (model, response) =>
        $.unblockUI()

        view = new MagicOrders.Views.TradesRow(model: model)
        $("#trade_#{model.get('id')}").replaceWith(view.render().el)
        view.reloadOperationMenu()
        $("a[rel=popover]").popover({placement: 'left', html:true})
        $('#logistic_waybill').modal('hide')

      error: (model, error, response) =>
        $.unblockUI()
        alert("输入错误")
