class MagicOrders.Routers.Trades extends Backbone.Router
  routes:
    '': 'main'
    'trades': 'index'
    'trades/:trade_mode-:trade_type': 'index'
    'send/:trade_mode-:trade_type': 'index'
    'color/:trade_mode-:trade_type': 'index'
    'trades/:id/splited': 'splited'
    'trades/:id/:operation': 'operation'
    'trades/print_deliver_bills': 'printDeliverBills'
    'trades/:id/recover': 'recover'

  initialize: ->
    @trade_type = null
    $('#content').html('')
    @collection = new MagicOrders.Collections.Trades()

    MagicOrders.original_path = window.location.hash
    $('.trade.modal').on 'hidden', (event) ->
      refresh = ($('#content').html() == '')
      if _.str.include(MagicOrders.original_path,'-')
        Backbone.history.navigate("#{MagicOrders.original_path}", refresh)
      else
        Backbone.history.navigate("trades", refresh)

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

  main: () ->
    Backbone.history.navigate('trades', true)

  index: (trade_mode = "trades", trade_type = null) ->
    # reset the index stage, hide all popups
    $('.modal').modal('hide')

    @isFixed = false

    # if @collection.length == 0 || @trade_type != trade_type
    $('#content').html ""
    @trade_type = trade_type
    MagicOrders.trade_mode = trade_mode
    MagicOrders.trade_type = trade_type
    blocktheui()
    @show_top_nav()
    @collection.fetch data: {trade_type: trade_type}, success: (collection, response) =>
      @mainView = new MagicOrders.Views.TradesIndex(collection: collection, trade_type: trade_type)
      $('#content').html(@mainView.render().el)
      $("a[rel=popover]").popover({placement: 'left', html:true})
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
        else
          $('.trade_nav').html($("[data-trade-status=#{trade_type}]").html())
      $('.order_search_form .datepickers').datepicker(format: 'yyyy-mm-dd')
      $('.order_search_form .timepickers').timeEntry(show24Hours: true, showSeconds: true, spinnerImage: '/assets/spinnerUpDown.png', spinnerSize: [17, 26, 0], spinnerIncDecOnly: true)

      unless MagicOrders.trade_mode in ['trades', 'deliver', 'logistics', 'send']
        $("#search_toggle").hide()
        $(".label_advanced").hide()
      else
        $('.trade_nav').html($("[data-trade-status=#{trade_type}]").html())
    $('.order_search_form .datepickers').datepicker(format: 'yyyy-mm-dd')
    $('.order_search_form .timepickers').timeEntry(show24Hours: true, showSeconds: true, spinnerImage: '/assets/spinnerUpDown.png', spinnerSize: [17, 26, 0], spinnerIncDecOnly: true)

    unless MagicOrders.trade_mode in ['trades', 'deliver', 'logistics', 'send']
      $("#search_toggle").hide()
      $(".label_advanced").hide()
    else
      $(".label_advanced").show()
    @nav = $('.subnav')
    @navTop = $('.subnav').length && $('.subnav').offset().top - 40
    $(window).off 'scroll'
    $(window).on 'scroll', @processScroll
    @processScroll

    $.unblockUI()

    # # 新订单提醒相关
    # if collection.models.length > 0
    #   @latest_trade_timestamp = collection.models[0].get('created_timestamp')
    # else
    #   @latest_trade_timestamp = -1

    # clearInterval @newTradesNotiferInterval if @newTradesNotiferInterval
    # @newTradesNotiferInterval = setInterval @newTradesNotifer, 300000


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
    viewClassName = "Trades" + _.classify(operation_key)
    modalDivID = "#trade_" + operation_key

    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views[viewClassName](model: model)
      $(modalDivID).html(view.render().el)
      $(modalDivID + ' .datepickers').datepicker(format: 'yyyy-mm-dd')

      switch operation_key
        when 'detail'
          $('.color_typeahead').typeahead({
            source: (query, process)->
              $.get '/colors/autocomplete', {num: query}, (data)->
                process(data)
          })
        when 'deliver'
          if MagicOrders.company == 'nippon' and !(parseInt(MagicOrders.current_user_seller_id) in MagicOrders.enable_trade_deliver_bill_spliting_sellers)
            $(modalDivID).find('.error').html()
            $('.deliver').show()
            if model.get('logistic_waybill')
              $("#logistic_company").html(model.get('logistic_name'))
            else
              $("#logistic_company").html('其他')
          else
            unless model.get('logistic_waybill')
              $(modalDivID).find('.error').html('该订单没有设置物流商和物流单号，请去“物流单”下“未设置物流信息”中调整订单')
              $('.deliver').hide()
            else
              $(modalDivID).find('.error').html()
              $('.deliver').show()
        when 'color'
          $('.color_typeahead').typeahead({
            source: (query, process)->
              $.get '/colors/autocomplete', {num: query}, (data)->
                process(data)
          })

      $(modalDivID).modal('show')

  splited: (id) ->
    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch data: {splited: true}, success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesSplited(model: model)
      $('#trade_splited').html(view.render().el)
      $('#trade_splited').modal('show')

  printDeliverBills: ->
    $('[checked="checked"].trade_check')
