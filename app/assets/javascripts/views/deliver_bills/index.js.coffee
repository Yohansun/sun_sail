class MagicOrders.Views.DeliverBillsIndex extends Backbone.View

  template: JST['deliver_bills/index']

  events:
    'click .header #checkbox_all': 'optAll'
    'click .header-copy #checkbox_all': 'optCopyAll'
    'click [data-trade-status]': 'selectSameStatusTrade'
    'click .print_delivers': 'printDelivers'
    'click .index_pops li a[data-type]': 'show_type'

    # 加载更多订单相关
    'click [data-type=loadMoreTrades]': 'forceLoadMoreTrades'

    # index显示相关
    'change #cols_filter input[type=checkbox]': 'filterTradeColumns'
    'click #cols_filter input,label': 'keepColsFilterDropdownOpen'

    # 搜索相关
    'click .search': 'search'

  initialize: ->
    @offset = @collection.length
    @first_rendered = true
    @collection.on("fetch", @renderUpdate, this)

  render: =>
    if @first_rendered
      $(@el).html(@template(bills: @collection))
      #initial mode=trades
      visible_cols = MagicOrders.trade_cols_visible_modes[MagicOrders.trade_mode]
      MagicOrders.trade_cols_hidden[MagicOrders.trade_mode] = []
      if $.cookie("trade_cols_hidden_#{MagicOrders.trade_mode}")
        MagicOrders.trade_cols_hidden[MagicOrders.trade_mode] = $.cookie("trade_cols_hidden_#{MagicOrders.trade_mode}").split(',')
      for col in MagicOrders.trade_cols_keys
        if col in visible_cols
          $(@el).find("#cols_filter li[data-col=#{col}]").show()
          $(@el).find("#trades_table th[data-col=#{col}]").show()
          $(@el).find("#trades_table td[data-col=#{col}]").show()
        else
          $(@el).find("#cols_filter li[data-col=#{col}]").hide()
          $(@el).find("#trades_table th[data-col=#{col}]").hide()
          $(@el).find("#trades_table td[data-col=#{col}]").hide()

      # check column & trades_table filters
      $(@el).find("#cols_filter input[type=checkbox]").attr("checked", "checked")
      for col in MagicOrders.trade_cols_hidden[MagicOrders.trade_mode]
        $(@el).find("#cols_filter input[value=#{col}]").attr("checked", false)
        $(@el).find("#trades_table th[data-col=#{col}]").hide()
        $(@el).find("#trades_table td[data-col=#{col}]").hide()

    @first_rendered = false
    @collection.each(@appendTrade)

    $(@el).find(".get_offset").html(@offset)
    @loadStatusCount()
    $("#content").removeClass("search-expand")
    this

  filterTradeColumns: (event) ->
    col = event.target
    if $(col).attr("checked") == 'checked'
      $("#trades_table th[data-col=#{$(col).val()}],td[data-col=#{$(col).val()}]").show()
      MagicOrders.trade_cols_hidden[MagicOrders.trade_mode] = _.without(MagicOrders.trade_cols_hidden[MagicOrders.trade_mode], $(col).val())
    else
      $("#trades_table th[data-col=#{$(col).val()}],td[data-col=#{$(col).val()}]").hide()
      MagicOrders.trade_cols_hidden[MagicOrders.trade_mode].push($(col).val())

    MagicOrders.trade_cols_hidden[MagicOrders.trade_mode] = _.uniq(MagicOrders.trade_cols_hidden[MagicOrders.trade_mode])
    $.cookie("trade_cols_hidden_#{MagicOrders.trade_mode}", MagicOrders.trade_cols_hidden[MagicOrders.trade_mode].join(","))

  keepColsFilterDropdownOpen: (event) ->
    event.stopPropagation()

  selectSameStatusTrade: (e) =>
    e.preventDefault()
    link = $(e.target).closest("a[data-trade-status]")
    $('.dropdown.open .dropdown-toggle').dropdown('toggle')
    MagicOrders.trade_mode = $(link).data('trade-mode')
    status = $(link).data('trade-status')
    nvg_path = "#{MagicOrders.trade_mode}/" + "#{MagicOrders.trade_mode}-#{status}"
    search_id = $(link).data('search-id')
    if search_id
      nvg_path += "?sid=" + search_id
    Backbone.history.navigate(nvg_path, true)
    MagicOrders.original_path = window.location.hash

  closeCheckAll: (e) ->
    $('.trade_check').removeAttr('checked')
    $('#op-toolbar .dropdown-menu').parents('div.btn-group').removeAttr('style')

  CheckAll: (e) ->
    $('.trade_check').attr('checked', 'checked')
    $('#op-toolbar .dropdown-menu').parents('div.btn-group').css('display', 'none')
    $('#op-toolbar .batch_ops').show()
  
  optAll: (e) ->
    if $('.header #checkbox_all')[0].checked
      @CheckAll()
    else
      @closeCheckAll()
  
  optCopyAll: (e) ->
    if $('.header-copy #checkbox_all')[0].checked
      $('.header #checkbox_all')[0].checked = true
      @CheckAll()
    else
      $('.header #checkbox_all')[0].checked = false
      @closeCheckAll()

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
        html += '<td>' + trade.batch_num + '</td>'
        html += '<td>' + trade.serial_num + '</td>'
        html += '<td>' + trade.name + '</td>'
        html += '<td>' + trade.address + '</td></tr>'

      bind_swf(tmp, 'ffd', '')
      $('#logistic_select').hide()
      $('.deliver_count').html(data.length)
      $('#print_delivers_tbody').html(html)
      $('#print_delivers').on 'hidden', ()->
        # if MagicOrders.hasPrint == true
        #   $.get '/trades/batch-print-deliver', {ids: MagicOrders.idCarrier}
        MagicOrders.hasPrint = false

      $('#print_delivers').modal('show')

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

  # 加载更多订单
  forceLoadMoreTrades: (e) =>
    e.preventDefault()
    blocktheui()

    MagicOrders.trade_reload_limit = parseInt $('#load_count').val()
    @collection.fetch data: {trade_type: @trade_type, limit: MagicOrders.trade_reload_limit, offset: @offset, search: @search_hash, deliver_bill_search: @deliver_bill_search_hash}, success: (collection) =>
      if collection.length >= 0
        @offset = @offset + MagicOrders.trade_reload_limit
        @renderUpdate()
        $(e.target).val('')
      else
        $.unblockUI()

  ## 搜索相关 ##
  renderUpdate: =>
    @collection.each(@appendTrade)

    if @collection.length > 0
      $(".complete_offset").html(@collection.at(0).get("bills_count"))
      unless parseInt($(".complete_offset").html()) <= @offset
        $(".get_offset").html(@offset)
      else
        $(".get_offset").html($(".complete_offset").html())



    $.unblockUI()

  appendTrade: (trade) =>
    if $("#trade_#{trade.get('id')}").length == 0
      # MagicOrders.cache_trade_number = 0
      # @trade_number += 1
      view = new MagicOrders.Views.DeliverBillsRow(model: trade)
      $(@el).find("#trade_rows").append(view.render().el)
      #$(@el).find("#trade_#{trade.get('id')} td:first").html("#{@trade_number}")

  search: (e) ->
    e.preventDefault()

    search_hash = {}
    deliver_bill_search_hash = {}
    @simple_search_option = $('.search_option').children('option:selected').val()
    @simple_search_value = $(".search_value").val()
    @search_logistic = $(".search_logistic").val()

    if @simple_search_option != ''
      if @simple_search_option == 'logistic_name'
        search_hash[@simple_search_option] = @search_logistic
      else
        if @simple_search_value != ''
          search_hash[@simple_search_option] = @simple_search_value

    length = $('.search_tags_group').children().find('input').length
    if length != 0
      $('.search_tags_group').children().find('input').each ->
        if $(this).parent('span').attr('id') != "batch_search_tag"
          name = $(this).attr('name')
          value = $(this).val()
          search_hash[name] = value
        else
          name = $(this).attr('name')
          value = $(this).val()
          deliver_bill_search_hash[name] = value

    @deliver_bill_search_hash = deliver_bill_search_hash
    @search_hash = search_hash
    @offset = 0
    blocktheui()
    $("#trade_rows").html('')

    @collection.fetch data: {search: search_hash, deliver_bill_search: deliver_bill_search_hash}, success: (collection) =>
      if collection.length > 0
        @offset = @offset + 20
        @trade_number = 0
        @renderUpdate()
        $.unblockUI()
      else if collection.length == 0
        $(@el).find(".get_offset").html(@offset)
        $(@el).find(".complete_offset").html("0")
        $.unblockUI()

  loadStatusCount:()->
    $("[data-trade-status]",@el).each ->
      self = this
      coll = null
      trade_mode = $(this).data("trade-mode")
      trade_type = $(this).data("trade-status")
      switch trade_mode
        when "trades"
          coll = new MagicOrders.Collections.Trades()
        when "deliver_bills"
          coll = new MagicOrders.Collections.DeliverBills()
        when "logistic_bills"
          coll = new MagicOrders.Collections.DeliverBills()

      coll.fetch  data:{trade_type:trade_type,limit:1}, success: (collection, response)->
        count = 0
        if(collection.length > 0)
          count = collection.models[0].get("trades_count") || collection.models[0].get("bills_count")
        $("em",self).text("("+count+")")

