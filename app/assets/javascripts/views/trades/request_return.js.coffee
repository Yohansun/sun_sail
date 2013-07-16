class MagicOrders.Views.TradesRequestReturn extends Backbone.View

  template: JST['trades/request_return']

  events:
    'click .save': 'save'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  save: ->
    blocktheui()
    @model.set "operation", "申请退货"
    @model.save 'request_return_at', true, success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesRow(model: model)
      $("#trade_#{model.get('id')}").replaceWith(view.render().el)
      checkedTradeRow(model.get('id'))
      $("a[rel=popover]").popover({placement: 'left', html:true})

      $('#trade_request_return').modal('hide')