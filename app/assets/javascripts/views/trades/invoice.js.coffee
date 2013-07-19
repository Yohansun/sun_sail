class MagicOrders.Views.TradesInvoice extends Backbone.View

  template: JST['trades/invoice']

  events:
    'click .save': 'save'
    'click .no_invoice': 'no_invoice'
    'click .need_invoice': 'need_invoice'
    'click .is_invoice': 'is_invoice'

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
    @model.set "operation", "申请开票"
    @model.save {"invoice_name": $("#invoice_name_text").val()},
      error: (model, error, response) ->
        $.unblockUI()
        alert(error)

      success: (model, response) =>
        $.unblockUI()

        view = new MagicOrders.Views.TradesRow(model: model)
        $("#trade_#{model.get('id')}").replaceWith(view.render().el)
        checkedTradeRow(model.get('id'))
        $("a[rel=popover]").popover({placement: 'left', html:true})

        $('#trade_invoice').modal('hide')
        # window.history.back()

  no_invoice: (e) ->
    $("#invoice_name_text").attr("disabled","true")

  need_invoice: (e) ->
    $("#invoice_name_text").removeAttr("disabled")

  is_invoice: (e) ->
    $("#invoice_name_text").removeAttr("disabled")
