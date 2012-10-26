class MagicOrders.Views.TradesConfirmRefund extends Backbone.View

  template: JST['trades/confirm_refund']

  events:
    'click .save': 'save'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  save: ->
    blocktheui()
    @model.set "operation", "确认退款"
    @model.save 'confirm_refund_at', true, success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesRow(model: model)
      $("#trade_#{model.get('id')}").replaceWith(view.render().el)
      $("a[rel=popover]").popover(placement: 'left')

      $('#trade_confirm_refund').modal('hide')