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

    @model.save 'seller_confirm_deliver_at', true, success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesRow(model: model)
      $("#trade_#{model.get('id')}").replaceWith(view.render().el)
      $("a[rel=popover]").popover(placement: 'left')

      $('#trade_seller_confirm_deliver').modal('hide')
      #window.history.back()