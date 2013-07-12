class MagicOrders.Routers.Trades extends Backbone.Router
  routes:
    '': 'main'
    'trades': 'index'
    'trades/:trade_mode-:trade_type': 'index'
    'send/:trade_mode-:trade_type': 'index'
    'color/:trade_mode-:trade_type': 'index'
    'return/:trade_mode-:trade_type': 'index'
    'trades/:id/splited': 'splited'
    'trades/print_deliver_bills': 'printDeliverBills'
    'trades/:id/recover': 'recover'
    'trades/batch/:batch_operation' : 'batch_operation'
    'trades/:id/:operation': 'operation'

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

  form_height: ->
    out_height = $('.js-affix').outerHeight();
    $('.btn-toolbar').css('top', out_height + 71 + 'px');

  processScroll: =>
    scrollTop = $(window).scrollTop()
    if scrollTop >= @navTop && !@isFixed
      @isFixed = true
      @nav.addClass('subnav-fixed')
    else
      if scrollTop <= @navTop && @isFixed
        @isFixed = false
        @nav.removeClass('subnav-fixed')
    $('.js-affix').affix()
    @form_height()


  main: () ->
    Backbone.history.navigate('trades', true)

  index: (trade_mode = "trades", trade_type = 'my_trade') ->
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
      @searchView = new MagicOrders.Views.TradesAdvancedSearch()
      $("#search_form").html(@searchView.render().el)
      $("a[rel=popover]").popover({placement: 'left', html:true})
      switch trade_type
        when 'undispatched_for_days' then $('.trade_nav').html('未分派时间过长')
        when 'undelivered_for_days' then $('.trade_nav').html('未发货时间过长')
        when 'unpaid_for_days' then $('.trade_nav').html('未付款时间过长')
        when 'buyer_delay_deliver' then $('.trade_nav').html('买家延迟发货')
        when 'seller_ignore_deliver' then $('.trade_nav').html('卖家长时间未发货')
        when 'seller_lack_product' then $('.trade_nav').html('经销商缺货')
        when 'seller_lack_color' then $('.trade_nav').html('经销商无法调色')
        when 'buyer_demand_refund' then $('.trade_nav').html('买家要求退款')
        when 'buyer_demand_return_product' then $('.trade_nav').html('买家要求退货')
        when 'other_unusual_state' then $('.trade_nav').html('其他异常')
        else
          $('.trade_nav').html($("[data-trade-status=#{trade_type}]").html())
      unless MagicOrders.trade_mode in ['trades', 'deliver', 'logistics', 'send']
        $("#search_toggle").hide()
        $(".label_advanced").hide()
      else
        $('.trade_nav').html($("[data-trade-status=#{trade_type}]").html())
    unless MagicOrders.trade_mode in ['trades', 'deliver', 'logistics', 'send']
      $("#search_toggle").hide()
      $(".label_advanced").hide()
    else
      $(".label_advanced").show()
    @nav = $('.subnav')
    @navTop = $('.subnav').length && $('.subnav').offset().top - 40
#    $(window).off 'scroll'
#    $(window).on 'scroll', @processScroll
    @processScroll
    $('.js-affix').affix()
    $('.label_advanced').bind 'click', ->
      $(this).parents("fieldset").siblings(".search_advanced").toggle 0, ->
        out_height = $('.js-affix').outerHeight()
        $('.btn-toolbar').css('top', out_height + 71 + 'px')

      $(this).parent().toggleClass('open_advance')
      # $(this).find('i').toggleClass('icon-arrow-up')
      className = $('.js-open_advance').find('i').hasClass('icon-arrow-down')
      $('.js-open_advance').find('i').toggleClass( className ? 'icon-arrow-up' : 'icon-arrow-down')
      $('.js-open_advance').find('i').removeClass('icon-arrow-down').addClass('icon-arrow-up')
      # $.unblockUI()

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

  batch_operation: (operation_key)->
    viewClassName = "Trades" + _.classify(operation_key)
    modalDivID = "#trade_" + operation_key

    tmp = []
    length = $('.trade_check:checked').parents('tr').length
    if length > 300
      alert('请选择小于300个订单！')
      return

    $('.trade_check:checked').parents('tr').each (index, el) ->
      input = $(el).find('.trade_check')
      a = input[0]
      if a.checked
        trade_id = $(el).attr('id').replace('trade_', '')
        tmp.push trade_id

    if tmp.length != 0
      @collection.fetch data: {ids: tmp, batch_option: true}, success: (collection, response) =>
        view = new MagicOrders.Views[viewClassName](collection: collection)
        $(modalDivID).html(view.render().el)
        $(modalDivID).modal('show')

        switch operation_key
          when 'batch_add_gift'
            $.get '/categories/category_templates', {}, (c_data)->
              $('#select_category').select2 data: c_data
            $("#select_product").select2 data: []
            $('#select_sku').select2 data: []

  operation: (id, operation_key) ->
    viewClassName = "Trades" + _.classify(operation_key)
    modalDivID = "#trade_" + operation_key


    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views[viewClassName](model: model)
      $(modalDivID).html(view.render().el)
      $(modalDivID + ' .datepickers').datetimepicker(format: 'yyyy-mm-dd', autoclose: true, minView: 2)

      switch operation_key
        when 'detail'
          $('.color_typeahead').typeahead({
            source: (query, process)->
              $.get '/colors/autocomplete', {num: query}, (data)->
                process(data)
          })
        when 'deliver'
          unless model.get('logistic_waybill')
            $(modalDivID).find('.error').html('该订单没有设置物流公司和物流单号，请设置物流信息')
          else
            $(modalDivID).find('.error').html()
          $('.deliver').show()
        when 'color'
          $('.color_typeahead').typeahead({
            source: (query, process)->
              $.get '/colors/autocomplete', {num: query}, (data)->
                process(data)
          })
        when 'barcode'
          $(modalDivID).on 'shown', ->
            $("#input_barcode input:eq(0)").focus()
        when 'gift_memo'
          $.get '/categories/category_templates', {}, (c_data)->
            $('#select_category').select2 data: c_data
          $("#select_product").select2 data: []
          $('#select_sku').select2 data: []
        when 'lock_trade'
          $(modalDivID).find('.save').hide()
          if model.get('stock_status') == "CANCELING"
            $(modalDivID).find('.error').html('此订单目前无法撤销,请稍后执行操作')
          else if model.get('stock_status') == "STOCKED" && model.get('stock_status') == "CANCELED_FAILED"
            $(modalDivID).find('.error').html('此订单已出库，无法撤销')
          else if model.get('stock_status') == "SYNCKED"
            $(modalDivID).find('.error').html('此订单已同步出库单，请先撤销此订单出库单')
          else
            if model.get('dispatched_at')
              $(modalDivID).find('.error').html('此订单已分流，请先分流重置订单')
            else
              $(modalDivID).find('.save').show()
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
