class MagicOrders.Views.TradesMarkUnusualState extends Backbone.View
 
  template: JST['trades/mark_unusual_state']
 
  events:
    'click .save': 'save'
    'click .manage' : 'manage'
    'focus #other_state' : 'keep_pace_text'
    'click #other_radio' : 'keep_pace_radio'
 
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
    else if @reason is undefined
      $.unblockUI()
      alert("请选择异常")
      return

    for state in @model.get('unusual_states')
      if state.reason is @reason
        $.unblockUI()
        alert("异常已标注过")
        return

    @model.set "plan_repair_at", $("#plan_repair_at").val()
    @model.set "state_note", $("#state_note").val()
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

  manage: (event) ->
    blocktheui()

    id = $(event.target).data("id")
    @model.set "operation", "处理异常"
    @model.save {'state_id': id }, success: (model, response) =>
      $.unblockUI()
      view = new MagicOrders.Views.TradesRow(model: model)
      $("#trade_#{model.get('id')}").replaceWith(view.render().el)
      $('#trade_mark_unusual_state').modal('hide')

  keep_pace_text: ->
    $('#other_radio').attr("checked",true);

  keep_pace_radio: ->
    $('#other_state').focus();
    