class MagicOrders.Views.RevokeSplitTrade extends Backbone.View

  template: JST['trades/revoke_split_trade']

  events:
    'click .save' : 'save'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  save: (e) ->
    e.preventDefault()
    $.ajax '/api/trades/' + @model.id + '/revoke_split_trade',
      type:     'PUT'
      dataType: 'json'
      success: (data, textStatus, jqXHR) ->
        if data.success
          $('#revoke_split_trade').modal('hide')
          alert("撤销拆分成功")
        else
          alert("撤销拆分失败" + data.message)
          console.log(data)
      error: (jqXHR, textStatus, errorThrown)->
        console.log(jqXHR.status)