class MagicOrders.Views.TradesRow extends Backbone.View

  tagName: 'tr'

  template: JST['trades/row']

  events:
    'click [data-type]': 'show_type'
    'click [data-type=trade_split]': 'show_split'
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
    for col in MagicOrders.trade_cols_hidden
      $(@el).find("td[data-col=#{col}]").hide()
    for col in _.difference(_.keys(MagicOrders.trade_cols), MagicOrders.trade_cols_hidden)
      $(@el).find("td[data-col=#{col}]").show()

    this

  show_type: (e) ->
    e.preventDefault()
    type = $(e.target).data('type')
    if type isnt 'trade_split'
      Backbone.history.navigate('trades/' + @model.get("id") + "/#{type}", true)

  show_split: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trades/' + @model.get("id") + '/splited', true)

  highlight: (e) =>
    $("#trades_table tr").removeClass 'info'
    $(@el).addClass 'info'