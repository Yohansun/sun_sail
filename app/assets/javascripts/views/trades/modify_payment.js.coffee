class MagicOrders.Views.TradesModifyPayment extends Backbone.View

  template: JST['trades/modify_payment']

  events:
    'click .save': 'save'
    'click .clear_info': 'clear_info'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  save: ->
    blocktheui()

    unless /^[0-9]*$/.test($("#modify_payment_no").val())
      alert("支付宝交易号格式错误")
      $.unblockUI()
      return

    unless /^(-|)[0-9]*$/.test($("#modify_payment").val())
      alert("价格格式错误")
      $.unblockUI()
      return

    unless @model.get('total_fee') + parseFloat($('#modify_payment').val()) >= 0
      alert("价格调整幅度过大")
      $.unblockUI()
      return

    new_model = new MagicOrders.Models.Trade(id: @model.id)
    new_model.save {
      operation: "金额调整"
      modify_payment: $("#modify_payment").val()
      modify_payment_at: $("#modify_payment_at").val()
      modify_payment_no: $("#modify_payment_no").val()
      modify_payment_memo: $("#modify_payment_memo").val()
    }, success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesRow(model: model)
      $("#trade_#{model.get('id')}").replaceWith(view.render().el)
      view.reloadOperationMenu()

      $('#trade_modify_payment').modal('hide')

  clear_info: ->
    $("#modify_payment").val("")
    $("#modify_payment_at").val("")
    $("#modify_payment_no").val("")
    $("#modify_payment_memo").val("")