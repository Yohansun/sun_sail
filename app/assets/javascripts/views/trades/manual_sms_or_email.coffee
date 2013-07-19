class MagicOrders.Views.TradesManualSmsOrEmail extends Backbone.View

  template: JST['trades/manual_sms_or_email']

  events:
    'click .save': 'save'

  initialize: ->
    @collection.on("fetch", @render, this)
    @all_has_seller = true
    self = this
    @collection.each (trade) ->
      if !trade.get("seller_id")
        self.all_has_seller = false
        return false

  render: ->
    html = @template(trades: @collection, all_has_saller: @all_has_seller)
    $(@el).html(html)
    this

  validate: ->
    title = $("#notify_theme").val().trim()
    content = $("#notify_content").val().trim()
    errors = []
    if title == ''
      errors.push("发送主题不能为空")
    if content == ''
      errors.push("发送内容不能为空")
    if errors.length > 0
      alert(errors.join("\n"))
      return false
    true

  save: ->
    if (!@validate())
      return
    blocktheui()
    # the logic is : save many trade with sms,
    # each save action done, check if all sms was sent
    # then close the dialog
    trades_sent_sms = []
    collection_size = @collection.length

    sent_trades_sms = (model)->
      trades_sent_sms.push model.id

      if trades_sent_sms.length == collection_size
        $.unblockUI()
        view = new MagicOrders.Views.TradesRow(model: model)
        $("#trade_#{model.get('id')}").replaceWith(view.render().el)
        checkedTradeRow(model.get('id'))
        $("a[rel=popover]").popover({placement: 'left', html:true})

        $('#trade_manual_sms_or_email').modal('hide')
        # window.history.back()
    @collection.each (trade) ->
      trade.set "operation", "发短信/邮件"
      trade.save {
      	'notify_sender': $("#notify_sender").val(),
      	'notify_receiver': $("#notify_receiver").val(),
      	'notify_theme': $("#notify_theme").val(),
      	'notify_content': $("#notify_content").val(),
      	'notify_type': $("#notify_type").val()

      }, success: (model, response) =>
        sent_trades_sms(model)

