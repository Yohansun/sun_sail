class MagicOrders.Views.TradesRefundRef extends Backbone.View

  template: JST['trades/refund_ref']

  events:
    'click .refund_ref_sku' : 'returnRefSku'
    'click .delete_ref_sku' : 'deleteRefSku'
    'click .request_refund_ref' : 'requestReturnRef'
    'click .confirm_refund_ref' : 'confirmSave'
    'click .cancel_refund_ref' : 'confirmSave'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    # 添加 sku options
    $(@el).find(".skus_in_order").empty()
    for order in @model.get('orders')
      for content in order.contents
        option = new Option(content.sku_title, content.sku_id+";"+(content.number*order.num))
        $(@el).find(".skus_in_order").append(option)

    this

  returnRefSku: ->
    num = $('.refund_ref_num').val()
    if num == ''
      alert("数量不能为空。")
    else if /^[1-9]{1}[0-9]*$/.test(num) != true
      alert("数量格式不正确。")
    else
      title = $(".skus_in_order option:selected").text()
      sku_id = $(".skus_in_order option:selected").val().split(";")[0]
      total_num = $(".skus_in_order option:selected").val().split(";")[1]
      if parseInt(num) > parseInt(total_num)
        alert('退款数量大于购买数量')
        return
      sku_ids = $(".refund_ref_table tr").map(->
        $(this).attr "id"
      ).get()
      if $.inArray(sku_id, sku_ids) != -1
        alert("已添加过商品")
        return
      tr = "<tr id='"+sku_id+"'><td>"+title+"</td>"
      tr += "<td>"+total_num+"</td>"
      tr += "<td>"+num+"</td>"
      tr += "<td><a class='btn delete_ref_sku'>删除</a></td></tr>"
      $('.refund_ref_table').append(tr)

  deleteRefSku: (e)->
    $(e.currentTarget).parents('tr').remove()

  requestReturnRef: ->
    payment = $('.refund_ref_payment').val()
    if payment == ''
      alert("金额不能为空。")
    else if /^[0-9]+(\.[0-9]*)?$/.test(payment) != true
      alert("金额格式不正确。")
    else if parseFloat(payment) >= parseFloat(@model.get('total_fee'))
      alert("退款金额大于等于购买金额。")
    else
      if $('.refund_ref_table tr').length == 0
        alert("未添加退款商品")
      else
        blocktheui()

        refund_ref_hash = {}
        ref_order_array = []
        current_order_array = []
        ref_batch = {}
        length = $('.refund_ref_table tr').length
        order_length = $('.skus_in_order').find('option').length
        if length != 0
          for num in [0..(length-1)]
            sku_id = $(".refund_ref_table tr:eq("+num+")").attr('id')
            title = $(".refund_ref_table tr:eq("+num+")").find('td:eq(0)').text()
            num = $(".refund_ref_table tr:eq("+num+")").find('td:eq(2)').text()
            ref_order_array.push sku_id+","+title+","+num

            for order in @model.get('orders')
              for content in order.contents
                if parseInt(content.sku_id) == parseInt(sku_id) && parseInt((content.number*order.num)) == parseInt(num)
                  current_order_array.push 1

          if order_length == current_order_array.length
            alert("全部退款订单请直接锁定。")
            $.unblockUI()
            return

        ref_batch['ref_payment'] = payment
        ref_batch['ref_type'] = 'refund_ref'
        ref_batch['status'] = 'request_refund_ref'
        refund_ref_hash['ref_memo'] = $('.ref_memo').val()
        refund_ref_hash['ref_order_array'] = ref_order_array
        refund_ref_hash['ref_batch'] = ref_batch

        new_model = new MagicOrders.Models.Trade(id: @model.id)
        new_model.save {operation: "申请线下退款", refund_ref_hash: refund_ref_hash},
          success: (model, response) =>
            $.unblockUI()

            view = new MagicOrders.Views.TradesRow(model: model)
            $("#trade_#{model.get('id')}").replaceWith(view.render().el)
            view.reloadOperationMenu()
            $('#trade_refund_ref').modal('hide')
            items = model.check_operations()
            MagicOrders.enabled_operation_items = items
            menu_items = $('#op-toolbar').find('[data-type]')
            menu_items.each ->
              if $.inArray($(this).data('type')+'', MagicOrders.enabled_operation_items) is -1
                $(this).css('display', 'none')

      $('#op-toolbar .dropdown-menu').each ->
        if $(this).find('li a[style]').length is $(this).find('li a').length
          $(this).parents('div.btn-group').css('display', 'none')

          error: (model, error, response) =>
            $.unblockUI()
            alert("存储失败")

  confirmSave: (e) ->
    status = $(e.currentTarget).attr('class').split(" ")[2]
    memo = $('.ref_memo').val()
    new_model = new MagicOrders.Models.Trade(id: @model.id)
    new_model.save {operation: "确认线下退款", refund_ref_status: status, refund_ref_memo: memo},
      success: (model, response) =>
        $.unblockUI()

        view = new MagicOrders.Views.TradesRow(model: model)
        $("#trade_#{model.get('id')}").replaceWith(view.render().el)
        view.reloadOperationMenu()
        $('#trade_refund_ref').modal('hide')
        items = model.check_operations()
        MagicOrders.enabled_operation_items = items
        menu_items = $('#op-toolbar').find('[data-type]')
        menu_items.each ->
          if $.inArray($(this).data('type')+'', MagicOrders.enabled_operation_items) is -1
            $(this).css('display', 'none')

      error: (model, error, response) =>
        $.unblockUI()
        alert("存储失败")