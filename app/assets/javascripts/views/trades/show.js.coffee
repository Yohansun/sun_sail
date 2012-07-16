class MagicOrders.Views.TradesShow extends Backbone.View

  template: JST['trades/show']

  events:
    "click .button_print": 'print'

  initliaze: ->
    @model.on("change", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  print: (e) ->
    print_body = $(@el).find(".modal-body")
    print_body.wrapInner('<div class="print_content"></div>')
    print_body.children('.print_content').printArea()
