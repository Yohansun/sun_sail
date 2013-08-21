class MagicOrders.Views.LogisticBillsRow extends Backbone.View

  tagName: 'tr'

  template: JST['logistic_bills/row']

  events:
    'click [data-type]': 'show_type'
    'click a[rel=popover]': "addHover"
    'click': 'highlight'
    'click input.trade_check': 'freezeCheck'

  initialize: ->

  render: ->
    $(@el).attr("id", "trade_#{@model.get('id')}")
    $(@el).html(@template(bill: @model))

    if @model.get("has_unusual_state") is true
      $(@el).attr("class", "error")

    #reset cols
    visible_cols = MagicOrders.trade_cols_visible_modes[MagicOrders.trade_mode]
    for col in MagicOrders.trade_cols_keys
      if col in visible_cols
        $(@el).find("td[data-col=#{col}]").show()
      else
        $(@el).find("td[data-col=#{col}]").hide()
    for col in MagicOrders.trade_cols_hidden[MagicOrders.trade_mode]
      $(@el).find("td[data-col=#{col}]").hide()

    this

  show_type: (e) ->
    e.preventDefault()
    type = $(e.target).data('type')
    Backbone.history.navigate('logistic_bills/' + @model.get("id") + "/#{type}", true)

  highlight: (e) =>
    $("#trades_table tr").removeClass 'info'
    $(e.currentTarget).addClass 'info'
    if $(e.currentTarget).find('input').attr("checked") == 'checked'
      $(e.currentTarget).find('input').attr("checked", false)
      @toggleOperationMenu()
    else
      $(e.currentTarget).find('input').attr("checked", true)
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

  freezeCheck: (e) =>
    e.stopPropagation()
    $("#trades_table tr").removeClass 'info'
    $(@el).addClass 'info'
    @toggleOperationMenu()

  toggleOperationMenu: ->
    if $('#all_orders input.trade_check:checked').length > 1
      $('#op-toolbar .dropdown-menu').parents('div.btn-group').css('display', 'none')
      $('#op-toolbar .batch_ops').show()
    else if $('#all_orders input.trade_check:checked').length == 1
      if @model.get('delivered_at')
        $('#op-toolbar .index_pops').find('[data-type=setup_logistic]').hide()
      $('#op-toolbar .dropdown-menu').parents('div.btn-group').removeAttr('style')
      $('#op-toolbar .batch_ops').css('display', 'none')
      trade = $('#all_orders input.trade_check:checked')[0]
    else
      $('#op-toolbar .dropdown-menu').parents('div.btn-group').removeAttr('style')