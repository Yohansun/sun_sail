class MagicOrders.Views.TradesSetupLogistic extends Backbone.View

  template: JST['trades/setup_logistic']

  events:
    "click .save": 'save'
    "change #logistic_select": 'set_logistic_id'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    $.get '/logistics/logistic_templates', {type: 'all',trade_type: @model.get("trade_type")}, (t_data)->
      html_options = ''
      for item in t_data
        html_options += '<option lid="' + item.id + '" value="' + item.xml + '">' + item.name + '</option>'
      $('#logistic_select').html(html_options)

    this

  save: ->
    flag = $("#logistic_select").find("option:selected").html() in ['其他', '虹迪', '雄瑞']
    lid = $('#logistic_id').val()
    waybill = $('.waybill').val()
    if lid == '' || lid == 'null'
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
    new_model.save {operation: "设置物流信息", logistic_id: lid, logistic_waybill: waybill, setup_logistic: true}, success: (model, response)->
      view = new MagicOrders.Views.TradesRow(model: model)
      $("#trade_#{model.get('id')}").replaceWith(view.render().el)
      view.reloadOperationMenu()
      $('#trade_setup_logistic').modal('hide')

  set_logistic_id: ->
    logistic_id = $("#logistic_select").find("option:selected").attr("lid")
    $("#logistic_id").val(logistic_id)
