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

  save: (e) ->
    e.preventDefault()
    blocktheui()

    unless @model.set("app_key": $("#app_key").val()) and (/^[0-9]*$/.test($("#app_key").val()))
      $.unblockUI()
      alert("app_key为空或格式不正确")
      return

    unless @model.set("secret_key": $("#secret_key").val()) and (/^[a-z0-9]*$/.test($("#secret_key").val()))
      $.unblockUI()
      alert("secret_key为空或格式不正确")
      return

    unless @model.set("session": $("#session").val()) and (/^[a-z0-9]*$/.test($("#session").val()))
      $.unblockUI()
      alert("session为空或格式不正确")
      return

    @model.set "fetch_quantity", $('#set_quantity').val()
    @model.set "fetch_time_circle", $('#set_time_circle').val()
    @model.set "high_pressure_valve", $('#set_valve_state').val()

    @model.save {}, success: (model, response) =>
      $.unblockUI()
      alert("修改成功！")
      view = new MagicOrders.Views.TradeSourcesShow(model: model)