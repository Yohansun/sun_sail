class MagicOrders.Views.LogisticBillsIndex extends Backbone.View

  template: JST['logistic_bills/index']

  events:
    'click #checkbox_all': 'optAll'
    'click [data-trade-status]': 'selectSameStatusTrade'
    'click .print_logistics': 'printLogistics'
    'click .js-confirm-return': 'confirmReturn'
    'click .return_logistics': 'returnLogistics'
    'click .js-confirm-logistics': 'confirmLogistics'
    'click .index_pops li a[data-type]': 'show_type'

    # 加载更多订单相关
    'click [data-type=loadMoreTrades]': 'forceLoadMoreTrades'

    # 搜索相关
    'click .search': 'search'

  initialize: ->
    @offset = @collection.length
    @collection.on("fetch", @renderUpdate, this)

  render: =>
    $(@el).html(@template(bills: @collection))
    @collection.each(@appendTrade)
    $("a[rel=popover]").popover({placement: 'left', html:true})
    $(@el).find(".get_offset").html(@offset)
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
      $('#op-toolbar .dropdown-menu').parents('div.btn-group').css('display', 'none')
      $('#op-toolbar .batch_ops').show()
    else
      $('.trade_check').removeAttr('checked')
      $('#op-toolbar .dropdown-menu').parents('div.btn-group').removeAttr('style')

  prependTrade: (bill) =>
    view = new MagicOrders.Views.LogisticBillsRow(model: bill)
    $(@el).find("#trade_rows").prepend(view.render().el)

  printLogistics: (e)->
    e.preventDefault()

    tmp = []
    logistics = {}
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
        lname = trade.logistic_name
        lname = '无物流商' if lname == ''
        logistics[lname] = logistics[lname] || 0
        logistics[lname] += 1
        html += '<tr>'
        html += '<td>' + trade.tid + '</td>'
        html += '<td>' + trade.batch_sequence + '</td>'
        html += '<td>' + trade.batch_index + '</td>'
        html += '<td>' + trade.name + '</td>'
        html += '<td>' + trade.address + '</td></tr>'

      $.get '/logistics/logistic_templates', {}, (t_data)->
        html_options = ''
        for item in t_data
          html_options += '<option lid="' + item.id + '" value="' + item.xml + '">' + item.name + '</option>'

        $('#logistic_select').html(html_options)
        $('#logistic_select').show()
        bind_swf(tmp, 'kdd', $('#logistic_select').val())
        $('.deliver_count').html(data.length)
        $('#print_delivers_tbody').html(html)
        $('#logistic_select').attr('data-printType', 'logistic')
        $('#showbox').wrap("<div style='position:relative;width: 83px;height: 35px;float:right'></div>").after("<a class='print_button' href='javascript:;' style='position:absolute;left:0;top:0;width: 83px;height: 35px;z-index:1;'></a>")
        $('.print_button').click ()->
          dd = getElement('showbox')
          dd.startPrint()

        flag = true
        notice = '其中'
        for key, value of logistics
          notice += key + value + '单， '
          flag = false if value == 20

        $('#print_delivers .notice').html(notice) if flag = true
        $('#print_delivers').modal('show')

  returnLogistics: ->
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
    $('.logistic_count').html(length)
    MagicOrders.idCarrier = tmp

    logistics = {}
    $.get '/deliver_bills/deliver_list', {ids: tmp}, (data) ->
      for trade in data
        lname = trade.logistic_name
        lname = '无物流商' if lname == ''
        logistics[lname] = logistics[lname] || 0
        logistics[lname] += 1

      flag = ''
      notice = '其中'
      for key, value of logistics
        notice += key + value + '单'
        flag = key if value == tmp.length

      $.get '/logistics/logistic_templates', {type: 'all'}, (t_data)->
        html_options = ''
        for item in t_data
          html_options += '<option lid="' + item.id + '" value="' + item.xml + '">' + item.name + '</option>'

        $('#ord_logistics_billnum_mult .logistic_select').html(html_options)

        if flag == ''
          $('#ord_logistics_billnum_mult .info').html(notice)
        else
          $("#ord_logistics_billnum_mult option:contains('" + flag + "')").attr('selected', 'selected')

        $('#ord_logistics_billnum_mult').modal('show')

  confirmReturn: ->
    flag = $(".logistic_select").find("option:selected").html() in ['其他', '虹迪', '雄瑞']

    begin = $('.logistic_begin').val()
    end = $('.logistic_end').val()
    begin_pre = begin.slice(0, -4)
    begin_last_number = begin.slice(-4) * 1
    end_pre = end.slice(0, -4)
    end_last_number = end.slice(-4) * 1

    unless (!begin or !end) and flag
      unless /^\w+$/.test(begin) and /^\w+$/.test(end)
        alert('输入单号不符合规则')
        return

    unless flag
      if (end_last_number - begin_last_number + 1) != MagicOrders.idCarrier.length
        alert('物流单号与选中产品个数不匹配')
        return

    $.get '/deliver_bills/deliver_list', {ids: MagicOrders.idCarrier}, (data) ->
      html = ''
      for trade, i in data
        html += '<tr>'
        html += '<td class="tid">' + trade.tid + '</td>'
        html += '<td>' + trade.name + '</td>'
        html += '<td>' + trade.address + '</td>'
        if begin and end
          html += '<td class="logistic_bill">' + begin_pre + (begin_last_number + i) + '</td></tr>'
        else
          html += '<td class="logistic_bill"></td></tr>'

      $('#ord_logistics_billnum_mult2 tbody').html(html)
      $('#ord_logistics_billnum_mult').modal('hide')
      $('#ord_logistics_billnum_mult2').modal('show')

  confirmLogistics: ->
    bb = []
    a = $('#ord_logistics_billnum_mult2 tbody tr')
    a.each (i)->
      tid = $(a[i]).find('td.tid').html()
      logistic = $(a[i]).find('td.logistic_bill').html()
      h = {tid: tid, logistic: logistic}
      bb.push(h)

    $.get '/deliver_bills/setup_logistics', {data: bb, logistic: $('#ord_logistics_billnum_mult .logistic_select').find("option:selected").attr('lid')}, (data)->
      if data.isSuccess == true
        $('#ord_logistics_billnum_mult2').modal('hide')
      else
        alert('失败')

  show_type: (e) ->
    e.preventDefault()
    length = $('.trade_check:checked').parents('tr').length
    if length <= 1
      if length == 1
        trade_id = $('.trade_check:checked').parents('tr').attr('id').slice(6)
        type = $(e.target).data('type')
        MagicOrders.cache_trade_number = parseInt($('.trade_check:checked').parents('tr').children('td:first').html())
        Backbone.history.navigate('logistic_bills/' + trade_id + "/#{type}", true)
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

      $("a[rel=popover]").popover({placement: 'left', html:true})

    $.unblockUI()

  appendTrade: (trade) =>
    if $("#trade_#{trade.get('id')}").length == 0
      # MagicOrders.cache_trade_number = 0
      # @trade_number += 1
      view = new MagicOrders.Views.LogisticBillsRow(model: trade)
      $(@el).find("#trade_rows").append(view.render().el)
      # $(@el).find("#trade_#{trade.get('id')} td:first").html("#{@trade_number}")

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