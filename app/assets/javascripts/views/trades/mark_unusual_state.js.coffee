class MagicOrders.Views.TradesMarkUnusualState extends Backbone.View
 
  template: JST['trades/mark_unusual_state']
 
  events:
    'click .save': 'save'
    'click .manage' : 'manage'
 
  initialize: ->
    @model.on("fetch", @render, this)
 	
 	render: ->
 	  $(@el).html(@template(trade: @model))
 	  this
 	
  save: ->
    blocktheui()

    @reason = $('input[name=reason]:checked').val()
    if @reason is "其他"
      if $("#other_state").val() is ''
        $.unblockUI()
        alert("请填写异常信息")
        return
      else
        @reason = $("#other_state").val()

    for state in @model.get('unusual_states')
      if state.reason is @reason
        $.unblockUI()
        alert("异常已标注过")
        return
     	
    @model.set "operation", "标注异常"
    @model.save {'reason': @reason},
      success: (model, response) =>
        $.unblockUI()

        view = new MagicOrders.Views.TradesRow(model: model)
        $("#trade_#{model.get('id')}").replaceWith(view.render().el)
        $('#trade_mark_unusual_state').modal('hide')
      
      error: (model, error, response) =>
        $.unblockUI()
        alert("输入错误")

  manage: ->
    blocktheui()

    id = $(event.target).data("id")
    @model.set "operation", "处理异常"
    @model.save {'state_id': id }, success: (model, response) =>
      $.unblockUI()
      view = new MagicOrders.Views.TradesRow(model: model)
      $("#trade_#{model.get('id')}").replaceWith(view.render().el)
      $('#trade_mark_unusual_state').modal('hide')