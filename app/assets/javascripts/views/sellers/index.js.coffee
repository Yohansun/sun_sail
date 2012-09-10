class MagicOrders.Views.SellersIndex extends Backbone.View

  template: JST['sellers/index']

  events:
    'click .browse_children': 'browse_children'
    'click .preview_children': 'preview_children'
    'click .edit_seller': 'edit_seller'
    'click .close_seller': 'close_seller'
    'click #new_seller': 'new_seller'

  initialize: ->
    @collection.on("reset", @render, this)

  render: ->
    $(@el).html(@template(sellers: @collection))
    this

  new_seller: (event) ->
    event.preventDefault()
    parent_id = $('.parent_id').val()
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