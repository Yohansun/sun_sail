class MagicOrders.Views.UsersNew extends Backbone.View

  template: JST['users/new']

  events:
    'click .save': 'save'

  render: ->
    $(@el).html(@template(user: @model))
    this

  initialize: ->
    @model.on("fetch", @render, this)


  save: (e) ->
    e.preventDefault()
    blocktheui()

    unless @model.set("username": $('#user_username').val())
      $.unblockUI()
      alert("用户名不能为空")     
      return
        
    unless @model.set("name": $("#user_name").val())
      $.unblockUI()
      alert("经销商全称不能为空")     
      return

    unless @model.set("password": $("#user_password").val())
      $.unblockUI()
      alert("密码不能为空")     
      return

    unless @model.set("password_confirmation": $("#user_password_confirmation").val())
      $.unblockUI()
      alert("密码验证不能为空")     
      return

    unless @model.set("email": $("#user_email").val()) and (/^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)$/.test($("#user_email").val()))
      $.unblockUI()
      alert("Email为空或格式不正确")      
      return     

    @model.save {},
      success: (model, response) =>
        $.unblockUI()
        alert("添加成功!")
        Backbone.history.navigate('users', true)
      error: ->
        $.unblockUI()        
        return

