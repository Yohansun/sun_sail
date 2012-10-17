class MagicOrders.Views.TradesConfirmReceive extends Backbone.View

  template: JST['trades/confirm_receive']

  events:
    'click .save': 'save'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  save: ->
    blocktheui()
    @model.set "operation", "确认买家收货"
    @model.save 'confirm_receive_at', true, success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesRow(model: model)
      $("#trade_#{model.get('id')}").replaceWith(view.render().el)
      $("a[rel=popover]").popover(placement: 'left')

      $('#trade_confirm_receive').modal('hide')