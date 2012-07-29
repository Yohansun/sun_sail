class MagicOrders.Views.TradesInvoice extends Backbone.View

  template: JST['trades/invoice']

  events:
    'click .save': 'save'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this
 
  save: ->
    $("body").spin()

    @model.save {'invoice_type': $('input[name=invoice_type]:checked').val()}
    @model.save {'invoice_name': $("#invoice_name_text").val()}                  
    @model.save {'invoice_date': $("#invoice_date_text").val()}, success: (model, response) => 
      $("body").spin(false)
      $('#trade_invoice').modal('hide')
      window.history.back()