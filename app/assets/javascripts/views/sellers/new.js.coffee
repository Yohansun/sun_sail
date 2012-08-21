class MagicOrders.Views.SellersNew extends Backbone.View

  template: JST['sellers/new']

  events:
    'click .save': 'save'

  initialize: ->
    @model.on("fetch", @render, this)
      
  render: ->
    $(@el).html(@template(seller: @model))
    this 

  save: (e) ->
    e.preventDefault()
    blocktheui()

    unless @model.set("seller_name": $('#seller_name').val())
      $.unblockUI()
      alert("经销商简称不能为空")     
      return
        
    unless @model.set("seller_fullname": $("#seller_fullname").val())
      $.unblockUI()
      alert("经销商全称不能为空")     
      return
          
    unless @model.set("seller_mobile": $("#seller_mobile").val()) and (/^[0-9]*$/.test($("#seller_mobile").val()))
      $.unblockUI()
      alert("电话为空或格式不正确")
      return

    unless @model.set("seller_address": $("#seller_address").val())
      $.unblockUI()
      alert("地址不能为空")     
      return   

    unless @model.set("seller_email": $("#seller_email").val()) and (/^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)$/.test($("#seller_email").val()))
      $.unblockUI()
      alert("Email为空或格式不正确")      
      return     

    @model.save {},
      success: (model, response) =>
        $.unblockUI()
        alert("添加成功!")
        Backbone.history.navigate('sellers', true)
      error: ->
        $.unblockUI()        
        return
