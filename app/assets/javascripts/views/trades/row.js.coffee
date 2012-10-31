class MagicOrders.Views.TradesRow extends Backbone.View

  tagName: 'tr'

  template: JST['trades/row']

  events:
    'click [data-type]': 'show_type'
    'click [data-type=trade_split]': 'show_split'
    'click a[rel=popover]': "addHover"
    'click': 'highlight'

  initialize: ->

  render: ->
    $(@el).attr("id", "trade_#{@model.get('id')}")
    $(@el).html(@template(trade: @model))
    if @model.get("has_unusual_state") is true
      $(@el).attr("class", "error")
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

    $("a[rel=popover]").popover(placement: 'left')
    this

  show_type: (e) ->
    e.preventDefault()
    type = $(e.target).data('type')
    if type isnt 'trade_split'
      Backbone.history.navigate('trades/' + @model.get("id") + "/#{type}", true)

  show_split: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trades/' + @model.get("id") + '/splited', true)

  addHover: (e) ->
    $(e.target).parent().toggleClass('lovely_pop')
    $('.popover.right').css('margin-left','-5px')
    $('.popover').mouseleave ->
      $('.lovely_pop').click()
      $(e.target).parent().toggleClass('lovely_pop')

  highlight: (e) =>
    $("#trades_table tr").removeClass 'info'
    $(@el).addClass 'info'