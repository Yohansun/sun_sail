class MagicOrders.Views.TradesModifyReceiverInformation extends Backbone.View

  template: JST['trades/modify_receiver_information']

  events:
    'click .save': 'save'

  initialize: ->
    @model.on("fetch", @render, this)
    self = this

  render: ->
    html = @template(trade:@model)
    $(@el).html(html)
    view = new MagicOrders.Views.AreasSelectState({location:{state:@model.get("receiver_state"),city:@model.get("receiver_city"),district:@model.get("receiver_district")}})
    $(@el).find('#modify_receiver_select_state').html(view.render().el)

    $('#modify_receiver_form',@el).validate({
      rules:{
       name:{required:true}
       mobile:{required:true}
       address:{required:true}
       select_state:{required:true}
       select_city:{required:true}
       select_district:{required:true}
      }
      messages:{
       name:{required:"改名不能为空"}
       mobile:{required:"联系方式不能为空 "}
       address:{required:"详细地址不能为空 "}
       select_state:{required:"请选择省份"}
       select_city:{required:"请选择城市"}
       select_district:{required:"请选择区域"}
      }
      highlight: (element)  ->
        $(element).closest('.control-group').removeClass('success').addClass('error')
      success: (element) ->
       element
       .text('OK!').addClass('valid')
       .closest('.control-group').removeClass('error').addClass('success')
      errorPlacement: (error, element) ->
        element.closest('.control-group').find('span.help-inline').html(error.text())

    })

    this


  save: ->
    form = $("#modify_receiver_form")[0]
    if (!$(form).valid())
      return
    blocktheui()
    self = this
    @model.save {
     receiver_name:form["name"].value
     receiver_mobile:form["mobile"].value
     receiver_state:form["select_state"].value
     receiver_city:form["select_city"].value
     receiver_district:form["select_district"].value
     receiver_address:form["address"].value
    }, success: ->
      $.unblockUI()
      view = new MagicOrders.Views.TradesRow(model: self.model)
      $("#trade_"+self.model.get("id")).replaceWith(view.render().el)
      checkedTradeRow(self.model.get("id"))
      $("#trade_modify_receiver_information").modal("hide")


