class MagicOrders.Views.TradesConfirmCheckGoods extends Backbone.View

  template: JST['trades/confirm_check_goods']

  events:
    'click .save': 'save'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  save: ->
    blocktheui()
    @model.set "operation", "确认验货"
    @model.save 'confirm_check_goods_at', true, success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesRow(model: model)
      $("#trade_#{model.get('id')}").replaceWith(view.render().el)
      $("a[rel=popover]").popover({placement: 'left', html:true})

      $('#trade_confirm_check_goods').modal('hide')
      #window.history.back()