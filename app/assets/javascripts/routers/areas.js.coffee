class MagicOrders.Routers.Areas extends Backbone.Router
  routes:
    'areas': 'index'
    'areas/:id': 'show'

  initialize: ->
    @collection = new MagicOrders.Collections.Areas()

  show_top_nav: ->
    $("#top-nav li").hide()
    $("#top-nav li.areas").show()

  index: ->
    @show_top_nav()
    @collection.fetch()
    view = new MagicOrders.Views.AreasIndex(collection: @collection)
    $('#content').html(view.render().el)

  show: (id) ->
    @show_top_nav()
    @collection.fetch({data: {parent_id: id}})
    view = new MagicOrders.Views.AreasIndex(collection: @collection)
    $('#content').html(view.render().el)