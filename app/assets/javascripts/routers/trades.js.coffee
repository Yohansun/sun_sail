class MagicOrders.Routers.Trades extends Backbone.Router
  routes:
    'trades': 'index'
    'trades/:trade_type': 'index'
    'trades/:id/detail': 'show'
    'trades/:id/print_deliver_bill': 'print_deliver_bill'
    'trades/:id/seller': 'seller'
    'trades/:id/deliver': 'deliver'
    'trades/:id/cs_memo': 'cs_memo'
    'trades/:id/color': 'color'
    'trades/:id/invoice': 'invoice'
    'trades/:id/invoice_number': 'invoice_number'
    'trades/:id/seller_confirm_deliver':'seller_confirm_deliver'
    'trades/:id/seller_confirm_invoice':'seller_confirm_invoice'
    'trades/:id/barcode':'barcode'
    'trades/:id/logistic_waybill':'logistic_waybill'
    'trades/:id/mark_unusual_state':'mark_unusual_state'
    'trades/:id/operation_log':'operation_log'
    'trades/:id/confirm_color': 'confirm_color'
    'trades/:id/confirm_check_goods': 'confirm_check_goods'
    'trades/:id/splited': 'splited'

  initialize: ->
    @trade_type = null
    $('#content').html('')
    @collection = new MagicOrders.Collections.Trades()

    $('#trade_detail').on 'hide', (event) ->
      Backbone.history.navigate('trades')

    $('#trade_seller').on 'hide', (event) ->
      Backbone.history.navigate('trades')

    $('#trade_invoice').on 'hidden', (event) ->
      Backbone.history.navigate('trades')

    $('#trade_color').on 'hide', (event) ->
      Backbone.history.navigate('trades')

    $('#trade_deliver').on 'hide', (event) ->
      Backbone.history.navigate('trades')

    $('#trade_cs_memo').on 'hide', (event) ->
      Backbone.history.navigate('trades')

    $('#trade_invoice_number').on 'hide', (event) ->
      Backbone.history.navigate('trades')

    $('#trade_seller_confirm_deliver').on 'hide', (event) ->
      Backbone.history.navigate('trades')

    $('#trade_seller_confirm_invoice').on 'hide', (event) ->
      Backbone.history.navigate('trades')

    $('#trade_barcode').on 'hide', (event) ->
      Backbone.history.navigate('trades')

    $('#logistic_waybill').on 'hide', (event) ->
      Backbone.history.navigate('trades')

    $('#trade_mark_unusual_state').on 'hide', (event) ->
      Backbone.history.navigate('trades')

    $('#trade_operation_log').on 'hide', (event) ->
      Backbone.history.navigate('trades')

    $('#trade_confirm_color').on 'hide', (event) ->
      Backbone.history.navigate('trades')

    $('#trade_confirm_check_goods').on 'hide', (event) ->
      Backbone.history.navigate('trades')

    $('#trade_splited').on 'hide', (event) ->
      Backbone.history.navigate('trades')

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

  index: (trade_type = null) ->
    @isFixed = false

    if @collection.length == 0 || @trade_type != trade_type
      $('#content').html ""
      @trade_type = trade_type
      blocktheui()
      @show_top_nav()
      @collection.fetch data: {trade_type: trade_type}, success: (collection, response) =>
        @mainView = new MagicOrders.Views.TradesIndex(collection: collection, trade_type: trade_type)
        console.log $('.trade_nav')
        console.log trade_type
        $('#content').html(@mainView.render().el)
        $("a[rel=popover]").popover(placement: 'left')
        switch trade_type
          when 'undispatched_one_day' then $('.trade_nav').html('超过一天未分流')
          when 'undelivered_two_days' then $('.trade_nav').html('超过两天未发货')
          when 'unpaid_two_days' then $('.trade_nav').html('超过两天未付款')
          when 'buyer_delay_deliver' then $('.trade_nav').html('买家延迟发货')
          when 'seller_ignore_deliver' then $('.trade_nav').html('卖家长时间未发货')
          when 'seller_lack_product' then $('.trade_nav').html('经销商缺货')
          when 'seller_lack_color' then $('.trade_nav').html('经销商无法调色')
          when 'buyer_demand_refund' then $('.trade_nav').html('买家要求退款')
          when 'buyer_demand_return_product' then $('.trade_nav').html('买家要求退货')
          when 'other_unusual_state' then $('.trade_nav').html('其他异常')

        $('.form-search .datepicker').datepicker(format: 'yyyy-mm-dd')
        $('.form-search .timepicker').timeEntry(show24Hours: true, showSeconds: true, spinnerImage: '/assets/spinnerUpDown.png', spinnerSize: [17, 26, 0], spinnerIncDecOnly: true)

        @nav = $('.subnav')
        @navTop = $('.subnav').length && $('.subnav').offset().top - 40
        $(window).off 'scroll'
        $(window).on 'scroll', @processScroll
        @processScroll

        $.unblockUI()

        # 新订单提醒相关
        if collection.models.length > 0
          @latest_trade_timestamp = collection.models[0].get('created_timestamp')
        else
          @latest_trade_timestamp = -1

        clearInterval @newTradesNotiferInterval if @newTradesNotiferInterval
        @newTradesNotiferInterval = setInterval @newTradesNotifer, 300000


  newTradesNotifer: =>
    $.get "/api/trades/notifer", {trade_type: @trade_type, timestamp: @latest_trade_timestamp}, (response) =>
      if response > 0
        $("#newTradesNotifer span").text(response)
        $("#newTradesNotifer").show()
        $("#newTradesNotiferLink").on 'click', (event) =>
          event.preventDefault()
          $("#newTradesNotiferLink").off 'click'
          @mainView.fetch_new_trades()

  show: (id) ->
    blocktheui()
    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesShow(model: model)
      $('#trade_detail').html(view.render().el)
      $('#trade_detail').modal('show')

  print_deliver_bill: (id) ->
    blocktheui()
    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesDeliverBill(model: model)
      $('#trade_detail').html(view.render().el)
      $('#trade_detail').modal('show')

  seller: (id) ->
    blocktheui()

    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesSeller(model: model)
      $('#trade_seller').html(view.render().el)
      $('#trade_seller').modal('show')

  splited: (id) ->
    blocktheui()

    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch data: {splited: true}, success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesSplited(model: model)
      $('#trade_splited').html(view.render().el)
      $('#trade_splited').modal('show')

  deliver: (id) ->
    blocktheui()

    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesDeliver(model: model)
      $('#trade_deliver').html(view.render().el)
      $('#trade_deliver').modal('show')

  cs_memo: (id) ->
    blocktheui()

    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesCsMemo(model: model)
      $('#trade_cs_memo').html(view.render().el)
      $('#trade_cs_memo').modal('show')

  color: (id) ->
    blocktheui()

    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesColor(model: model)
      $('#trade_color').html(view.render().el)
      $('#trade_color').modal('show')

  invoice: (id) ->
    blocktheui()

    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesInvoice(model: model)
      $('#trade_invoice').html(view.render().el)
      $('.pick_invoice_detail .datepicker').datepicker(format: 'yyyy-mm-dd')
      $('#trade_invoice').modal('show')

  invoice_number: (id) ->
    blocktheui()

    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesInvoiceNumber(model: model)
      $('#trade_invoice_number').html(view.render().el)
      $('#trade_invoice_number').modal('show')


  seller_confirm_deliver: (id) ->
    blocktheui()

    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesSellerConfirmDeliver(model: model)
      $('#trade_seller_confirm_deliver').html(view.render().el)
      $('#trade_seller_confirm_deliver').modal('show')

  seller_confirm_invoice: (id) ->
    blocktheui()

    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesSellerConfirmInvoice(model: model)
      $('#trade_seller_confirm_invoice').html(view.render().el)
      $('#trade_seller_confirm_invoice').modal('show')

  barcode: (id) ->
    blocktheui()

    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesBarcode(model: model)
      $('#trade_barcode').html(view.render().el)
      $('#trade_barcode').modal('show')

  logistic_waybill: (id) ->
    blocktheui()

    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesLogisticWaybill(model: model)
      $('#logistic_waybill').html(view.render().el)
      $('#logistic_waybill').modal('show')

  mark_unusual_state: (id) ->
    blocktheui()

    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesMarkUnusualState(model: model)
      $('#trade_mark_unusual_state').html(view.render().el)
      $('#trade_mark_unusual_state').modal('show')

  operation_log: (id) ->
    blocktheui()

    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesOperationLog(model: model)
      $('#trade_operation_log').html(view.render().el)
      $('#trade_operation_log').modal('show')

  confirm_color: (id) ->
    blocktheui()

    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesConfirmColor(model: model)
      $('#trade_confirm_color').html(view.render().el)
      $('#trade_confirm_color').modal('show')

  confirm_check_goods: (id) ->
    blocktheui()

    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesConfirmCheckGoods(model: model)
      $('#trade_confirm_check_goods').html(view.render().el)
      $('#trade_confirm_check_goods').modal('show')
