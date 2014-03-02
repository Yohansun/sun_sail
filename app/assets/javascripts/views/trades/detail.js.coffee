class MagicOrders.Views.TradesDetail extends Backbone.View

  template: JST['trades/detail']

  events:
    "click .button_print": 'print'
    'click button.js-big_window': 'zoomBig'
    'click button.js-small_window': 'zoomSmall'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    $('#myTab a:first').tab('show');
    $('div.modal-header h3 span').parents('.modal').removeClass('bigtoggle_parents');
    this

  print: (e) ->
    print_body = $(@el).find(".modal-body")
    print_body.wrapInner('<div class="print_content"></div>')
    print_body.children('.print_content').printArea()

    $('#trade_detail').modal('hide')

  zoomBig: (e) ->
    $(e.currentTarget).parents('.modal').addClass('bigtoggle_parents');

  zoomSmall: (e) ->
    $(e.currentTarget).parents('.modal').removeClass('bigtoggle_parents');