class MagicOrders.Views.DeliverBillsIndex extends Backbone.View

  template: JST['deliver_bills/index']

  events:
    'click #checkbox_all': 'optAll'
    'click [data-trade-status]': 'selectSameStatusTrade'
    'click .print_delivers': 'printDelivers'
    'click .js-search': 'search'
    'click .index_pops li a[data-type]': 'show_type'

  initialize: ->

  render: =>
    $(@el).html(@template(bills: @collection))
    @collection.each(@prependDeliverBill)
    $(@el).find('a[data-trade-mode='+MagicOrders.trade_mode+'][data-trade-status="'+MagicOrders.trade_type+'"]').parents('li').addClass('active')
    this

  selectSameStatusTrade: (e) =>
    e.preventDefault()
    $('.dropdown.open .dropdown-toggle').dropdown('toggle')
    MagicOrders.trade_mode = $(e.target).data('trade-mode')
    status = $(e.target).data('trade-status')
    Backbone.history.navigate("#{MagicOrders.trade_mode}/" + "#{MagicOrders.trade_mode}-#{status}", true)

    MagicOrders.original_path = window.location.hash

  optAll: (e) ->
    if $('#checkbox_all')[0].checked
      $('.trade_check').attr('checked', 'checked')
    else
      $('.trade_check').removeAttr('checked')

  prependDeliverBill: (bill) =>
    view = new MagicOrders.Views.DeliverBillsRow(model: bill)
    $(@el).find("#trade_rows").prepend(view.render().el)

  printDelivers: ->
    tmp = []
    length = $('.trade_check:checked').parents('tr').length

    if length < 1
      alert('未选择订单！')
      return

    if length > 300
      alert('请选择小于300个订单！')
      return

    $('.trade_check:checked').parents('tr').each (index, el) ->
      input = $(el).find('.trade_check')
      a = input[0]

      if a.checked
        trade_id = $(el).attr('id').replace('trade_', '')
        tmp.push trade_id

    MagicOrders.idCarrier = tmp

    $.get '/deliver_bills/deliver_list', {ids: tmp}, (data) ->
      html = ''
      for trade in data
        html += '<tr>'
        html += '<td>' + trade.tid + '</td>'
        html += '<td>' + trade.name + '</td>'
        html += '<td>' + trade.address + '</td></tr>'


      bind_swf(tmp, 'ffd', '')
      $('#logistic_select').hide()
      $('.deliver_count').html(data.length)
      $('#print_delivers_tbody').html(html)
      $('#print_delivers').modal('show')

  search: (e)->
    blocktheui()
    search_hash = {}
    search_hash['condition'] = $('#deliver_bill_search_condition').val()
    search_hash['value'] = $('#deliver_bill_search_value').val()
    search_hash['from_batch_num'] = $('#from_batch_num').val()
    search_hash['to_batch_num'] = $('#to_batch_num').val()

    @collection.fetch data: {diliver_bill_search: search_hash}, success: (collection, response) =>
      @mainView = new MagicOrders.Views.LogisticBillsIndex(collection: collection)
      $('#content').html(@mainView.render().el)
      $.unblockUI()

  show_type: (e) ->
    e.preventDefault()
    length = $('.trade_check:checked').parents('tr').length
    if length <= 1
      if length == 1
        trade_id = $('.trade_check:checked').parents('tr').attr('id').slice(6)
        type = $(e.target).data('type')
        MagicOrders.cache_trade_number = parseInt($('.trade_check:checked').parents('tr').children('td:first').html())
        Backbone.history.navigate('deliver_bills/' + trade_id + "/#{type}", true)
      else
        alert("请勾选要操作的订单。")