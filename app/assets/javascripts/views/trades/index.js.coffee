class MagicOrders.Views.TradesIndex extends Backbone.View

  template: JST['trades/index']

  events:
    # 'click [data-trade-type]': 'changeTradeType'
    'click [data-trade-mode]': 'changeTradeMode'
    'click .search': 'search'
    'click .search_all': 'searchAll'
    'click [data-type=loadMoreTrades]': 'forceLoadMoreTrades'
    'click .export_orders': 'exportOrders'
    'click #cols_filter input,label': 'keepColsFilterDropdownOpen'
    'change #cols_filter input[type=checkbox]': 'filterTradeColumns'

    #navigation bar function
    'click [data-trade-status]': 'selectSameStatusTrade'
    'click [data-invoice-status]': 'selectSameStatusInvoice'
    'click [data-deliver-bill-status]': 'selectSameStatusDeliverBill'
    'click [data-logistic-status]': 'selectSameStatusLogistic'
    'click [data-color-status]': 'selectSameStatusColor'
    'click [data-confirm_color-status]': 'selectSameStatusConfirmColor'

    #visual effects
    'click #advanced_btn': 'advancedSearch'
    'click .dropdown': 'dropdownTurnGray'

  initialize: (options) ->
    @trade_type = options.trade_type
    @search_option = null
    @search_value = null
    @status_option = null
    @type_option = null
    @search_start_date = null
    @search_end_date = null
    @search_start_time = null
    @search_end_time = null
    @pay_start_time = null
    @pay_end_time = null
    @pay_start_date = null
    @pay_end_date = null

    @offset = @collection.length
    @first_rendered = false

    # @collection.on("reset", @render, this)
    @collection.on("fetch", @renderUpdate, this)

  render: =>
    $.unblockUI()
    if !@first_rendered
       $(@el).html(@template())
      #initial mode=trades
      visible_cols = MagicOrders.trade_cols_visible_modes[MagicOrders.trade_mode]
      if MagicOrders.trade_cols_hidden == []
        MagicOrders.trade_cols_hidden = _.difference(MagicOrders.trade_cols_keys, visible_cols)
      for col in MagicOrders.trade_cols_keys
        if col in MagicOrders.trade_cols_hidden
          $("#trades_table th[data-col=#{col}],td[data-col=#{col}]").hide()
          $(@el).find("#cols_filter li[data-col=#{col}]").hide()
        else
          $("#trades_table th[data-col=#{col}],td[data-col=#{col}]").show()
          $(@el).find("#cols_filter li[data-col=#{col}]").show()

      # check column filters
      $(@el).find("#cols_filter input[type=checkbox]").attr("checked", "checked")
      for col in MagicOrders.trade_cols_hidden
        $(@el).find("td[data-col=#{col}]").hide()
        $(@el).find("th[data-col=#{col}]").hide()
        $(@el).find("#cols_filter input[value=#{col}]").attr("checked", false)

    @first_rendered = true
    @collection.each(@appendTrade)
    $("a[rel=popover]").popover(placement: 'left')
    @render_select_state()
    if MagicOrders.role_key == 'seller'
      $(@el).find(".trade_nav").text("未发货订单")
    this

  render_select_state: ->
    view = new MagicOrders.Views.AreasSelectState()
    $(@el).find('#select_state').html(view.render().el)

  renderUpdate: =>
    @collection.each(@appendTrade)
    $("a[rel=popover]").popover(placement: 'left')
    $.unblockUI()

  appendTrade: (trade) =>
    if $("#trade_#{trade.get('id')}").length == 0
      view = new MagicOrders.Views.TradesRow(model: trade)
      $(@el).find("#trade_rows").append(view.render().el)

  renderNew: =>
    @collection.each(@prependTrade)
    $("a[rel=popover]").popover(placement: 'left')
    $.unblockUI()

  prependTrade: (trade) =>
    if $("#trade_#{trade.get('id')}").length == 0
      view = new MagicOrders.Views.TradesRow(model: trade)
      $(@el).find("#trade_rows").prepend(view.render().el)

  keepColsFilterDropdownOpen: (event) ->
    event.stopPropagation()

  filterTradeColumns: (event) ->
    col = event.target
    if $(col).attr("checked") == 'checked'
      $("#trades_table th[data-col=#{$(col).val()}],td[data-col=#{$(col).val()}]").show()
      MagicOrders.trade_cols_hidden = _.without(MagicOrders.trade_cols_hidden, $(col).val())
    else
      $("#trades_table th[data-col=#{$(col).val()}],td[data-col=#{$(col).val()}]").hide()
      MagicOrders.trade_cols_hidden.push($(col).val())

    MagicOrders.trade_cols_hidden = _.uniq(MagicOrders.trade_cols_hidden)
    $.cookie('trade_cols_hidden', MagicOrders.trade_cols_hidden.join(","))

  search: (e) ->
    e.preventDefault()
    @search_option = $(".search_option").val()
    @search_value = $(".search_value").val()
    return if @search_option == '' or @search_value == ''

    blocktheui()
    $("#trade_rows").html('')
    @collection.fetch data: {search: {option: @search_option, value: @search_value}}, success: (collection) =>
      @renderUpdate()
      $.unblockUI()

  searchAll: (e) ->
    e.preventDefault()

    @search_option = $(".search_option").val()
    @search_value = $(".search_value").val()

    @status_option = $("#status_option").val()
    @type_option = $("#type_option").val()
    @state_option = $("#state_option").val()
    @city_option = $("#city_option").val()
    @district_option = $("#district_option").val()

    @search_start_date = $(".search_start_date").val()
    @search_end_date = $(".search_end_date").val()
    @search_start_time = $(".search_start_time").val()
    @search_end_time = $(".search_end_time").val()
    @pay_start_time = $(".pay_start_time").val()
    @pay_end_time = $(".pay_end_time").val()
    @pay_start_date = $(".pay_start_date").val()
    @pay_end_date = $(".pay_end_date").val()

    @search_buyer_message = $("#search_buyer_message").is(':checked')
    @search_seller_memo = $("#search_seller_memo").is(':checked')
    @search_cs_memo = $("#search_cs_memo").is(':checked')
    @search_invoice = $("#search_invoice").is(':checked')
    @search_color = $("#search_color").is(':checked')

    return if (@search_option == '' or @search_value == '') and @status_option == "" and @state_option == "" and @city_option == "" and @district_option == "" and @type_option == "" and (@search_start_date == '' or @search_end_date == '') and (@pay_start_date == '' or @pay_end_date == '') and @search_buyer_message == false and @search_seller_memo == false and @search_cs_memo == false and @search_color == false and @search_invoice == false

    @offset = 0
    blocktheui()
    $("#trade_rows").html('')

    @collection.fetch data: {trade_type: @trade_type, search: {option: @search_option, value: @search_value}, search_all: {@search_start_date, @search_start_time, @search_end_date, @pay_start_time, @pay_end_time, @pay_start_date, @pay_end_date, @search_end_time, @status_option, @type_option, @state_option, @city_option, @district_option, @search_buyer_message, @search_seller_memo, @search_cs_memo, @search_invoice, @search_color}}, success: (collection) =>

      if collection.length > 0
        @offset = @offset + 20
        @renderUpdate()
      else
        $.unblockUI()

  # changeTradeType: (e) ->
  #   e.preventDefault()
  #   type = $(e.target).data('trade-type')
  #   Backbone.history.navigate('trades/' + type, true)

  changeTradeMode: (e) ->
    e.preventDefault()
    $('.dropdown.open .dropdown-toggle').dropdown('toggle');
    $(@el).find(".trade_pops li").hide()
    MagicOrders.trade_mode = $(e.target).data('trade-mode')
    if MagicOrders.trade_mode isnt 'trades'
      $("#search_toggle").hide()
      $("#fieldset_advanced").hide()
      $("#advanced_btn i").toggleClass 'icon-arrow-down'
      $("#advanced_btn i").toggleClass 'icon-arrow-up'
      $("#simple_search_button").removeClass 'simple_search'
    else
      $("#fieldset_advanced").show()
    #$(@el).find(".trade_mode").text(MagicOrders.trade_modes[MagicOrders.trade_mode])

    # hide some cols
    visible_cols = MagicOrders.trade_cols_visible_modes[MagicOrders.trade_mode]
    MagicOrders.trade_cols_hidden = _.difference(MagicOrders.trade_cols_keys, visible_cols)

    for col in MagicOrders.trade_cols_keys
      if col in MagicOrders.trade_cols_hidden
        $("#trades_table th[data-col=#{col}], #trades_table td[data-col=#{col}]").hide()
        $("#cols_filter li[data-col=#{col}]").hide()
      else
        $("#trades_table th[data-col=#{col}], #trades_table td[data-col=#{col}]").show()
        $("#cols_filter li[data-col=#{col}]").show()

    # reset cols filter checker
    $("#cols_filter input[type=checkbox]").attr("checked", "checked")
    for col in MagicOrders.trade_cols_hidden
      $("#cols_filter input[value=#{col}]").attr("checked", false)

    # reset operation
    for pop in MagicOrders.trade_pops[MagicOrders.trade_mode]
      unless MagicOrders.role_key == 'admin'
        if pop in MagicOrders.trade_pops[MagicOrders.role_key]
          $(@el).find(".trade_pops li [data-type=#{pop}]").parent().show()
      else
        $(@el).find(".trade_pops li [data-type=#{pop}]").parent().show()

  fetch_new_trades: =>
    @collection.fetch add: true, data: {trade_type: @trade_type, offset: 0, limit: $("#newTradesNotifer span").text()}, success: (collection) =>
      @renderNew()
      $("#newTradesNotifer").hide()

  forceLoadMoreTrades: (event) =>
    event.preventDefault()

    blocktheui()
    @collection.fetch data: {trade_type: @trade_type, offset: @offset, search: {option: @search_option, value: @search_value}, search_all: {@search_start_date, @search_start_time, @pay_start_time, @pay_end_time, @pay_start_date, @pay_end_date, @search_end_date, @search_end_time, @status_option, @type_option, @state_option, @state_option, @city_option, @district_option, @search_buyer_message, @search_seller_memo, @search_cs_memo, @search_invoice, @search_color}, search_deliverbill_status: @search_deliverbill_status, logistic_status: @logistic_status, search_trade_status: @search_trade_status, search_invoice_status: @search_invoice_status, search_color_status: @search_color_status}, success: (collection) =>
      if collection.length > 0
        @offset = @offset + 20
        @renderUpdate()
      else
        $.unblockUI()

  fetchMoreTrades: (event, direction) =>
    if direction == 'down'
      @forceLoadMoreTrades(event)

  advancedSearch: (e) ->
    e.preventDefault()
    $("#advanced_btn i").toggleClass 'icon-arrow-down'
    $("#advanced_btn i").toggleClass 'icon-arrow-up'
    $("#search_toggle").toggle()
    $("#simple_search_button").toggleClass 'simple_search'

  dropdownTurnGray: (e) ->
    e.preventDefault()
    $click_li_dropdown = $("#overview").find("li.dropdown li")
    $click_li_dropdown.click ->
      $(this).parents(".dropdown").siblings().removeClass "active"
      $(this).parents(".dropdown").addClass "active"

  exportOrders: (e) =>
    e.preventDefault()

    @search_option = $(".search_option").val()
    @search_value = $(".search_value").val()

    @status_option = $("#status_option").val()
    @type_option = $("#type_option").val()
    @state_option = $("#state_option").val()

    @search_start_date = $(".search_start_date").val()
    @search_end_date = $(".search_end_date").val()
    @search_start_time = $(".search_start_time").val()
    @search_end_time = $(".search_end_time").val()
    @pay_start_time = $(".pay_start_time").val()
    @pay_end_time = $(".pay_end_time").val()
    @pay_start_date = $(".pay_start_date").val()
    @pay_end_date = $(".pay_end_date").val()

    @search_buyer_message = $("#search_buyer_message").is(':checked')
    @search_seller_memo = $("#search_seller_memo").is(':checked')
    @search_cs_memo = $("#search_cs_memo").is(':checked')

    @search_invoice = $("#search_invoice").is(':checked')
    @search_color = $("#search_color").is(':checked')

    @collection.fetch data: {trade_type: @trade_type, search_all: {@search_start_date, @search_start_time, @pay_start_time, @pay_end_time, @pay_start_date, @pay_end_date, @search_end_date, @search_end_time, @status_option, @type_option, @search_buyer_message, @search_seller_memo, @search_cs_memo, @search_invoice, @search_color}}, success: (collection) =>
      Backbone.history.navigate("/api/trades.xls?trade_type=#{@trade_type}&search%5Boption%5D=#{@search_option}&search%5Bvalue%5D=#{@search_value}&search_all%5Bsearch_start_date%5D=#{@search_start_date}&search_all%5Bsearch_start_time%5D=#{@search_start_time}&search_all%5Bsearch_end_date%5D=#{@search_end_date}&search_all%5Bsearch_end_time%5D=#{@search_end_time}&search_all%5Bstatus_option%5D=#{@status_option}&search_all%5Btype_option%5D=#{@type_option}&search_all%5Bstate_option%5D=#{@state_option}&search_all%5Bcity_option%5D=#{@city_option}&search_all%5Bdistrict_option%5D=#{@district_option}&search_all%5Bsearch_buyer_message%5D=#{@search_buyer_message}&search_all%5Bsearch_seller_memo%5D=#{@search_seller_memo}&search_all%5Bsearch_cs_memo%5D=#{@search_cs_memo}&search_all%5Bsearch_invoice%5D=#{@search_invoice}&search_all%5Bsearch_color%5D=#{@search_color}&search_deliverbill_status=#{@search_deliverbill_status}&logistic_status=#{@logistic_status}&search_all%5Bpay_start_time%5D=#{@pay_start_time}&search_all%5Bpay_end_time%5D=#{@pay_end_time}&search_all%5Bpay_start_date%5D=#{@pay_start_date}&search_all%5Bpay_end_date%5D=#{@pay_end_date}&limit=1000000&offset=0", true)
      location.reload()
      Backbone.history.navigate('trades')

  selectSameStatusTrade: (e) =>
    e.preventDefault()
    $('.dropdown.open .dropdown-toggle').dropdown('toggle');
    @search_trade_status = $(e.target).data('trade-status')
    $(@el).find(".trade_nav").text($("[data-trade-status=#{@search_trade_status}]").html())

    @offset = 0
    blocktheui()
    $("#trade_rows").html('')

    @collection.fetch data: {search_trade_status: @search_trade_status}, success: (collection) =>
     if collection.length > 0
       @offset = @offset + 20
       @renderUpdate()
     else
       $.unblockUI()

  selectSameStatusInvoice: (e) =>
    e.preventDefault()
    $('.dropdown.open .dropdown-toggle').dropdown('toggle');
    @search_invoice_status = $(e.target).data('invoice-status')
    $(@el).find(".trade_nav").text($(@el).find("[data-invoice-status=#{@search_invoice_status}]").html())
    @offset = 0
    blocktheui()
    $("#trade_rows").html('')

    @collection.fetch data: {search_invoice_status: @search_invoice_status}, success: (collection) =>
     if collection.length > 0
       @offset = @offset + 20
       @renderUpdate()
     else
       $.unblockUI()

  selectSameStatusDeliverBill: (e) =>
    e.preventDefault()
    $('.dropdown.open .dropdown-toggle').dropdown('toggle');
    @search_deliverbill_status = $(e.target).data('deliver-bill-status')
    $(@el).find(".trade_nav").text($(@el).find("[data-deliver-bill-status=#{@search_deliverbill_status}]").html())

    @offset = 0
    blocktheui()
    $("#trade_rows").html('')

    @collection.fetch data: {search_deliverbill_status: @search_deliverbill_status}, success: (collection) =>
     if collection.length > 0
       @offset = @offset + 20
       @renderUpdate()
     else
       $.unblockUI()

  selectSameStatusLogistic: (e) =>
    e.preventDefault()
    $('.dropdown.open .dropdown-toggle').dropdown('toggle');
    @logistic_status = $(e.target).data('logistic-status')
    $(@el).find(".trade_nav").text($(@el).find("[data-logistic-status=#{@logistic_status}]").html())

    @offset = 0
    blocktheui()
    $("#trade_rows").html('')

    @collection.fetch data: {logistic_status: @logistic_status}, success: (collection) =>
     if collection.length > 0
       @offset = @offset + 20
       @renderUpdate()
     else
       $.unblockUI()

  selectSameStatusColor: (e) =>
    e.preventDefault()
    $('.dropdown.open .dropdown-toggle').dropdown('toggle');
    @search_color_status = $(e.target).data('color-status')
    console.log(@search_color_status)
    $(@el).find(".trade_nav").text($(@el).find("[data-color-status=#{@search_color_status}]").html())

    @offset = 0
    blocktheui()
    $("#trade_rows").html('')

    @collection.fetch data: {search_color_status: @search_color_status}, success: (collection) =>
     if collection.length > 0
       @offset = @offset + 20
       @renderUpdate()
     else
       $.unblockUI()

  selectSameStatusConfirmColor: (e) =>
    e.preventDefault()
    $('.dropdown.open .dropdown-toggle').dropdown('toggle');
    @search_color_status = $(e.target).data('confirm_color-status')
    $(@el).find(".trade_nav").text($(@el).find("[data-confirm_color--status=#{@search_color_status}]").html())
    @offset = 0
    blocktheui()
    $("#trade_rows").html('')

    @collection.fetch data: {search_confirm_color_status: @search_color_status}, success: (collection) =>
     if collection.length > 0
       @offset = @offset + 20
       @renderUpdate()
     else
       $.unblockUI()