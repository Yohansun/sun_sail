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

    @model.set "operation", "输入物流单号"
    @model.set "logistic_waybill", $(".logistic_waybill").val()

    @model.save {},
      success: (model, response) =>
        $.unblockUI()

        view = new MagicOrders.Views.TradesRow(model: model)
        $("#trade_#{model.get('id')}").replaceWith(view.render().el)
        $("a[rel=popover]").popover(placement: 'left')
        $('#logistic_waybill').modal('hide')

      error: (model, error, response) =>
        $.unblockUI()
        alert("输入错误")
