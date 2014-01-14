class MagicOrders.Views.TradesPropertyMemo extends Backbone.View

  template: JST['trades/property_memo']

  events:
    'click .save':               'save'
    'click .find_matched_bills': 'match_icp_bills'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  match_icp_bills: (e) ->
    outer_id = $(e.currentTarget).parents('td').prev('td').find('.order_outer_iid').text()
    order_id = $(e.currentTarget).parents('tr').attr('id')
    property_memo = {outer_id: outer_id, order_id: order_id}
    property_memo['values'] = []

    for memo in $('#'+order_id+' .property_memos').children(':input')
      if $(memo).data('type') == 'multiple_select'
        for value in $(memo).select2('data')
          property_memo['values'].push {id: value.id, value: value.text}
      else if $(memo).data('type') == 'single_select'
        property_memo['values'].push {id: $(memo).select2('data').id, value: $(memo).select2('data').text}
      else if $(memo).data('type') == 'input_text'
        property_memo['values'].push {id: $(memo).data('value-id'), value: $(memo).val()}

    $.get "/api/trades/match_icp_bills", {property_memo: property_memo}, (data) =>
      for bill in data.bills
        if bill != null
          $('#matched_icp_bills').append("<option value="+bill.id+">"+bill.text+"</option>")
      $('.find_matched_bills').remove()

  save: ->
    blocktheui()

    property_memos = {}
    for order in @model.get('orders')
      outer_id = $('#'+order.id).children('td:eq(2)').find('.order_outer_iid').text()
      property_memos[order.id] = {outer_id: outer_id}
      property_memos[order.id]['values'] = []
      property_memos[order.id]['stock_in_bill_tids'] = []

      for bill in $('#'+order.id).children('td:last').find('#matched_icp_bills').select2('data')
        property_memos[order.id]['stock_in_bill_tids'].push bill.id

      for memo in $('#'+order.id+' .property_memos').children(':input')
        if $(memo).data('type') == 'multiple_select'
          for value in $(memo).select2('data')
            property_memos[order.id]['values'].push {id: value.id, value: value.text}
        else if $(memo).data('type') == 'single_select'
          property_memos[order.id]['values'].push {id: $(memo).select2('data').id, value: $(memo).select2('data').text}
        else if $(memo).data('type') == 'input_text'
          property_memos[order.id]['values'].push {id: $(memo).data('value-id'), value: $(memo).val()}

    new_model = new MagicOrders.Models.Trade(id: @model.id)
    new_model.save {operation: "属性备注", property_memos: property_memos}, success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesRow(model: model)
      $("#trade_#{model.get('id')}").replaceWith(view.render().el)
      view.reloadOperationMenu()

      $('#trade_property_memo').modal('hide')
