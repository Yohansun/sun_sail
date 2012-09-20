class MagicOrders.Views.SellersIndex extends Backbone.View

  template: JST['sellers/index']

  events:
    'click .browse_children': 'browse_children'
    'click .preview_children': 'preview_children'
    'click .edit_seller': 'edit_seller'
    'click .close_seller': 'close_seller'
    'click #new_seller': 'new_seller'
    'click #seller_search': 'search'
    'click #search_users': 'search_users'
    'click #user_setting': 'user_setting'
    'click .check_user': 'check_user'
    'click .remove_user': 'remove_user'
    'click .goto_stock': 'goto_stock'
    'click .open_stock': 'open_stock'

  initialize: ->
    @collection.on("reset", @render, this)

  render: =>
    $(@el).html(@template())
    @collection.each(@appendSeller)
    this

  appendSeller: (seller) =>
    if $("#seller_#{seller.get('id')}").length == 0
      view = new MagicOrders.Views.SellersRow(model: seller)
      $(@el).find("#seller_rows").append(view.render().el)

  new_seller: (event) ->
    event.preventDefault()
    parent_id = $('.parent_id').val()
    if parent_id == ''
      parent_id = 0
    Backbone.history.navigate("sellers/#{parent_id}/new", true)

  browse_children: (event) ->
    event.preventDefault()
    id = $(event.target).data("id")
    Backbone.history.navigate("sellers/#{id}", true)

  edit_seller: (event) ->
    event.preventDefault()
    id = $(event.target).data("id")
    Backbone.history.navigate("sellers/#{id}/edit", true)

  close_seller: (event) ->
    event.preventDefault()
    id = $(event.target).data("id")
    @model = new MagicOrders.Models.Seller(id: id)
    @model.save {'active'}, success: (model, response) =>
      location.reload()

  preview_children: (event) ->
    event.preventDefault()
    id = $(event.currentTarget).data('id')
    $.get('/api/sellers/' + id + '/children.json', {}, (data) ->
      html = ''
      for x in data
        html += "<li><a>" + x.name + "</a></li>"

        for c in x.child_names
          html += "<li class='pad15'><a>" + c + "</a></li>"

      html = '<li><a>无下级经销商</a></li>' if html == ''

      $('#children_' + id).html(html)
    )

  search: (event) ->
    event.preventDefault()
    @collection.fetch data: {key: $('#search_key').val(), value: $('#search_value').val()}, success: (collection, response) =>
      view = new MagicOrders.Views.SellersIndex(collection: collection)
      $('#content').html(view.render().el)

  search_users: (event) ->
    event.preventDefault()
    name = $('#search_users_input').val();
    collection = new MagicOrders.Collections.Users()
    collection.fetch data: {name: name}, success: (collection, response) =>
      view = new MagicOrders.Views.SellersUserList(collection: collection)
      $('#user_list').html(view.render().el)

  user_setting: (event) ->
    id = $(event.target).data("id")
    $('#seller_id_container').html(id)
    collection = new MagicOrders.Collections.Users()
    collection.fetch data: {seller_id: id}, success: (collection, response) =>
      view = new MagicOrders.Views.SellersUserTable(collection: collection)
      $('#user_table').html(view.render().el)

  check_user: (event) ->
    id = $(event.target).data("id")
    @model = new MagicOrders.Models.Seller(id: $('#seller_id_container').html())
    @model.save {user_id: id, method: 'add'}, 
      success: (model, response) =>
        user = new MagicOrders.Models.User(id: id)
        user.fetch success: (model, response) =>
          $(event.target).parent().remove()
          html = "<tr id='" + id + "'>"
          html += '<td>' + user.get('id') + '</td>'
          html += '<td>' + user.get('name') + '</td>'
          html += '<td>' + user.get('roles') + '</td>'
          html += '<td>' + user.get('active') + '</td>'
          html += "<td><a class='remove_user' href='javascript:void(0)' data-id='" + id + "'>删除</a></td>"
          html += '</tr>'
          $('#user_table table tbody').prepend(html)
      error: =>
        $(event.target).removeAttr('checked')

  remove_user: (event)->
    event.preventDefault()
    id = $(event.target).data("id");
    @model = new MagicOrders.Models.Seller(id: $('#seller_id_container').html())
    @model.save {user_id: id, method: 'remove'}, 
      success: (model, response) =>
        $('#' + id).remove()
      error: =>
        alert('服务器错误请稍后再试')

  goto_stock: (event) ->
    event.preventDefault()
    id = $(event.target).data("id");
    $('#storage_pop .seller_id_container').html(id)

  open_stock: (event) ->
    event.preventDefault()
    id = $('#storage_pop .seller_id_container').html()
    $('#storage_pop').modal('hide')
    @model = new MagicOrders.Models.Seller(id: id)
    @model.save {has_stock: true}, 
      success: (model, response) =>
        $(location).attr('pathname', "/sellers/#{id}/stocks")
      error: =>
        alert('fail')