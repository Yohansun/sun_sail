class MagicOrders.Views.TradesConfirmColor extends Backbone.View

  template: JST['trades/confirm_color']

  events:
    'click .save': 'save'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  save: ->
    blocktheui()
    @model.set "operation", "确认调色"
    @model.save 'confirm_color_at', true, success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesRow(model: model)
      $("#trade_#{model.get('id')}").replaceWith(view.render().el)
      checkedTradeRow(model.get('id'))
      $("a[rel=popover]").popover({placement: 'left', html:true})

      $('#trade_confirm_color').modal('hide')
      #window.history.back()

