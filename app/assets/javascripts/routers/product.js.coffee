class MagicOrders.Routers.Products extends Backbone.Router
  routes:
    'products': 'index'
    'products/:id/new': 'new'
    'products/:id': 'show'
    'products/:id/edit': 'edit'

  initialize: ->
    @collection = new MagicOrders.Collections.Products()

  show_top_nav: ->
    $("#top-nav li").hide()
    $("#top-nav li.products").show()

  index: ->
    @show_top_nav()
    @collection.fetch()
    view = new MagicOrders.Views.ProductsIndex(collection: @collection)
    $('#content').html(view.render().el)

  show: (id) ->
    @show_top_nav()
    @collection.fetch({data: {parent_id: id}})
    view = new MagicOrders.Views.ProductsIndex(collection: @collection)
    $('#content').html(view.render().el)

  new: (id) ->
    @show_top_nav()
    @model= new MagicOrders.Models.Product()
    @model.set('parent_id', id)

    view = new MagicOrders.Views.ProductsNew(model: @model)
    $('#content').html(view.render().el)

  edit: (id) ->
    @show_top_nav()
    @model = new MagicOrders.Models.Product(id: id)
    @model.fetch success: (model, response) =>
      view = new MagicOrders.Views.ProductsEdit(model: model)
      $('#content').html(view.render().el)