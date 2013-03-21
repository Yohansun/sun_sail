class MagicOrders.Views.TradesRow extends Backbone.View

  tagName: 'tr'

  className: ()=>
     @model.get('unusual_color_class')

  template: JST['trades/row']

  events:
    'click .trade_pops li a[data-type]': 'show_type'
    'click .pop_detail' : 'show_type'
    'click .gift_trade_pop': 'showTrade'
    'click a[rel=popover]': "addHover"
    'click': 'highlight'
    'click input.trade_check': 'toggleOperationMenu'

  initialize: ->

  render: ->
    if $("tr#trade_#{@model.get('id')}").hasClass('notice_tr')
      $(@el).addClass('notice_tr')

    $(@el).attr("id", "trade_#{@model.get('id')}")
    $(@el).html(@template(trade: @model))

    $(@el).find(".trade_pops li").hide()
    for pop in MagicOrders.trade_pops[MagicOrders.trade_mode]
      unless MagicOrders.role_key == 'admin'
        if pop in MagicOrders.trade_pops[MagicOrders.role_key]
          $(@el).find(".trade_pops li [data-type=#{pop}]").parent().show()
      else
        $(@el).find(".trade_pops li [data-type=#{pop}]").parent().show()

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

  # renderUpdate: =>
  #   @collection.each(@appendTrade)

  #   if @collection.length > 0
  #     $(".complete_offset").html(@collection.at(0).get("trades_count"))
  #     unless parseInt($(".complete_offset").html()) <= @offset
  #       $(".get_offset").html(@offset)
  #     else
  #       $(".get_offset").html($(".complete_offset").html())

  #     $("a[rel=popover]").popover({placement: 'left', html:true})

  #   $.unblockUI()

  # appendTrade: (trade) =>
  #   if $("#trade_#{trade.get('id')}").length == 0
  #     MagicOrders.cache_trade_number = 0
  #     @trade_number += 1
  #     view = new MagicOrders.Views.TradesRow(model: trade)
  #     $(@el).find("#trade_rows").append(view.render().el)
  #     $(@el).find("#trade_#{trade.get('id')} td:first").html("#{@trade_number}")

  showTrade: (e) ->
    e.preventDefault()
    if @model.get("tid").slice(-2, -1) == "G"
      $('.search_value').val(@model.get("tid").slice(0,-2))
    else
      $('.search_value').val($.trim($(e.currentTarget).text()))
    $('#simple_search_button').click()


  highlight: (e) =>
    $("#trades_table tr").removeClass 'info'
    $(@el).addClass 'info'

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

  toggleOperationMenu: (e) ->
    $('#op-toolbar .dropdown-menu').parents('div.btn-group').removeAttr('style')
    if $('#all_orders input.trade_check:checked').length > 1
      $('#op-toolbar .dropdown-menu').parents('div.btn-group').css('display', 'none')
    else
      trade = $('#all_orders input.trade_check:checked')[0]
      if trade
        $('#op-toolbar .dropdown-menu').removeAttr('style')
        $('#op-toolbar').find('[data-type]').each ->
          $(this).removeAttr('style')

        tradeId = $(trade).parents('tr').attr('id').split('trade_')[1]
        checkedItem = new MagicOrders.Models.Trade(id: tradeId)
        checkedItem.fetch success: (model, response) =>
          menu_items = $('#op-toolbar').find('[data-type]')
          items = model.check_operations()
          console.log model.attributes.id, items
          MagicOrders.enabled_operation_items = items
          menu_items.each ->
            if $.inArray($(this).data('type')+'', MagicOrders.enabled_operation_items) is -1
              $(this).css('display', 'none')

          $('#op-toolbar .dropdown-menu').each ->
            if $(this).find('li a[style]').length is $(this).find('li a').length
              $(this).parents('div.btn-group').css('display', 'none')

      else
        $('#op-toolbar .dropdown-menu').removeAttr('style')
        $('#op-toolbar').find('[data-type]').each ->
          $(this).removeAttr('style')
