class MagicOrders.Views.TradesLogisticSplit extends Backbone.View

  template: JST['trades/logistic_split']

  events:
    "click .js-split" : 'split'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))

    $.get '/logistics/logistic_templates', {type: 'all', trade_type: @model.get('trade_type')}, (t_data)->
      html_options = ''
      for item in t_data
        html_options += '<option value="' + item.id + '">' + item.name + '</option>'

      $('.logistic_id').html(html_options)
    this

  split: (e)->
    e.preventDefault()
    blocktheui()
    logistic_ids = {}
    for item in $('table')
      logistic_ids[$(item).find('.bill_id').html()] = $(item).find('select').val()

    new_model = new MagicOrders.Models.Trade(id: @model.id)
    new_model.save {operation: "物流单拆分", logistic_ids: logistic_ids},
      success: (model, response) =>
        $.unblockUI()
        $('#trade_logistic_split').modal('hide')

      error: (model, error, response) =>
        $.unblockUI()
        alert("输入错误")
