class MagicOrders.Views.TradesUnsplited extends Backbone.View

  template: JST['trades/unsplit']

  events:
    'click .recover': 'recover'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  recover: (e) ->
    e.preventDefault()

    if confirm("提醒：合并订单，该订单的状态将恢复到原始状态，不保留任何记录!")
      $.get '/api/trades/' + @model.get('id') + '/recover_from_split', {}, (data) ->
        if data.is_success
          $('#trade_unsplited').modal('hide')
        else
          alert('合并失败')
    else
      console.log "false"
      $('#trade_unsplited').modal('hide')
