class MagicOrders.Views.TradesManualSmsOrEmail extends Backbone.View

  template: JST['trades/manual_sms_or_email']
 
  events:
    'click .save': 'save'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  save: ->
    blocktheui()
    @model.set "operation", "发短信/邮件"
    @model.save {
    	'notify_sender': $("#notify_sender").val(), 
    	'notify_receiver': $("#notify_receiver").val(),
    	'notify_theme': $("#notify_theme").val(),
    	'notify_content': $("#notify_content").val(),
    	'notify_type': $("#notify_type").val()

    }, success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views.TradesRow(model: model)
      $("#trade_#{model.get('id')}").replaceWith(view.render().el)
      $("a[rel=popover]").popover({placement: 'left', html:true})

      $('#trade_manual_sms_or_email').modal('hide')
      # window.history.back()