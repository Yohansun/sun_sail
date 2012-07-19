class MagicOrders.Routers.Sellers extends Backbone.Router
  routes:
    'sellers': 'index'
    'sellers/:id': 'show'

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