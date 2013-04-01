class MagicOrders.Views.DeliverBillsRow extends Backbone.View

  tagName: 'tr'

  template: JST['deliver_bills/row']

  events:
    'click [data-type]': 'show_type'
    'click a[rel=popover]': "addHover"
    'click': 'highlight'
    'click input.trade_check': 'toggleOperationMenu'

  initialize: ->

  render: ->
    $(@el).attr("id", "trade_#{@model.get('id')}")
    $(@el).html(@template(bill: @model))

    if @model.get("has_unusual_state") is true
      $(@el).attr("class", "error")
    $(@el).find(".trade_pops li").hide()
    # for pop in MagicOrders.trade_pops[MagicOrders.trade_mode]
    #   unless MagicOrders.role_key == 'admin'
    #     if pop in MagicOrders.trade_pops[MagicOrders.role_key]
    #       $(@el).find(".trade_pops li [data-type=#{pop}]").parent().show()
    #   else
    #     $(@el).find(".trade_pops li [data-type=#{pop}]").parent().show()

    # reset cols
    # visible_cols = MagicOrders.trade_cols_visible_modes[MagicOrders.trade_mode]
    # for col in MagicOrders.trade_cols_keys
    #   if col in visible_cols
    #     $(@el).find("td[data-col=#{col}]").show()
    #   else
    #     $(@el).find("td[data-col=#{col}]").hide()
    # for col in MagicOrders.trade_cols_hidden[MagicOrders.trade_mode]
    #   $(@el).find("td[data-col=#{col}]").hide()

    # $("a[rel=popover]").popover(placement: 'left')

    # if MagicOrders.cache_trade_number != 0
    #   $(@el).find("td:first").html("#{MagicOrders.cache_trade_number}")
    this

  show_type: (e) ->
    e.preventDefault()
    type = $(e.target).data('type')
    Backbone.history.navigate('deliver_bills/' + @model.get("id") + "/#{type}", true)

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
    if $('#all_orders input.trade_check:checked').length > 1
      $('#op-toolbar .dropdown-menu').parents('div.btn-group').css('display', 'none')
      $('#op-toolbar .batch_ops').show()
    else
      $('#op-toolbar .dropdown-menu').parents('div.btn-group').removeAttr('style')
      $('#op-toolbar .batch_ops').css('display', 'none')
      trade = $('#all_orders input.trade_check:checked')[0]