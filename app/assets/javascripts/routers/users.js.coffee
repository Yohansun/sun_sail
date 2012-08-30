class MagicOrders.Routers.Users extends Backbone.Router
  routes:
    'users': 'index'
    'users/new': 'new'
    'users/:id': 'show'
    'users/:id/edit': 'edit'
    
  initialize: ->
    @collection = new MagicOrders.Collections.Users()

  show_top_nav: ->
    $("#top-nav li").hide()
    $("#top-nav li.users").show()

  index: ->
    @show_top_nav()
    @collection.fetch()
    view = new MagicOrders.Views.UsersIndex(collection: @collection)
    $('#content').html(view.render().el)

  show:  (id) ->
    blocktheui()
    @model = new MagicOrders.Models.User(id: id)
    @model.fetch success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.UsersShow(model: model)
      $('#content').html(view.render().el)

  new: () ->
    @show_top_nav()
    @model= new MagicOrders.Models.User()
    view = new MagicOrders.Views.UsersNew(model: @model)
    $('#content').html(view.render().el)

  edit: (id) ->
    @show_top_nav()
    @model = new MagicOrders.Models.User(id: id)
    @model.fetch success: (model, response) =>
      view = new MagicOrders.Views.UsersEdit(model: @model)
      $('#content').html(view.render().el)