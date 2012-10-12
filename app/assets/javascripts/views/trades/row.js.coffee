class MagicOrders.Views.TradesRow extends Backbone.View

  tagName: 'tr'

  template: JST['trades/row']

  events:
    'click [data-type=detail]': 'show_detail'
    'click [data-type=seller]': 'show_seller'
    'click [data-type=deliver]': 'show_deliver'
    'click [data-type=cs_memo]': 'show_cs_memo'
    'click [data-type=color]': 'show_color'
    'click [data-type=invoice]': 'show_invoice'
    'click [data-type=invoice_number]': 'show_invoice_number'
    'click [data-type=seller_confirm_deliver]':'show_seller_confirm_deliver'
    'click [data-type=seller_confirm_invoice]':'show_seller_confirm_invoice'
    'click [data-type=barcode]':'show_barcode'
    'click [data-type=mark_unusual_state]':'show_mark_unusual_state'
    'click [data-type=operation_log]':'show_operation_log'
    'click [data-type=confirm_color]':'show_confirm_color'
    'click [data-type=confirm_check_goods]':'show_confirm_check_goods'

  initialize: ->

  render: ->
    $(@el).attr("id", "trade_#{@model.get('id')}")
    $(@el).html(@template(trade: @model))
    if @model.get("has_unusual_state") is true
      $(@el).attr("class", "error")
    $(@el).find(".trade_pops li").hide()
    for pop in MagicOrders.trade_pops[MagicOrders.trade_mode]
      unless MagicOrders.role_key == 'admin'
        if pop in MagicOrders.trade_pops[MagicOrders.role_key]
          $(@el).find(".trade_pops li [data-type=#{pop}]").parent().show()
      else
        $(@el).find(".trade_pops li [data-type=#{pop}]").parent().show()

    # reset cols
    for col in MagicOrders.trade_cols_hidden
      $(@el).find("td[data-col=#{col}]").hide()
    for col in _.difference(_.keys(MagicOrders.trade_cols), MagicOrders.trade_cols_hidden)
      $(@el).find("td[data-col=#{col}]").show()

    this

  show_detail: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trades/' + @model.get("id") + '/detail', true)

  show_seller: (e) ->
    e.preventDefault()
    html = ''
    trade_path = '/trades/' + @model.get("id")
    id = @model.get("id")
    tid = @model.get("tid")
    status = @model.get("status_text")
    name = @model.get('receiver_name')
    mobile = @model.get('receiver_mobile_phone')
    address = @model.get('receiver_state') + @model.get('receiver_city') + @model.get('receiver_district') + @model.get('receiver_address')
    s_name = name + "<br>" + mobile + "<br>" + address
    price = "￥" + @model.get('total_fee')
    $.get trade_path + '/sellers_info', {}, (data)->
      if data.length <= 1
        Backbone.history.navigate(trade_path + '/seller', true)
      else
        for el in data
          html += "<table class='table table-bordered'>"
          html += "<tr><th rowspan='" + (el.orders.length + 1) + "'>商品详细</th><th>商品名</th><th>数量</th></tr>"
          el.orders.forEach (item)->
            html += "<tr><td class='so_iid' iid='" + item.outer_iid + "'>" + item.title + "</td><td class='so_num'>" + item.num + "</td></tr>"
          html += "<tr><th>配送经销商</th><td colspan='2' class='seller_id' data='" + el.seller_id + "'>" + el.seller_name + "</td></tr>"
          html += "</table>"
        $('#s_id').html(id)
        $('#s_tid').html(tid)
        $('#s_status').html(status)
        $('#s_name').html(s_name)
        $('#s_price').html(price)
        $('#ord_split .splitted_orders').html(html)
        $('#ord_split').modal('show')

  show_deliver: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trades/' + @model.get("id") + '/deliver', true)

  show_cs_memo: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trades/' + @model.get("id") + '/cs_memo', true)

  show_color: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trades/' + @model.get("id") + '/color', true)

  show_invoice: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trades/' + @model.get("id") + '/invoice', true)

  show_invoice_number: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trades/' + @model.get("id") + '/invoice_number', true)

  show_seller_confirm_deliver: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trades/' + @model.get("id") + '/seller_confirm_deliver', true)

  show_seller_confirm_invoice: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trades/' + @model.get("id") + '/seller_confirm_invoice', true)

  show_barcode: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trades/' + @model.get("id") + '/barcode', true)

  show_mark_unusual_state: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trades/' + @model.get("id") + '/mark_unusual_state', true)

  show_operation_log: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trades/' + @model.get("id") + '/operation_log', true)

  show_confirm_color: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trades/' + @model.get("id") + '/confirm_color', true)

  show_confirm_check_goods: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trades/' + @model.get("id") + '/confirm_check_goods', true)