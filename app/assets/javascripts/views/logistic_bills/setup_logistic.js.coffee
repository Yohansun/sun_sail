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

    @model.set('logistic_id', lid)
    @model.set('logistic_waybill', waybill)
    @model.save {setup_logistic: true}, success: (model, response)->
      $('#logistic_bill_setup_logistic').modal('hide')
