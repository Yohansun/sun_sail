class MagicOrders.Views.TradesAddRef extends Backbone.View

  template: JST['trades/add_ref']

  events:
    'click .add_ref_sku' : 'addRefSku'
    'click .delete_ref_sku' : 'deleteRefSku'
    'click .request_add_ref': 'requestAddRef'
    'click .confirm_add_ref' : 'confirmAddRef'

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

  addRefSku: ->
    num = $('.add_ref_num').val()
    if num == ''
      alert("数量不能为空。")
    else if /^[1-9]{1}[0-9]*$/.test(num) != true
      alert("数量格式不正确。")
    else
      title = $(".skus_in_order option:selected").text()
      sku_id = $(".skus_in_order option:selected").val().split(";")[0]
      total_num = $(".skus_in_order option:selected").val().split(";")[1]
      sku_ids = $(".add_ref_table tr").map(->
        $(this).attr "id"
      ).get()
      if $.inArray(sku_id, sku_ids) != -1
        alert("已添加过商品")
        return
      tr = "<tr id='"+sku_id+"'><td>"+title+"</td>"
      tr += "<td>"+total_num+"</td>"
      tr += "<td>"+num+"</td>"
      tr += "<td><a class='btn delete_ref_sku'>删除</a></td></tr>"
      $('.add_ref_table').append(tr)

  deleteRefSku: (e)->
    $(e.currentTarget).parents('tr').remove()

  requestAddRef: ->
    payment = $('.ref_payment').val()
    if payment == ''
      alert("金额不能为空。")
    else if /^[0-9]+(\.[0-9]*)?$/.test(payment) != true
      alert("金额格式不正确。")
    else
      if $('.add_ref_table tr').length == 0
        alert("未添加补货商品")
      else
        blocktheui()

        add_ref_hash = {}
        ref_order_array = []
        ref_batch = {}
        length = $('.add_ref_table tr').length
        if length != 0
          for num in [0..(length-1)]
            sku_id = $(".add_ref_table tr:eq("+num+")").attr('id')
            title = $(".add_ref_table tr:eq("+num+")").find('td:eq(0)').text()
            num = $(".add_ref_table tr:eq("+num+")").find('td:eq(2)').text()
            ref_order_array.push sku_id+","+title+","+num


        ref_batch['ref_payment'] = payment
        ref_batch['ref_type'] = 'add_ref'
        ref_batch['status'] = 'request_add_ref'

        add_ref_hash['ref_order_array'] = ref_order_array
        add_ref_hash['ref_batch'] = ref_batch

        new_model = new MagicOrders.Models.Trade(id: @model.id)
        new_model.set({operation: "申请补货", add_ref_hash: add_ref_hash})
        new_model.save {},
          success: (model, response) =>
            $.unblockUI()

            view = new MagicOrders.Views.TradesRow(model: model)
            $("#trade_#{model.get('id')}").replaceWith(view.render().el)
            view.reloadOperationMenu()
            $('#trade_add_ref').modal('hide')
            items = model.check_operations()
            MagicOrders.enabled_operation_items = items
            menu_items = $('#op-toolbar').find('[data-type]')
            menu_items.each ->
              if $.inArray($(this).data('type')+'', MagicOrders.enabled_operation_items) is -1
                $(this).css('display', 'none')

          error: (model, error, response) =>
            $.unblockUI()
            alert("存储失败")

  confirmAddRef: ->
    new_model = new MagicOrders.Models.Trade(id: @model.id)
    new_model.save {operation: "确认补货", add_ref_status: 'confirm_add_ref'},
      success: (model, response) =>
        $.unblockUI()

        view = new MagicOrders.Views.TradesRow(model: model)
        $("#trade_#{model.get('id')}").replaceWith(view.render().el)
        view.reloadOperationMenu()
        $('#trade_add_ref').modal('hide')
        items = model.check_operations()
        MagicOrders.enabled_operation_items = items
        menu_items = $('#op-toolbar').find('[data-type]')
        menu_items.each ->
          if $.inArray($(this).data('type')+'', MagicOrders.enabled_operation_items) is -1
            $(this).css('display', 'none')

      error: (model, error, response) =>
        $.unblockUI()
        alert("存储失败")