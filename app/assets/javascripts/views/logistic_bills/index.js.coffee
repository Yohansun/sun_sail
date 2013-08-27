class MagicOrders.Views.LogisticBillsIndex extends Backbone.View

  template: JST['logistic_bills/index']

  events:
    'click #checkbox_all': 'optAll'
    'click [data-trade-status]': 'selectSameStatusTrade'
    'click .print_logistics': 'printLogistics'
    'click .confirm_return': 'confirmReturn'
    'click .return_logistics': 'returnLogistics'
    'click .confirm_logistics': 'confirmLogistics'
    'keydown #set_logistics_tbody input': 'enterReplaceTab'
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
    $("a[rel=popover]").popover({placement: 'left', html:true})
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
        lname = '无物流公司' if lname == ''
        logistics[lname] = logistics[lname] || 0
        logistics[lname] += 1
        html += '<tr>'
        html += '<td>' + trade.tid + '</td>'
        html += '<td>' + trade.batch_num + '</td>'
        html += '<td>' + trade.serial_num + '</td>'
        html += '<td>' + trade.name + '</td>'
        html += '<td>' + trade.address + '</td></tr>'

      $.get '/logistics/logistic_templates', {type: 'all'}, (t_data)->
        html_options = ''
        for item in t_data
          html_options += '<option lid="' + item.id + '" value="' + item.xml + '">' + item.name + '</option>'

        $('#logistic_select').html(html_options)
        $('#logistic_select').show()
        bind_swf(tmp, 'kdd', $('#logistic_select').val())
        $('.deliver_count').html(data.length)
        $('#print_delivers_tbody').html(html)
        $('#print_delivers').on 'hidden', ()->
          # if MagicOrders.hasPrint == true
          #   $.get '/trades/batch-print-logistic', {ids: MagicOrders.idCarrier, logistic: $("#logistic_select").find("option:selected").attr('lid')}
          MagicOrders.hasPrint = false

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
    $.get '/deliver_bills/logistic_waybill_list', {ids: tmp}, (data) ->
      html = ''
      for trade in data
        html += '<tr>'
        html += '<td nowrap>' + trade.tid + '</td>'
        html += '<td nowrap>' + trade.batch_num + '</td>'
        html += '<td nowrap>' + trade.serial_num + '</td>'
        html += '<td nowrap>' + trade.name + '</td>'
        html += '<td>' + trade.address + '</td>'
        html += '<td><input class="logistic_waybill" type="text"></td></tr>'

        $('#set_logistics_tbody').html(html)

        lname = trade.logistic_name
        lname = '无物流公司' if lname == ''
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

        $('#ord_logistics_billnum_mult').on 'shown', ->
          $("#set_logistics_tbody input:first").focus()

  enterReplaceTab: (e)->
    input = $(e.currentTarget).parents("tr").next().find("input:first")
    if e.which == 13
      e.preventDefault()
      if input.length > 0
        input.focus()
      else
        $(e.currentTarget).blur()

  confirmReturn: ->
    flag = $(".logistic_select").find("option:selected").html() in ['其他', '虹迪', '雄瑞']

    # begin = $('.logistic_begin').val()
    # end = $('.logistic_end').val()
    # begin_pre = begin.slice(0, -4)
    # begin_last_number = begin.slice(-4) * 1
    # end_pre = end.slice(0, -4)
    # end_last_number = end.slice(-4) * 1

    # unless (!begin or !end) and flag
    #   unless /^\w+$/.test(begin) and /^\w+$/.test(end)
    #     alert('输入单号不符合规则')
    #     return

    logistic_waybill_array = []
    $('#ord_logistics_billnum_mult').find('td .logistic_waybill').each ->
      if $(this).val() != "" && $(this).val() != undefined && $(this).val() != null
        logistic_waybill_array.push($(this).val())

      unless flag
        unless /^\w+$/.test($(this).val())
          alert('输入单号不符合规则')
          return

    unless flag
      if logistic_waybill_array.length != MagicOrders.idCarrier.length
        alert('物流单号与选中产品个数不匹配')
        return
      else
        unique_array = logistic_waybill_array.slice()
        if $.unique(unique_array).length != logistic_waybill_array.length
          diff_array = $.same(logistic_waybill_array).join(",")
          alert("有重复单号 "+diff_array+"，请检查")
          return

    unless flag
      logistic = $('#ord_logistics_billnum_mult .logistic_select').find("option:selected").attr('lid')
      $.get '/deliver_bills/verify_logistic_waybill', {data: logistic_waybill_array, logistic: logistic}, (data)->
        if data.existed_waybills
          waybills_msg = data.existed_waybills.join(", ")
          alert(waybills_msg+" 物流单号被使用过，请检查")
          return
        else
          $.get '/deliver_bills/logistic_waybill_list', {ids: MagicOrders.idCarrier}, (data) ->
            html = ''
            for trade, i in data
              html += '<tr>'
              html += '<td class="tid" nowrap>' + trade.tid + '</td>'
              html += '<td nowrap>' + trade.batch_num + '</td>'
              html += '<td nowrap>' + trade.serial_num + '</td>'
              html += '<td nowrap>' + trade.name + '</td>'
              html += '<td>' + trade.address + '</td>'
              if logistic_waybill_array[i] != undefined
                html += '<td class="logistic_bill">' + logistic_waybill_array[i] + '</td></tr>'
              else
                html += '<td class="logistic_bill"></td></tr>'
              # if begin and end
              #   html += '<td class="logistic_bill">' + begin_pre + (begin_last_number + i) + '</td></tr>'
              # else
              #   html += '<td class="logistic_bill"></td></tr>'

            $('#ord_logistics_billnum_mult2 tbody').html(html)
            $('#ord_logistics_billnum_mult').modal('hide')
            $('#ord_logistics_billnum_mult2').modal('show')
    else
      $.get '/deliver_bills/logistic_waybill_list', {ids: MagicOrders.idCarrier}, (data) ->
          html = ''
          for trade, i in data
            html += '<tr>'
            html += '<td class="tid" nowrap>' + trade.tid + '</td>'
            html += '<td nowrap>' + trade.batch_num + '</td>'
            html += '<td nowrap>' + trade.serial_num + '</td>'
            html += '<td nowrap>' + trade.name + '</td>'
            html += '<td>' + trade.address + '</td>'
            if logistic_waybill_array[i] != undefined
              html += '<td class="logistic_bill">' + logistic_waybill_array[i] + '</td></tr>'
            else
              html += '<td class="logistic_bill"></td></tr>'
            # if begin and end
            #   html += '<td class="logistic_bill">' + begin_pre + (begin_last_number + i) + '</td></tr>'
            # else
            #   html += '<td class="logistic_bill"></td></tr>'

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

    logistic = $('#ord_logistics_billnum_mult .logistic_select').find("option:selected").attr('lid')

    $.get '/deliver_bills/setup_logistics', {data: bb, logistic: logistic}, (data)->
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

