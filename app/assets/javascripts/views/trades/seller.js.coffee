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
    view = new MagicOrders.Views.AreasInputs(order_id: @model.get('id'), states: states, state: @model.get('receiver_state'), city: @model.get('receiver_city'), district: @model.get('receiver_district'))

    $(@el).find('#areas_inputs').html(view.render().el)

  set_seller: ->
    blocktheui()
    if $("#trade_seller_id").val() > 0
      @model.set "operation", "订单分派"
      @model.set {seller_id: $("#trade_seller_id").val()}, success: (model, response) =>
        $.unblockUI()
        view = new MagicOrders.Views.TradesRow(model: model)
        $("#trade_#{model.get('id')}").replaceWith(view.render().el)
        view.reloadOperationMenu()
        $("a[rel=popover]").popover({placement: 'left', html:true})

        $('#trade_seller').modal('hide')
        # window.history.back()

  reset_seller: ->
    blocktheui()
    @model.set "operation", "分派重置"
    @model.set 'seller_id', "void", success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesRow(model: model)
      $("#trade_#{model.get('id')}").replaceWith(view.render().el)
      view.reloadOperationMenu()
      $("a[rel=popover]").popover({placement: 'left', html:true})

      $('#trade_seller').modal('hide')
      # window.history.back()
