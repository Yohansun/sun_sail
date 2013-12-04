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

  $(".magic_operation").live "click", ->
    if checked_inputs().length < 1 && $(this).attr("check") != "false"
      @stopImmediatePropagation
      alert("请选择")
      return false
    else
      form = $("form.simple-operation")
      href = $(this).attr("href")
      action = $(this).attr("target_url")
      if action.match(/\?/) == null
        action = action.replace(/(\/*)$/,'/')
      method = $(this).attr("request")
      if method == "put" || method == "delete"
        form.append('<input type="hidden" name="_method" value="' + method + '" />')
        method = "post"
      form.attr({action: action ,method: method })
      # Skip href #id
      if !href.match(/^#.+/)
        if ($(this).attr("message") && confirm($(this).attr("message")) || !$(this).attr("message"))
          if $(this).attr("data-remote") == "true"
            form.attr("data-remote",'true')
          else
            form.removeAttr("data-remote")
          form.submit()
  $(".edit_bill").live "click", ->
    if checked_inputs().length == 0
      alert("请选择")
      $("div#bill_options").removeClass("open")
      return false
    else if checked_inputs().length > 1
      alert("请选择一个")
      $("div#bill_options").removeClass("open")
      return false
    else
      bill_id = checked_inputs().last().val()
      if $("#bill_locked_"+bill_id).html() == "true"
        alert("该订单已锁定不能编辑")
        $("div#bill_options").removeClass("open")
        return false
      else if $.inArray($("#bill_status_"+bill_id).html(), ["CREATED", "CHECKED", "SYNCK_FAILED", "CANCELD_OK", "CANCELD_FAILED"]) == -1
        alert("该订单不能编辑")
        $("div#bill_options").removeClass("open")
        return false
      else
        action = $(this).attr("target_url")
        if action.match(/\?/) == null
          # /users/edit => /users/edit/
          action = action.replace(/(\/*)$/,'/')
        if action.match(/\:id/)
          # /users/:id/edit => /users/1/edit
          link = action.replace(/\:id/, bill_id )
        else
          link = action + bill_id
        window.location= link
  $(".bill_operation").live "click", ->
    if checked_inputs().length < 1
      $("div#bill_options").removeClass("open")
      alert("请选择")
      return false
    else
      canSubmit = true
      operation_name = $(this).html()
      if operation_name == "锁定"
        for item in checked_inputs()
          bill_id = $(item).val()
          if $.inArray($("#bill_status_"+bill_id).html(), ["CREATED", "CHECKED", "CANCELD_OK"]) == -1
            canSubmit = false
            error_message = "只能锁定状态为1.已审核，待同步. 2.待审核. 3.撤销同步成功"
            break
      else if $.inArray(operation_name, ["审核", "同步", "撤销","确认同步","确认入库","确认出库"]) > -1
        for item in checked_inputs()
          bill_id = $(item).val()
          bill_status = $("#bill_status_"+bill_id).html()
          if $("#bill_locked_"+bill_id).html()=="true"
            canSubmit = false
            error_message = "已锁定的库单不能" + operation_name
            break
          if operation_name=="审核" && bill_status!="CREATED"
            canSubmit = false
            error_message = "只有待审核的库单允许审核"
            break
          if operation_name=="同步" && bill_status!="CHECKED" && bill_status!="SYNCK_FAILED"
            canSubmit = false
            error_message = "只有已审核的库单允许同步"
            break
          if operation_name=="撤销" && bill_status!="SYNCKED"
            canSubmit = false
            error_message = "只有已同步待出/入库的库单允许撤销"
            break
          if operation_name=="确认同步" && bill_status!="SYNCKING"
            canSubmit = false
            error_message = "只能确认同步的状态为 '同步中'"
            break
          if (operation_name=="确认入库" || operation_name=="确认出库") && bill_status!="SYNCKED"
            canSubmit = false
            error_message = "只能操作确认入库的状态为 '已同步待出/入库'"
            break
      if canSubmit
        if confirm("确定要"+operation_name+"吗？")
          form = $("form.simple-operation")
          href = $(this).attr("href")
          action = $(this).attr("target_url")
          if action.match(/\?/) == null
            action = action.replace(/(\/*)$/,'/')
          method = $(this).attr("request")
          form.attr({action: action ,method: method })
          # Skip href #id
          if !href.match(/^#.+/)
            if ($(this).attr("message") && confirm($(this).attr("message")) || !$(this).attr("message"))
              if $(this).attr("data-remote") == "true"
                form.attr("data-remote",'true')
              else
                form.removeAttr("data-remote")
              form.submit()
          $("div#bill_options").removeClass("open")
        else
          $("div#bill_options").removeClass("open")
          return false
      else
        $("div#bill_options").removeClass("open")
        alert(error_message)
        return false
