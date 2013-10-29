class MagicOrders.Views.TradesDetail extends Backbone.View

  template: JST['trades/detail']

  events:
    "click .button_print": 'print'
    # 'click button.js-save': 'save'
    'click div.modal-header h3 span': 'zoomToggle'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    $('#myTab a:first').tab('show');
    $('div.modal-header h3 span').parents('.modal').removeClass('bigtoggle_parents');
    this

  print: (e) ->
    print_body = $(@el).find(".modal-body")
    print_body.wrapInner('<div class="print_content"></div>')
    print_body.children('.print_content').printArea()

    $('#trade_detail').modal('hide')

  zoomToggle: (e) ->
    $(e.currentTarget).parents('.modal').toggleClass('bigtoggle_parents');
    $(e.currentTarget).toggleClass('bigtoggle');

  # save: (e)->
  #   blocktheui()
  #   button = $(e.currentTarget)
  #   if button.data('source') is 'pre-process'
  #     @pre_process()

  # pre_process: ->
  #   # color
  #   for order in @model.get('orders')
  #     color_num = []
  #     if order.packaged
  #       tmp = {}
  #       for info in order.bill_info
  #         infoArray = []
  #         for info_count in [0...(info.number*order.num)]
  #           for item in $(".js-color-num-" + order.item_id + '-' + info.outer_id + '-' + info_count)
  #             infoArray.push($(item).val())
  #           tmp[info['outer_id']] = infoArray
  #       for count in [0...order.num]
  #         suite = []
  #         for info in order.bill_info
  #           for info_index in [0...info.number]
  #             suite.push(tmp[info.outer_id].shift())
  #         color_num.push(suite)
  #     else
  #       for count in [0...order.num]
  #         tmp = []
  #         for item in $(".js-color-num-" + order.item_id + '-' + count)
  #           tmp.push $(item).val()
  #         color_num.push(tmp)
  #     order.color_num = color_num
  #   # memo
  #   order_cs_memos = {}
  #   for item in $(".order_cs_memo")
  #     order_id = $(item).data("order-id")
  #     order_cs_memo = $(item).val()
  #     order_cs_memos[order_id] = order_cs_memo

  #   orders = @model.get('orders')
  #   for order, i in orders
  #     orders[i].cs_memo = order_cs_memos[order.id]

  #   @model.set("orders", orders)

  #   # invoice
  #   @model.set "invoice_type", $('input[name=invoice_type]:checked').val()
  #   @model.set "invoice_name", $("#invoice_name_text").val()
  #   @model.set "invoice_content", $("#invoice_content_text").val()
  #   @model.set "invoice_date", $("#invoice_date_text").val()

  #   # gift memo
  #   @model.set 'gift_memo', $('#gift_memo_text').val()
  #   @model.set "operation", "订单预处理"
  #   @model.save {'cs_memo': $("#cs_memo_text").val()},
  #     error: (model, error, response) ->
  #       $.unblockUI()
  #       alert(error)
  #     success: (model, response) =>
  #       $.unblockUI()
  #       # refresh the content of info tab elements
  #       $(".js-trade-cs-memo-label").html(model.get('cs_memo'))
  #       for item in $(".order_cs_memo")
  #         order_id = $(item).data("order-id")
  #         $(".js-order-cs-memo-label-"+order_id).html($(item).val())

  #       for order in model.get('orders')
  #         colors = []
  #         if order.packaged
  #           for info in order.bill_info
  #             info_color = []
  #             for key, value of info.colors
  #               for v_index in [0...value[0]]
  #                 info_color.push(key+" "+value[1])
  #             colors.push(info_color)
  #         else
  #           for count in [0...order.num]
  #             if order.color_num[count] and order.color_num[count][0] and order.color_name[count]
  #               colors.push(order.color_num[count][0] + " "+ order.color_name[count])

  #         if order.packaged
  #           for index in [0...order.bill_info.length]
  #             mergedColor = compressArray(colors[index])
  #             # console.log("mergedColor ->"+mergedColor)
  #             if mergedColor.length is 0
  #               $('.js-color-label-'+order.id+"-"+order.bill_info[index].outer_id).html('')
  #             else
  #               colorHtml = ''
  #               for color in mergedColor
  #                 colorHtml += color.count+"桶 "+color.value+"<br/>"
  #               # console.log("colorHtml ->"+colorHtml)
  #               $('.js-color-label-'+order.id+"-"+order.bill_info[index].outer_id).html(colorHtml)
  #         else
  #           mergedColor = compressArray(colors)
  #           if mergedColor.length is 0
  #             $('.js-color-label-'+order.id).html('')
  #           else
  #             colorHtml = ''
  #             for color in mergedColor
  #               colorHtml += color.count+"桶 "+color.value+"<br/>"
  #             $('.js-color-label-'+order.id).html(colorHtml)

  #       if model.get('invoice_name') or model.get('invoice_content')
  #         $('.js-invoice-label').html(model.get('invoice_type') + ' ' + model.get('invoice_name') + ' ' + model.get('invoice_content') + ' ' + $("#invoice_date_text").val())
  #       else
  #         $('.js-invoice-label').html('')

  #       $('.js-gift-memo-label').html(model.get 'gift_memo')
  #       # focus on the info tab
  #       $('#myTab a:first').tab('show');
  #       # refresh the data to row view
  #       view = new MagicOrders.Views.TradesRow(model: model)
  #       $("#trade_#{model.get('id')}").replaceWith(view.render().el)
  #       view.reloadOperationMenu()
  #
