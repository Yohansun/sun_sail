class MagicOrders.Views.TradesDeliver extends Backbone.View

  template: JST['trades/deliver']

  events:
    'click .deliver': 'deliver'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  deliver: ->
    if $("#logistic_code").val() == "-1"
      $("#logistic_code").parent().addClass("error")
      $("#logistic_code").parent().find(".help-inline").show()
      return

    blocktheui()
    @model.set('logistic_code', $("#logistic_code").val())
    @model.set('logistic_waybill', $("#logistic_waybill").val())
    @model.set('delivered_at', true)
    @model.set "operation", "订单发货"
    @model.save {'logistic_code': $("#logistic_code").val()},
      error: (model, error, response) ->
        $.unblockUI()
        alert(error)
      success: (model, response) ->
        $.unblockUI()
        view = new MagicOrders.Views.TradesRow(model: model)
        $("#trade_#{model.get('id')}").replaceWith(view.render().el)
        $("a[rel=popover]").popover(placement: 'left')

        $('#trade_deliver').modal('hide')
        # window.history.back()