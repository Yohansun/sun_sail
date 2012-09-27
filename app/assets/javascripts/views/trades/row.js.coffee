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

  initialize: ->

  render: ->
    $(@el).attr("id", "trade_#{@model.get('id')}")
    $(@el).html(@template(trade: @model))
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
    Backbone.history.navigate('trades/' + @model.get("id") + '/seller', true)

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