class MagicOrders.Views.TradesRecover extends Backbone.View

  template: JST['trades/recover']

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
      $.get '/api/trades/' + @model.get('id') + '/recover', {}, (data) ->
        if data.is_success
          $('#trade_recover').modal('hide')
        else
          alert('合并失败')
    else
      console.log "false"
      $('#trade_recover').modal('hide')
