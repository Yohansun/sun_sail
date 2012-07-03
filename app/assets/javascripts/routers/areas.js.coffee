class MagicOrders.Routers.Areas extends Backbone.Router
  routes:
    'areas': 'index'
    'areas/:id': 'show'

  initialize: ->
    @collection = new MagicOrders.Collections.Areas()

  index: ->
    @collection.fetch()
    view = new MagicOrders.Views.AreasIndex(collection: @collection)
    $('#content').html(view.render().el)

  show: (id) ->
    @collection.fetch({data: {parent_id: id}})
    view = new MagicOrders.Views.AreasIndex(collection: @collection)
    $('#content').html(view.render().el)