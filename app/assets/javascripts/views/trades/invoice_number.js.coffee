class MagicOrders.Views.TradesInvoiceNumber extends Backbone.View

  template: JST['trades/invoice_number']

  events:
    'click .save': 'save'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  save: (e) ->
    e.preventDefault()
    blocktheui()
    
    unless $('#invoice_number_text').val() isnt ""
      alert("发票号不能为空")
      return

    unless /^[0-9]*$/.test($("#invoice_number_text").val())
      alert("发票格式不正确")
      return

    @model.save {"invoice_number": $("#invoice_number_text").val()},
      success: (model, response) =>
        $.unblockUI()

        view = new MagicOrders.Views.TradesRow(model: model)
        $("#trade_#{model.get('id')}").replaceWith(view.render().el)
        $("a[rel=popover]").popover(placement: 'left', trigger:'hover')

        $('#trade_invoice_number').modal('hide')


        