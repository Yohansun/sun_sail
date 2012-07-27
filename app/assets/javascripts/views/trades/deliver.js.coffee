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

    $("body").spin()
    @model.set('logistic_code', $("#logistic_code").val())
    @model.set('logistic_waybill', $("#logistic_waybill").val())

    @model.save 'delivered_at', true, success: (model, response) =>
      $("body").spin(false)
      $('#trade_deliver').modal('hide')
      window.history.back()