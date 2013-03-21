class MagicOrders.Routers.DeliverBills extends Backbone.Router
  routes:
    'deliver_bills': 'index'
    'deliver_bills/:trade_mode-:trade_type': 'index'
    'deliver_bills/:id/:operation': 'operation'

  initialize: ->
    @trade_type = null
    $('#content').html('')
    @collection = new MagicOrders.Collections.DeliverBills()

    MagicOrders.original_path = window.location.hash
    $('.delvier.modal').on 'hidden', (event) ->
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
    scrollTop = $(window).scrollTop()
    if scrollTop >= @navTop && !@isFixed
        @isFixed = true
        @nav.addClass('subnav-fixed')
    else
      if scrollTop <= @navTop && @isFixed
        @isFixed = false
        @nav.removeClass('subnav-fixed')

  index: (trade_mode = "deliver_bills", trade_type = null) ->
    # reset the index stage, hide all popups
    $('.modal').modal('hide')

    @isFixed = false

    $('#content').html ""
    @trade_type = trade_type
    MagicOrders.trade_mode = trade_mode
    MagicOrders.trade_type = trade_type
    blocktheui()
    @show_top_nav()
    @collection.fetch data: {trade_type: trade_type}, success: (collection, response) =>
      @mainView = new MagicOrders.Views.DeliverBillsIndex(collection: collection, trade_type: trade_type)
      $('#content').html(@mainView.render().el)
      $("a[rel=popover]").popover(placement: 'left')
      $('.order_search_form .datepickers').datetimepicker(weekStart:1,todayBtn:1,autoclose:1,todayHighlight:1,startView:2,forceParse:0,showMeridian:1)
      @nav = $('.subnav')
      @navTop = $('.subnav').length && $('.subnav').offset().top - 40
      $(window).off 'scroll'
      $(window).on 'scroll', @processScroll
      @processScroll
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
