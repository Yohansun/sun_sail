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
    blocktheui()

    @model.set "invoice_type", $('input[name=invoice_type]:checked').val()
    @model.set "invoice_name", $("#invoice_name_text").val()
    @model.set "invoice_content", $("#invoice_content_text").val()
    @model.set "invoice_date", $("#invoice_date_text").val()
    @model.save {"invoice_name": $("#invoice_name_text").val()},
      error: (model, error, response) ->
        $.unblockUI()
        alert(error)
        
      success: (model, response) =>
        $.unblockUI()

        view = new MagicOrders.Views.TradesRow(model: model)
        $("#trade_#{model.get('id')}").replaceWith(view.render().el)
        $("a[rel=popover]").popover(placement: 'left', trigger:'hover')

        $('#trade_invoice').modal('hide')