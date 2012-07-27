class MagicOrders.Views.TradesSeller extends Backbone.View

  template: JST['trades/seller']

  events:
    'click .set_seller': 'set_seller'
    'click .reset_seller': 'reset_seller'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    @render_area_inputs() unless @model.get('seller_id') || @model.get('trade_source') == '京东'
    this

  render_area_inputs: ->
    states = new MagicOrders.Collections.Areas()
    states.fetch()
    view = new MagicOrders.Views.AreasInputs(states: states, state: @model.get('receiver_state'), city: @model.get('receiver_city'), district: @model.get('receiver_district'))

    $(@el).find('#areas_inputs').html(view.render().el)

  set_seller: ->
    if $("#trade_seller_id").val() > 0
      @model.save 'seller_id', $("#trade_seller_id").val()

  reset_seller: ->
    @model.save('seller_id', null)