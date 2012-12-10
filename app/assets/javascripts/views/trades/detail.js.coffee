class MagicOrders.Views.TradesDetail extends Backbone.View

  template: JST['trades/detail']

  events:
    "click .button_print": 'print'
    'click button.js-save': 'save'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    $('#myTab a:first').tab('show');
    this

  print: (e) ->
    print_body = $(@el).find(".modal-body")
    print_body.wrapInner('<div class="print_content"></div>')
    print_body.children('.print_content').printArea()

    $('#trade_detail').modal('hide')

  save: (e)->
    blocktheui()
    button = $(e.currentTarget)
    if button.data('source') is 'pre-process'
      @pre_process()

  pre_process: ->
    # color
    for order in @model.get('orders')
      color_num = []
      for count in [0...order.num]
        tmp = []
        for item in $(".color_num_" + order.item_id + '_' + count)
          tmp.push $(item).val()
        color_num.push tmp
      order.color_num = color_num

    # memo
    order_cs_memos = {}
    for item in $(".order_cs_memo")
      order_id = $(item).data("order-id")
      order_cs_memo = $(item).val()
      order_cs_memos[order_id] = order_cs_memo

    orders = @model.get('orders')
    for order, i in orders
      orders[i].cs_memo = order_cs_memos[order.id]

    @model.set("orders", orders)

    # invoice
    @model.set "invoice_type", $('input[name=invoice_type]:checked').val()
    @model.set "invoice_name", $("#invoice_name_text").val()
    @model.set "invoice_content", $("#invoice_content_text").val()
    @model.set "invoice_date", $("#invoice_date_text").val()

    # gift memo
    @model.set 'gift_memo', $('#gift_memo_text').val()
    @model.set "operation", "订单预处理"
    @model.save {'cs_memo': $("#cs_memo_text").val()},
      error: (model, error, response) ->
        $.unblockUI()
        alert(error)
      success: (model, response) =>
        $.unblockUI()
        # refresh the content of info tab elements
        for item in $(".order_cs_memo")
          order_id = $(item).data("order-id")
          $(".js-order-cs-memo-label-"+order_id).html($(item).val())

        for order in @model.get('orders')
          colors = []
          for count in [0...order.num]
            if order.color_num[count][0] and order.color_name[count]
              colors.push(order.color_num[count][0] + " "+ order.color_name[count])
          mergedColor = compressArray(colors)
          for color in mergedColor
            $('.js-color-label-'+order.id).html(color.count+"桶 "+color.value+"<br/>")

        $('.js-invoice-label').html(@model.get('invoice_type') + ': ' + $("#invoice_name_text").val() + ', ' + $("#invoice_content_text").val() + ', ' + $("#invoice_date_text").val())
        $('.js-gift-memo-label').html(@model.get 'gift_memo')
        # focus on the info tab
        $('#myTab a:first').tab('show');
