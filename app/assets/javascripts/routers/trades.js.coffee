class MagicOrders.Routers.Trades extends Backbone.Router
  routes:
    '': 'main'
    'trades': 'index'
    'trades/:trade_mode-:trade_type?sid=:trade_search_id': 'index'
    'trades/:trade_mode-:trade_type': 'index'
    'send/:trade_mode-:trade_type': 'index'
    'color/:trade_mode-:trade_type': 'index'
    'return/:trade_mode-:trade_type': 'index'
    'trades/:id/splited': 'splited'
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

  processScroll: =>
    $('.js-affix').affix()

  main: () ->
    Backbone.history.navigate('trades', true)

  index: (trade_mode = "trades", trade_type = 'my_trade', trade_search_id = '') ->
    # reset the index stage, hide all popups
    $('.modal').modal('hide')

    @isFixed = false

    # if @collection.length == 0 || @trade_type != trade_type
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
      @mainView = new MagicOrders.Views.TradesIndex(collection: collection, trade_type: trade_type)
      $('#content').html(@mainView.render().el)
      @searchView = new MagicOrders.Views.TradesAdvancedSearch()
      $("#search_form").html(@searchView.render().el)

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
    $(window).on 'scroll', @processScroll
    $('.label_advanced').bind 'click', ->
      $(this).parent().toggleClass('open_advance')
      className = $('.js-open_advance').find('i').hasClass('icon-arrow-down')
      $('.js-open_advance').find('i').toggleClass( className ? 'icon-arrow-up' : 'icon-arrow-down')
      $('.js-open_advance').find('i').removeClass('icon-arrow-down').addClass('icon-arrow-up')

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
    if length > 120
      alert('订单数量过多，请选择120个以内的订单。')
      Backbone.history.navigate("#{MagicOrders.trade_mode}/" + "#{MagicOrders.trade_mode}-#{MagicOrders.trade_type}", false)
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

        switch operation_key
          when 'batch_add_gift'
            $.get '/categories/category_templates', {}, (c_data)->
              $('#select_category').select2 data: c_data
            $("#select_product").select2 data: []
            $('#select_sku').select2 data: []
          when 'batch_setup_logistic'
            trade_types = []
            for trade in collection.models
              trade_types.push(trade.attributes.trade_type)
            if $.unique(trade_types).length > 1
              alert('请选择同一来源的订单。')
              Backbone.history.navigate("#{MagicOrders.trade_mode}/" + "#{MagicOrders.trade_mode}-#{MagicOrders.trade_type}", false)
              return
          when 'batch_sort_product'
            MagicOrders.idCarrier = tmp
            $.get '/api/trades/sort_product_search', {ids: tmp}, (data) ->
              options =
                currentPage: 1
                totalPages: data.total_page
              $("#paginate_skus").bootstrapPaginator(options)
              $('#sort_product tbody').html(picking_orders(data.skus))
              $('#sort_product .print_sorted_product').show()
              $('.print_sorted_product').printPage()
              print_href = '/api/trades/sort_product_search.html?'+$.param({ids: tmp})
              $('.print_sorted_product').attr('href', print_href)

        $(modalDivID).html(view.render().el)
        $(modalDivID).modal('show')

  picking_orders = (skus) ->
    html = ''
    for sku in skus
      html += '<tr>'
      html += '<td>' + sku.title + '</td>'
      html += '<td>' + sku.num_iid + '</td>'
      html += '<td>' + sku.category + '</td>'
      html += '<td>' + sku.sku_properties + '</td>'
      html += '<td>' + sku.num + '</td>'
      html += '</tr>'
    return html

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
        when 'lock_trade','refund_ref'
          if model.get('stock_status') == "CANCELING"
            alert('此订单目前无法撤销,请稍后执行操作')
            Backbone.history.navigate("#{MagicOrders.trade_mode}/" + "#{MagicOrders.trade_mode}-#{MagicOrders.trade_type}", false)
            return
          else if model.get('stock_status') == "STOCKED" || model.get('stock_status') == "CANCELED_FAILED"
            alert('此订单已出库，无法撤销')
            Backbone.history.navigate("#{MagicOrders.trade_mode}/" + "#{MagicOrders.trade_mode}-#{MagicOrders.trade_type}", false)
            return
          else if model.get('stock_status') == "SYNCKED"
            alert('此订单已同步出库单，请先撤销此订单出库单')
            Backbone.history.navigate("#{MagicOrders.trade_mode}/" + "#{MagicOrders.trade_mode}-#{MagicOrders.trade_type}", false)
            return
          else
            if model.get('dispatched_at')
              alert('此订单已分流，请先分流重置订单')
              Backbone.history.navigate("#{MagicOrders.trade_mode}/" + "#{MagicOrders.trade_mode}-#{MagicOrders.trade_type}", false)
              return
        when 'seller'
          if model.get('stock_out_bill_present') && model.get('can_do_close') != true
            alert('此订单已出库或同步，无法分流重置')
            Backbone.history.navigate("#{MagicOrders.trade_mode}/" + "#{MagicOrders.trade_mode}-#{MagicOrders.trade_type}", false)
            return
        when 'property_memo'
          $("select.select2").select2()

      $(modalDivID).modal('show')

  splited: (id) ->
    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch data: {splited: true}, success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesSplited(model: model)
      $('#trade_splited').html(view.render().el)
      $('#trade_splited').modal('show')
