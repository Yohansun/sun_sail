class MagicOrders.Views.LogisticBillsSetupLogistic extends Backbone.View

  template: JST['logistic_bills/setup_logistic']

  events:
    "click .save": 'save'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    $.get '/logistics/logistic_templates', {type: 'all'}, (t_data)->
      html_options = ''
      for item in t_data
        html_options += '<option lid="' + item.id + '" value="' + item.xml + '">' + item.name + '</option>'
      $('.set_logistic_waybill #logistic_select').html(html_options)
    this

  save: ->
    flag = $("#logistic_select").find("option:selected").html() in ['其他', '虹迪', '雄瑞']
    lid = $('#logistic_select').find("option:selected").attr('lid')
    waybill = $('.waybill').val()

    unless flag
      if waybill == ''
        alert('运单号不能为空')
        return

      unless /^\w+$/.test(waybill)
        alert('输入物流单号不符合规则')
        return

    new_model = new MagicOrders.Models.Trade(id: @model.id)
    new_model.set({operation: "设置物流信息", logistic_id: lid, logistic_waybill: waybill, setup_logistic: true})
    new_model.save {}, success: (model, response) =>
      $('#logistic_bill_setup_logistic').modal('hide')
