class MagicOrders.Views.TradesSellerConfirmDeliver extends Backbone.View

  template: JST['trades/seller_confirm_deliver']

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
    new_model.save {operation: "确认发货", seller_confirm_deliver_at: true}, success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesRow(model: model)
      $("#trade_#{model.get('id')}").replaceWith(view.render().el)
      view.reloadOperationMenu()
      $("a[rel=popover]").popover({placement: 'left', html:true})

      $('#trade_seller_confirm_deliver').modal('hide')