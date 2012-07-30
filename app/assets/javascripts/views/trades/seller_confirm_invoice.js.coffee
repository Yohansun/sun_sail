class MagicOrders.Views.TradesSellerConfirmInvoice extends Backbone.View

  template: JST['trades/seller_confirm_invoice']

  events:
    'click .save': 'save'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this
 
  save: ->
    $("body").spin()
                
    @model.save 'seller_confirm_invoice_at', true, success: (model, response) => 
      $("body").spin(false)

      view = new MagicOrders.Views.TradesRow(model: model)
      $("#trade_#{model.get('id')}").replaceWith(view.render().el)
      $("a[rel=popover]").popover(placement: 'left')

      $('#trade_seller_confirm_invoice').modal('hide')
      #window.history.back()

