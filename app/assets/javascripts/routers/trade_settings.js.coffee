class MagicOrders.Routers.TradeSettings extends Backbone.Router
  
  routes:
    'trade_sources/:id': 'show'

  show: (id) ->
    blocktheui()
    @model = new MagicOrders.Models.TradeSource(id: id)
    @model.fetch success: (model, response) =>
      $.unblockUI()
      view = new MagicOrders.Views.TradeSourcesShow(model: @model)
      $('#content').html(view.render().el)