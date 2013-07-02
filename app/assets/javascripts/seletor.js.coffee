# <form class="simple-operation"></form>
# <a href="#" class="magic_detail" target_url="/users/:id/edit_with_role">编辑</a>
# <a href="#" class="magic_operation" id="delete_users" message="确认删除吗?" request="post" target_url="/users/delete">删除</a>
# <a href="#" class="magic_operation" message="确认开启吗?" request="post" target_url="/users/batch_update?operation=unlock">开启</a>
# <a href="#" class="magic_operation" message="确认禁用?" request="post" target_url="/users/batch_update?operation=lock">禁用</a>
$ ->
  checked_inputs = -> $(".table td input:checked")
  $(".magic_detail").click ->
    if checked_inputs().length < 1
      alert("请选择")
    else if checked_inputs().length > 1
      alert("请选择一个")
    else
      val = checked_inputs().last().val()
      action = $(this).attr("target_url")
      
      if action.match(/\?/) == null
        # /users/edit => /users/edit/
        action = action.replace(/(\/*)$/,'/')
      if action.match(/\:id/)
        # /users/:id/edit => /users/1/edit
        link = action.replace(/\:id/,val )
      else
        link = action + val
      window.location= link
      
  $(".magic_operation").click (e) ->
    if checked_inputs().length < 1
      e.stopImmediatePropagation()
      alert("请选择")
      return false
    else
      form = $("form.simple-operation")
      href = $(this).attr("href")
      action = $(this).attr("target_url")
      if action.match(/\?/) == null
        action = action.replace(/(\/*)$/,'/')
      method = $(this).attr("request")
      form.attr({action: action ,method: method })
      form.removeAttr("data-remote") if $(this).attr("data-remote") != "true"
      # Skip href #id
      if !href.match(/^#.+/)
        if ($(this).attr("message") && confirm($(this).attr("message")) || !$(this).attr("message"))
          form.submit()