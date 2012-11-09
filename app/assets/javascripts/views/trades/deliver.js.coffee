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
    blocktheui()
    @model.set('delivered_at', true)
    @model.set "operation", "订单发货"
    @model.save {'logistic_info': $("#logistic_company").html()},
      error: (model, error, response) ->
        $.unblockUI()
        alert(error)
      success: (model, response) ->
        $.unblockUI()
        if MagicOrders.trade_mode == 'send'
          $("#trade_#{model.get('id')}").remove()
        else
          view = new MagicOrders.Views.TradesRow(model: model)
          $("#trade_#{model.get('id')}").replaceWith(view.render().el)

        $("a[rel=popover]").popover(placement: 'left')
        $('#trade_deliver').modal('hide')
        # window.history.back()
