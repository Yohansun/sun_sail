class MagicOrders.Views.TradesPropertyMemo extends Backbone.View

  template: JST['trades/property_memo']

  events:
    'click .save':               'save'
    'click .find_matched_bills': 'match_icp_bills'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    $(@el).find("select.select2").select2(
      allowClear: true
    )
    if @model.get('is_paid_not_delivered') == true && @model.get('dispatched_at')
      $(@el).find('.btn.btn-primary').remove()
    this

  match_icp_bills: (e) ->
    outer_id = $(e.currentTarget).parents('td').prev('td').find('.order_outer_iid').text()
    property_memo = {outer_id: outer_id}
    property_memo['values'] = []

    for memo in $(e.currentTarget).parents('tr').find('.property_memos').children(':input')
      if $(memo).data('type') == 'multiple_select' && $(memo).select2('data') != null
        for value in $(memo).select2('data')
          property_memo['values'].push {id: value.id, value: value.text}
      else if $(memo).data('type') == 'single_select' && $(memo).select2('data') != null
        property_memo['values'].push {id: $(memo).select2('data').id, value: $(memo).select2('data').text}
      else if $(memo).data('type') == 'input_text'
        property_memo['values'].push {id: $(memo).data('value-id'), value: $(memo).val()}

    $.get "/api/trades/match_icp_bills", {property_memo: property_memo}, (data) =>
      for bill in data.bills
        if bill != null
          $(e.currentTarget).parents('td').find('.matched_icp_bills').append("<option value="+bill.id+">"+bill.text+"</option>")
      $(e.currentTarget).closest('.find_matched_bills').remove()

  save: ->
    blocktheui()

    stock_in_bill_tids = $('.stock_in_bill_tid').map ->
      $(this).find('.matched_icp_bills').select2('data').id
    if stock_in_bill_tids.length != $.unique(stock_in_bill_tids).length
      $.unblockUI()
      alert("同一个成品入库单号不能使用两次！")
      return

    property_memos = {}
    for order in @model.get('orders')
      if $('tr.'+order.id).length > 0
        outer_id = $('.'+order.id).first().children('td:eq(2)').find('.order_outer_iid').text()
        property_memos[order.id] = {}
        for i in [0..($('tr.'+order.id).length - 1)]
          property_memos[order.id][i] = {}
          property_memos[order.id][i]['values'] = []
          property_memos[order.id][i]['outer_id'] = outer_id
          property_memos[order.id][i]['stock_in_bill_tid'] = $('tr.'+order.id+':eq('+i+')').children('td:last').find('.matched_icp_bills').select2('data').id

          for memo in $('tr.'+order.id+':eq('+i+')').find('.property_memos').children(':input')
            if $(memo).data('type') == 'multiple_select' && $(memo).select2('data') != null
              for value in $(memo).select2('data')
                property_memos[order.id][i]['values'].push {id: value.id, value: value.text}
            else if $(memo).data('type') == 'single_select' && $(memo).select2('data') != null
              property_memos[order.id][i]['values'].push {id: $(memo).select2('data').id, value: $(memo).select2('data').text}
            else if $(memo).data('type') == 'input_text'
              property_memos[order.id][i]['values'].push {id: $(memo).data('value-id'), value: $(memo).val()}

    new_model = new MagicOrders.Models.Trade(id: @model.id)
    new_model.save {operation: "属性备注", property_memos: property_memos}, success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesRow(model: model)
      $("#trade_#{model.get('id')}").replaceWith(view.render().el)
      view.reloadOperationMenu()

      $('#trade_property_memo').modal('hide')
