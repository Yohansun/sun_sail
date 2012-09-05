class MagicOrders.Views.UsersEdit extends Backbone.View

  template: JST['users/edit']

  render: ->
    $(@el).html(@template(user: @model))
    this

  events:
    'click .edit': 'save'

  save: (e) ->
    e.preventDefault()
    blocktheui()

    unless @model.set("username": $("#user_username").val())
      $.unblockUI()
      alert("用户名不能为空")     
      return

    unless @model.set("name": $("#user_name").val())
      $.unblockUI()
      alert("姓名不能为空")     
      return

    if $("#user_password").val() != ''
      @model.set("password": $("#user_password").val())
      @model.set("password_confirmation": $("#user_password_confirmation").val())

    unless @model.set("email": $("#user_email").val()) and (/^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)$/.test($("#user_email").val()))
      $.unblockUI()
      alert("Email为空或格式不正确")      
      return

    @model.set('is_support', $('#role_support').attr('checked') == 'checked')
    @model.set('is_seller', $('#role_seller').attr('checked') == 'checked')
    @model.set('is_interface', $('#role_interface').attr('checked') == 'checked')
    @model.set('is_stock_admin', $('#role_stock_admin').attr('checked') == 'checked')

    @model.save {},
      success: (model, response) =>
        $.unblockUI()
        alert("修改成功!")
        Backbone.history.navigate('users', true)
      error: ->
        $.unblockUI()
        return
