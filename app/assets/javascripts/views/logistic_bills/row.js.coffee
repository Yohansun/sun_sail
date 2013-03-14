class MagicOrders.Views.LogisticBillsRow extends Backbone.View

  tagName: 'tr'

  template: JST['logistic_bills/row']

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

    this

  show_type: (e) ->
    e.preventDefault()
    type = $(e.target).data('type')
    Backbone.history.navigate('logistic_bills/' + @model.get("id") + "/#{type}", true)

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
      $('#op-toolbar .index_pops').css('display', 'none')
    else
      $('#op-toolbar .index_pops').removeAttr('style')
      trade = $('#all_orders input.trade_check:checked')[0]