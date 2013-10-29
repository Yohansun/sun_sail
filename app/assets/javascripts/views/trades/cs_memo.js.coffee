class MagicOrders.Views.TradesCsMemo extends Backbone.View

  template: JST['trades/cs_memo']

  events:
    'click .save': 'save'
    'blur #cs_memo_text': 'check_chars_num'
    'blur .order_cs_memo': 'check_chars_num'
    "change #logistic_select": 'set_logistic_id'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    logistic_name = @model.get('logistic_name')
    $.get '/logistics/logistic_templates', {type: 'all',trade_type: @model.get("trade_type")}, (t_data)->
      html_options = ''
      for item in t_data
        if logistic_name == item.name
          html_options += '<option selected="selected" lid="' + item.id + '" service_logistic_id="' + item.service_logistic_id + '" value="' + item.xml + '">' + item.name + '</option>'
        else
          html_options += '<option lid="' + item.id + '" service_logistic_id="' + item.service_logistic_id + '" value="' + item.xml + '">' + item.name + '</option>'
      $('#logistic_select').html(html_options)
      service_logistic_id = $("#logistic_select").find("option:selected").attr("service_logistic_id")
      $("#service_logistic_id").val(service_logistic_id)

    this

  check_chars_num: (e) ->
    if $(e.currentTarget).val().length > 51
      alert("字数不得超过50个")
      $(e.currentTarget).focus()

  save: ->
    blocktheui()

    lid = $('#logistic_select').find("option:selected").attr('lid')

    order_cs_memos = {}
    for item in $(".order_cs_memo")
      order_id = $(item).data("order-id")
      order_cs_memo = $(item).val()
      order_cs_memos[order_id] = order_cs_memo

    orders = @model.get('orders')
    new_orders = []
    for order, i in orders
      new_order = {}
      new_order["id"] = order.id
      new_order["cs_memo"] = order_cs_memos[order.id]
      new_orders.push new_order

    new_model = new MagicOrders.Models.Trade(id: @model.id)
    new_model.save {operation: "客服备注", logistic_id: lid, orders: new_orders, cs_memo: $("#cs_memo_text").val(), service_logistic_id: $("#service_logistic_id").val()}, success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesRow(model: model)
      $("#trade_#{model.get('id')}").replaceWith(view.render().el)
      view.reloadOperationMenu()


      $('#trade_cs_memo').modal('hide')

  set_logistic_id: ->
    service_logistic_id = $("#logistic_select").find("option:selected").attr("service_logistic_id")
    $("#service_logistic_id").val(service_logistic_id)