class MagicOrders.Views.TradesBatchSetupLogistic extends Backbone.View

  template: JST['trades/batch_setup_logistic']

  events:
    "click .save": 'save'

  initialize: ->
    @collection.on("fetch", @render, this)
    @trades = @collection.map((trade)->
      return trade
    )
    @count = @trades.length

  render: ->
    $(@el).html(@template(trades: @trades))
    html_options = ''
    html_options += '此次共设置' + @count + '单物流信息'
    $(@el).find('#trade_count').html(html_options)
    $.get '/logistics/logistic_templates', {type: 'all', trade_type: @trades[0].attributes.trade_type}, (t_data)->
      html_options = ''
      for item in t_data
        html_options += '<option lid="' + item.id + '" service_logistic_id="' + item.service_logistic_id + '" value="' + item.xml + '">' + item.name + '</option>'
      $('#set_logistic_select').html(html_options)
    this

  save: ->
    service_logistic_id = $('#set_logistic_select').find("option:selected").attr("service_logistic_id")
    lid = $('#set_logistic_select').find("option:selected").attr('lid')
    for trade in @trades
      waybill = $('.waybill' + trade.get('tid')).val()
      if waybill == ''
        alert('运单号不能为空')
        return
      unless /^\w+$/.test(waybill)
        alert('输入物流单号不符合规则')
        return
      new_model = new MagicOrders.Models.Trade(id: trade.id)
      new_model.save {operation: "设置物流信息", logistic_id: lid, logistic_waybill: waybill, setup_logistic: true, service_logistic_id: service_logistic_id}, success: (model, response)->
        $('#trade_batch_setup_logistic').modal('hide')