class MagicOrders.Views.TradesCsMemo extends Backbone.View

  template: JST['trades/cs_memo']

  events:
    'click .save': 'save'
    'blur #cs_memo_text': 'check_chars_num'
    'blur .order_cs_memo': 'check_chars_num'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    $.get '/logistics/all_logistics', {type: 'all'}, (t_data)->
      html_options = ''
      for item in t_data
        html_options += '<option lid="' + item.id + '" value="' + item.xml + '">' + item.name + '</option>'
      $('.set_logistic_waybill #logistic_select').html(html_options)
    this

  check_chars_num: (e) ->
    if $(e.currentTarget).val().length > 51
      alert("字数不得超过50个")
      $(e.currentTarget).focus()

  save: ->
    blocktheui()

    lid = $('#logistic_select').find("option:selected").attr('lid')

    @model.set('logistic_id', lid)

    order_cs_memos = {}
    for item in $(".order_cs_memo")
      order_id = $(item).data("order-id")
      order_cs_memo = $(item).val()
      order_cs_memos[order_id] = order_cs_memo

    orders = @model.get('orders')
    for order, i in orders
      orders[i].cs_memo = order_cs_memos[order.id]

    @model.set("orders", orders)
    @model.set "operation", "客服备注"
    @model.save {'cs_memo': $("#cs_memo_text").val()}, success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesRow(model: model)
      $("#trade_#{model.get('id')}").replaceWith(view.render().el)
      checkedTradeRow(model.get('id'))
      $("a[rel=popover]").popover({placement: 'left', html:true})

      $('#trade_cs_memo').modal('hide')
      # window.history.back()