class MagicOrders.Views.TradeSourcesShow extends Backbone.View

  template: JST['trade_sources/show']
  
  events:

  	'click [data-source=tmall]': 'show_tmall'
  	'click [data-source=taobao_market]': 'show_taobao_market'
  	'click .save': 'save'

  initialize: ->
    @model.on("fetch", @render, this)
      
  render: ->
    $(@el).html(@template(trade_source: @model))
    this

  show_tmall: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trade_sources/1', true)

  show_taobao_market: (e) ->
    e.preventDefault()
    Backbone.history.navigate('trade_sources/2', true)

  save: ->
    blocktheui()

    @model.set "app_key", $('#app_key').val()
    @model.set "secret_key", $('#secret_key').val()
    @model.set "session", $('#session').val()
    @model.set "fetch_quantity", $('#set_quantity').val()
    @model.set "fetch_time_circle", $('#set_time_circle').val()
    @model.set "high_pressure_valve", $('#set_valve_state').val()

    @model.save {}, success: (model, response) =>
      $.unblockUI()
      view = new MagicOrders.Views.TradeSourcesShow(model: model)

