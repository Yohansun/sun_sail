class MagicOrders.Views.SellersIndex extends Backbone.View

  template: JST['sellers/index']

  events:
    'click .browse_children': 'browse_children'
    'click .preview_children': 'preview_children'
    'click .edit_seller': 'edit_seller'
    'click .close_seller': 'close_seller'
    'click #new_seller': 'new_seller'
    'click #seller_search': 'search'

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