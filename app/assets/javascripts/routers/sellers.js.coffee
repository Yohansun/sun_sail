class MagicOrders.Routers.Sellers extends Backbone.Router
  routes:
    'sellers': 'index'
    'sellers/new': 'new'
    'sellers/:id': 'show'
    'sellers/:id/edit': 'edit'
    'sellers/:id/history': 'history'

  initialize: ->
    @collection = new MagicOrders.Collections.Sellers()

  show_top_nav: ->
    $("#top-nav li").hide()
    $("#top-nav li.sellers").show()

  index: ->
    @show_top_nav()
    @collection.fetch()
    view = new MagicOrders.Views.SellersIndex(collection: @collection)
    $('#content').html(view.render().el)

  show: (id) ->
    @show_top_nav()
    @collection.fetch({data: {parent_id: id}})
    view = new MagicOrders.Views.SellersIndex(collection: @collection)
    $('#content').html(view.render().el)

  new: () ->
    @show_top_nav()
    @model= new MagicOrders.Models.Seller()
    view = new MagicOrders.Views.SellersNew(model: @model)
    $('#content').html(view.render().el)

  edit: (id) ->
    @show_top_nav()
    @model = new MagicOrders.Models.Seller(id: id)
    @model.fetch success: (model, response) =>
      view = new MagicOrders.Views.SellersEdit(model: @model)
      $('#content').html(view.render().el)

  history: (id) ->
    @show_top_nav()
    @model = new MagicOrders.Models.Seller(id: id)
    @model.fetch success: (model, response) =>
      view = new MagicOrders.Views.SellersHistory(model: @model)
      $('#content').html(view.render().el)

