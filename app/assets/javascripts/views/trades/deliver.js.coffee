class MagicOrders.Views.TradesDeliver extends Backbone.View

  template: JST['trades/deliver']

  events:
    'click  .deliver':              'deliver'
    "change #send_logistic_select": 'set_logistic_id'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    logistic_name = @model.get('logistic_name')
    $.get '/logistics/logistic_templates', {trade_id: @model.get("id")}, (t_data) =>
      html_options = ''
      for item in t_data
        if logistic_name == item.name
          html_options += '<option selected="selected" lid="' + item.id + '" service_logistic_id="' + item.service_logistic_id + '" value="' + item.xml + '">' + item.name + '</option>'
        else
          html_options += '<option lid="' + item.id + '" service_logistic_id="' + item.service_logistic_id + '" value="' + item.xml + '">' + item.name + '</option>'
      $('#send_logistic_select').html(html_options)
      service_logistic_id = $("#send_logistic_select").find("option:selected").attr("service_logistic_id")
      $("#service_logistic_id").val(service_logistic_id)
    this

  deliver: ->
    blocktheui()

    flag = $("#send_logistic_select").find("option:selected").html() in ['其他', '虹迪', '雄瑞']
    lid = $('#send_logistic_select').find("option:selected").attr('lid')
    service_logistic_id = $('#service_logistic_id').val()
    waybill = $('.send_waybill').val()

    if (service_logistic_id == '' || service_logistic_id == 'null') && (@model.get('trade_type') != "CustomTrade" && @model.get('trade_type') != "Trade")
      alert '物流商ID不能为空'
      return

    unless flag
      if waybill == ''
        $.unblockUI()
        alert('运单号不能为空')
        return

      unless /^\w+$/.test(waybill)
        $.unblockUI()
        alert('输入物流单号不符合规则')
        return

    new_model = new MagicOrders.Models.Trade(id: @model.id)
    new_model.save {operation: "订单发货", logistic_id: lid, logistic_waybill: waybill, delivered_at: true, logistic_info: $("#logistic_company").html(), setup_logistic: true, service_logistic_id: service_logistic_id},
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
          view.reloadOperationMenu()


        $('#trade_deliver').modal('hide')
        # window.history.back()

  set_logistic_id: ->
    service_logistic_id = $("#send_logistic_select").find("option:selected").attr("service_logistic_id")
    $("#service_logistic_id").val(service_logistic_id)
