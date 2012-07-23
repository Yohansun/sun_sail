class MagicOrders.Views.TradesCsMemo extends Backbone.View

  template: JST['trades/cs_memo']

  events:
    'click .save': 'save'

  initialize: ->
    @model.on("change", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  save: ->
    @model.save 'cs_memo', $("#cs_memo_text").val(), success: (model, response) =>
      $('#trade_cs_memo').modal('hide')
      window.history.back()