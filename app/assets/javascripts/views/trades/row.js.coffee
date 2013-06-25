class MagicOrders.Views.TradesRow extends Backbone.View

  tagName: 'tr'

  className: ()=>
     @model.get('unusual_color_class')

  template: JST['trades/row']

  events:
    'click .pop_detail' : 'show_type'
    'click .gift_trade_pop': 'showTrade'
    'click a[rel=popover]': "addHover"
    'click input.trade_check': 'freezeCheck'
    'click': 'highlight'


  initialize: ->
    @model.on("reset",@render, this)

  render: ->
    if $("tr#trade_#{@model.get('id')}").hasClass('notice_tr')
      $(@el).addClass('notice_tr')

    $(@el).attr("id", "trade_#{@model.get('id')}")
    $(@el).html(@template(trade: @model))

    # reset cols
    visible_cols = MagicOrders.trade_cols_visible_modes[MagicOrders.trade_mode]
    for col in MagicOrders.trade_cols_keys
      if col in visible_cols
        $(@el).find("td[data-col=#{col}]").show()
      else
        $(@el).find("td[data-col=#{col}]").hide()
    for col in MagicOrders.trade_cols_hidden[MagicOrders.trade_mode]
      $(@el).find("td[data-col=#{col}]").hide()

    $("a[rel=popover]").popover({placement: 'left', html:true})
    if MagicOrders.cache_trade_number != 0
      $(@el).find("td:first").html("#{MagicOrders.cache_trade_number}")
      #$(@el).find('.trade_check').attr("checked","checked")
    this

  show_type: (e) ->
    e.preventDefault()
    type = $(e.target).data('type')
    MagicOrders.cache_trade_number = parseInt($(@el).find("td:first").html())
    Backbone.history.navigate('trades/' + @model.get("id") + "/#{type}", true)

  showTrade: (e) ->
    e.preventDefault()
    if @model.get("tid").slice(-2, -1) == "G"
      $('.search_value').val(@model.get("tid").slice(0,-2))
    else
      $('.search_value').val($.trim($(e.currentTarget).text()))
    $('#simple_search_button').click()


  highlight: (e) ->
    $("#trades_table tr").removeClass 'info'
    $(e.currentTarget).addClass 'info'
    if $(e.currentTarget).find('input').attr("checked") == 'checked'
      $(e.currentTarget).find('input').attr("checked", false)
      @toggleOperationMenu()
    else
      $(e.currentTarget).find('input').attr("checked", true)
      @toggleOperationMenu()

  freezeCheck: (e) =>
    e.stopPropagation()
    $("#trades_table tr").removeClass 'info'
    $(@el).addClass 'info'
    @toggleOperationMenu()

  addHover: (e) ->
    $(e.target).parent().toggleClass('lovely_pop')
    $('.popover.right').css('margin-left','-5px')
    $('.popover_close_btn').remove()
    $('.popover-inner').append('<div class="popover_close_btn" href="#">X</div>')
    $('.popover').mouseleave ->
      $('.lovely_pop').click()
      $('.lovely_pop').toggleClass('lovely_pop')
    $('.popover_close_btn').click ->
      $('.lovely_pop').click()
      $('.lovely_pop').toggleClass('lovely_pop')

  toggleOperationMenu: ->
    $('#op-toolbar .dropdown-menu').parents('div.btn-group').removeAttr('style')
    if $('#all_orders input.trade_check:checked').length > 1
      $('#op-toolbar .dropdown-menu').parents('div.btn-group').css('display', 'none')
      $('#op-toolbar .batch_ops').show()
      $('#op-toolbar .batch_ops .dropdown-menu a').css('display', 'none')
      $('#op-toolbar .batch_ops .dropdown-menu  a[data-batch-operation]').css('display', '')
      $('#op-toolbar .batch_ops .dropdown-menu  a[data-batch-operation]').css('display', '')
      $('#op-toolbar .batch_ops .dropdown-menu  a[data-batch_type]').css('display', '')

    else if $('#all_orders input.trade_check:checked').length == 1
      # initial display all btns
      $('#op-toolbar .dropdown-menu').parents('div.btn-group').css('display', '')
      $('#op-toolbar .batch_ops .dropdown-menu a').css('display', '')

      trade = $('#all_orders input.trade_check:checked')[0]
      $('#op-toolbar .dropdown-menu').removeAttr('style')
      $('#op-toolbar').find('[data-type]').each ->
        $(this).removeAttr('style')

      if @model.collection == undefined
        selected_trade = new MagicOrders.Models.Trade(id: $(trade).parents('tr').attr('id').split('trade_')[1])
        selected_trade.fetch success: (model) =>
          items = selected_trade.check_operations()
          MagicOrders.enabled_operation_items = items
          menu_items = $('#op-toolbar').find('[data-type]')
          menu_items.each ->
            if $.inArray($(this).data('type')+'', MagicOrders.enabled_operation_items) is -1
              $(this).css('display', 'none')

          $('#op-toolbar .dropdown-menu').each ->
            if $(this).find('li a[style]').length is $(this).find('li a').length
              $(this).parents('div.btn-group').css('display', 'none')
      else
        selected_trade = @model.collection.get($(trade).parents('tr').attr('id').split('trade_')[1])
        items = selected_trade.check_operations()
        MagicOrders.enabled_operation_items = items
        menu_items = $('#op-toolbar').find('[data-type]')
        menu_items.each ->
          if $.inArray($(this).data('type')+'', MagicOrders.enabled_operation_items) is -1
            $(this).css('display', 'none')

        $('#op-toolbar .dropdown-menu').each ->
          if $(this).find('li a[style]').length is $(this).find('li a').length
            $(this).parents('div.btn-group').css('display', 'none')
    else
      MagicOrders.enabled_operation_items = MagicOrders.trade_pops[MagicOrders.trade_mode]
      $('#op-toolbar').find('[data-type]').each ->
        $(this).removeAttr('style')
      $('#op-toolbar .dropdown-menu').removeAttr('style')
      $('#op-toolbar .dropdown-menu').parents('div.btn-group').removeAttr('style')