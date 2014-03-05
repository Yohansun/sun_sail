class MagicOrders.Views.TradesSetupLogistic extends Backbone.View

  template: JST['trades/setup_logistic']

  events:
    "click .save": 'save'
    "change #set_logistic_select": 'set_logistic_id'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    logistic_name = @model.get('logistic_name')
    $.get '/logistics/logistic_templates', {trade_id: @model.get("id")}, (t_data)->
      html_options = ''
      for item in t_data
        if logistic_name == item.name
          html_options += '<option selected="selected" lid="' + item.id + '" service_logistic_id="' + item.service_logistic_id + '" value="' + item.xml + '">' + item.name + '</option>'
        else
          html_options += '<option lid="' + item.id + '" service_logistic_id="' + item.service_logistic_id + '" value="' + item.xml + '">' + item.name + '</option>'
      $('#set_logistic_select').html(html_options)
      service_logistic_id = $("#set_logistic_select").find("option:selected").attr("service_logistic_id")
      $("#set_service_logistic_id").val(service_logistic_id)

    this

  save: ->
    flag = $("#set_logistic_select").find("option:selected").html() in ['其他', '虹迪', '雄瑞']
    lid = $('#set_logistic_select').find("option:selected").attr('lid')
    service_logistic_id = $('#set_service_logistic_id').val()

    waybill = $('.waybill').val()
    if (service_logistic_id == '' || service_logistic_id == 'null') && (@model.get('trade_type') != "CustomTrade" && @model.get('trade_type') != "Trade")
      alert '物流商ID不能为空'
      return

    unless flag
      if waybill == ''
        alert('运单号不能为空')
        return

      unless /^\w+$/.test(waybill)
        alert('输入物流单号不符合规则')
        return

    new_model = new MagicOrders.Models.Trade(id: @model.id)
    new_model.save {operation: "设置物流信息", logistic_id: lid, logistic_waybill: waybill, setup_logistic: true, service_logistic_id: service_logistic_id}, success: (model, response)->
      view = new MagicOrders.Views.TradesRow(model: model)
      $("#trade_#{model.get('id')}").replaceWith(view.render().el)
      view.reloadOperationMenu()
      $('#trade_setup_logistic').modal('hide')

  set_logistic_id: ->
    service_logistic_id = $("#set_logistic_select").find("option:selected").attr("service_logistic_id")
    $("#set_service_logistic_id").val(service_logistic_id)
