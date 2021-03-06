class MagicOrders.Views.TradesSeller extends Backbone.View

  template: JST['trades/seller']

  events:
    'click .set_seller': 'set_seller'
    'click .reset_seller': 'reset_seller'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    if @model.get('seller_id') == null && (@model.get('trade_source') != '京东' && @model.get('trade_source') != '一号店')
      @render_area_inputs()
    else
      @estimate_dispatch()
    this

  render_area_inputs: ->
    states = new MagicOrders.Collections.Areas()
    states.fetch()
    view = new MagicOrders.Views.AreasInputs(order_id: @model.get('id'), states: states, state: @model.get('receiver_state'), city: @model.get('receiver_city'), district: @model.get('receiver_district'))

    $(@el).find('#areas_inputs').html(view.render().el)

  estimate_dispatch: ->
    $.get '/api/trades/' + @model.get('id') + '/estimate_dispatch', {}, (data)=>
      unless data.dispatchable
        $(@el).find('.dispatch_error').html(data.dispatch_error)
        $(@el).find('.dispatch_error').css('color', 'red')
        $(@el).find('.set_seller').hide()
      else
        $("#trade_seller_id").val(data.seller_id)
        $(@el).find('.set_seller').show()

  set_seller: ->
    blocktheui()
    if $("#trade_seller_id").val() > 0
      for order in @model.get('orders')
        if order.sku_bindings.length == 0 && order.local_sku_id == null
          alert("订单中有未绑定本地SKU的商品，请先绑定本地SKU")
          $.unblockUI()
          return
          break

      new_model = new MagicOrders.Models.Trade(id: @model.id)
      new_model.save {operation: "订单分派", seller_id: $("#trade_seller_id").val()}, success: (model, response) =>
        $.unblockUI()
        view = new MagicOrders.Views.TradesRow(model: model)
        $("#trade_#{model.get('id')}").replaceWith(view.render().el)
        view.reloadOperationMenu()


        $('#trade_seller').modal('hide')

  reset_seller: ->
    blocktheui()
    new_model = new MagicOrders.Models.Trade(id: @model.id)
    new_model.save {operation: "分派重置", seller_id: "void"}, success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesRow(model: model)
      $("#trade_#{model.get('id')}").replaceWith(view.render().el)
      view.reloadOperationMenu()


      $('#trade_seller').modal('hide')
