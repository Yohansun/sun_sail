class MagicOrders.Views.TradesDeliver extends Backbone.View

  template: JST['trades/deliver']

  events:
    'click .deliver': 'deliver'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    $.get '/logistics/logistic_templates', {type: 'all'}, (t_data) =>
      html_options = ''
      for item in t_data
        if @model.get('logistic_company') == item.name
          html_options += '<option selected="selected" lid="' + item.id + '" value="' + item.xml + '">' + item.name + '</option>'
        else
          html_options += '<option lid="' + item.id + '" value="' + item.xml + '">' + item.name + '</option>'

      $('#send_logistic_select').html(html_options)
    this

  deliver: ->
    blocktheui()

    flag = $("#send_logistic_select").find("option:selected").html() in ['其他', '虹迪', '雄瑞']
    lid = $('#send_logistic_select').find("option:selected").attr('lid')
    waybill = $('.send_waybill').val()

    unless flag
      if waybill == ''
        $.unblockUI()
        alert('运单号不能为空')
        return

      unless /^\w+$/.test(waybill)
        $.unblockUI()
        alert('输入物流单号不符合规则')
        return

    @model.set('logistic_id', lid)
    @model.set('logistic_waybill', waybill)
    @model.set('delivered_at', true)
    @model.set "operation", "订单发货"
    @model.save {'logistic_info': $("#logistic_company").html(), setup_logistic: true},
      error: (model, error, response) ->
        $.unblockUI()
        alert(response)
      success: (model, response) ->
        $.unblockUI()
        if MagicOrders.trade_mode == 'send'
          $("#trade_#{model.get('id')}").remove()
        else
          view = new MagicOrders.Views.TradesRow(model: model)
          $("#trade_#{model.get('id')}").replaceWith(view.render().el)
          checkedTradeRow(model.get('id'))

        $("a[rel=popover]").popover({placement: 'left', html:true})
        $('#trade_deliver').modal('hide')
        # window.history.back()
