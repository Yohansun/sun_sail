class MagicOrders.Routers.DeliverBills extends Backbone.Router
  routes:
    'deliver_bills':                                              'index'
    'deliver_bills/:trade_mode-:trade_type?sid=:trade_search_id': 'index'
    'deliver_bills/:trade_mode-:trade_type':                      'index'
    'deliver_bills/:id/split_invoice':                            'split_invoice'
    'deliver_bills/batch/:batch_operation':                       'batch_operation'
    'deliver_bills/:id/:operation':                               'operation'

  initialize: ->
    @trade_type = null
    $('#content').html('')
    @collection = new MagicOrders.Collections.DeliverBills()

    MagicOrders.original_path = window.location.hash
    $('.deliver.modal').on 'hidden', (event) ->
      refresh = ($('#content').html() == '')
      if _.str.include(MagicOrders.original_path,'-')
        Backbone.history.navigate("#{MagicOrders.original_path}", refresh)
      else
        Backbone.history.navigate("deliver_bills", refresh)

    $('[data-toggle="modal"]').bind 'show', (event) ->
      blocktheui()

  show_top_nav: ->
    $("#top-nav li").hide()
    $("#top-nav li.trades").show()

  processScroll: =>
    $('.js-affix').affix()

  index: (trade_mode = "deliver_bills", trade_type = null, trade_search_id = '') ->
    # reset the index stage, hide all popups
    $('.modal').modal('hide')

    @isFixed = false

    $('#content').html ""
    @trade_type = trade_type
    MagicOrders.trade_mode = trade_mode
    MagicOrders.trade_type = trade_type
    search_data = {trade_type: trade_type}
    if /[0-9a-z]{24}/.exec(trade_search_id)
      MagicOrders.search_id = trade_search_id
      search_data["search_id"] = trade_search_id
    else
      MagicOrders.search_id = ''
    blocktheui()
    @show_top_nav()
    @collection.fetch data: search_data, success: (collection, response) =>
      @mainView = new MagicOrders.Views.DeliverBillsIndex(collection: collection, trade_type: trade_type)
      $('#content').html(@mainView.render().el)
      @searchView = new MagicOrders.Views.TradesAdvancedSearch()
      $("#search_form").html(@searchView.render().el)
      $("a[rel=popover]").popover(placement: 'left')
      $(window).on 'scroll', @processScroll
      switch trade_type
        when 'unprinted' then $('.trade_nav').html('未打印')
        when 'printed' then $('.trade_nav').html('已打印')

      $.unblockUI()

  newTradesNotifer: =>
    $.get "/api/trades/notifer", {trade_type: @trade_type, timestamp: @latest_trade_timestamp}, (response) =>
      if response > 0
        $("#newTradesNotifer span").text(response)
        $("#newTradesNotifer").show()
        $("#newTradesNotiferLink").on 'click', (event) =>
          event.preventDefault()
          $("#newTradesNotiferLink").off 'click'
          @mainView.fetch_new_trades()

  operation: (id, operation_key) ->
    viewClassName = "DeliverBills" + _.classify(operation_key)
    modalDivID = "#deliver_bill_" + operation_key

    @model = new MagicOrders.Models.DeliverBill(id: id)
    @model.fetch success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views[viewClassName](model: model)
      $(modalDivID).html(view.render().el)
      $(modalDivID + ' .datepicker').datetimepicker(format: 'yyyy-mm-dd',autoclose: true,minView: 2)

      switch operation_key
        when 'print_deliver_bill'
          bind_deliver_swf(model.get('id'))

          $(modalDivID).on 'hidden', ()->
            if MagicOrders.hasPrint == true
              $.get '/deliver_bills/batch-print-deliver', {ids: [model.get('id')]}

            MagicOrders.hasPrint = false

      $(modalDivID).modal('show')


  batch_operation: (operation_key)->
    viewClassName = "DeliverBills" + _.classify(operation_key)
    modalDivID = "#deliver_bill_" + operation_key

    tmp = []
    length = $('.trade_check:checked').parents('tr').length
    if length > 120
      alert('发货单数量过多，请选择120个以内的发货单。')
      Backbone.history.navigate("/deliver_bills/deliver_bills-all", false)
      return

    $('.trade_check:checked').parents('tr').each (index, el) ->
      input = $(el).find('.trade_check')
      a = input[0]
      if a.checked
        bill_id = $(el).attr('id').replace('trade_', '')
        tmp.push bill_id

    if tmp.length != 0
      @collection.fetch data: {ids: tmp, batch_option: true}, success: (collection, response) =>
        view = new MagicOrders.Views[viewClassName](collection: collection)

        switch operation_key
          when 'print_process_sheets'
            $.get '/api/trades/sort_product_search', {ids: tmp}, (data) ->
              $('.print_process_sheets').printPage()
              print_href = '/api/deliver_bills/print_process_sheets.html?'+$.param({ids: tmp})
              $('.print_process_sheets').attr('href', print_href)
        $(modalDivID).html(view.render().el)
        $(modalDivID).modal('show')

  split_invoice: (id) ->
    @model = new MagicOrders.Models.DeliverBill({id: id})
    @model.fetch success: (model,response) =>
      $.unblockUI()
      if model.get("bill_products_count") < 2
        alert("此物流单商品数量小于2,不能拆分!")
        Backbone.history.navigate("deliver_bills")
        return
      view = new MagicOrders.Views.DeliverBillsSplitInvoice({model: model})
      $('#split_invoice').html(view.render().el)
      $('#split_invoice').modal('show')