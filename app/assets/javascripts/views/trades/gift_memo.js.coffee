class MagicOrders.Views.TradesGiftMemo extends Backbone.View

  template: JST['trades/gift_memo']

  events:
    'click .save': 'save'
    'click #add_gift_to_list' : 'add_gift'
    'click .delete_a_gift' : 'delete_gift'
    'change #select_category': 'change_product'
    'change #select_product' : 'change_sku'

  initialize: ->
    @model.on("fetch", @render, this)
    @has_sku = true

  render: ->
    $(@el).html(@template(trade: @model))
    this

  # 赠品三级联动
  change_product: ->
    category_id = $('#select_category').val()
    $('#select_product').select2('enable', false)
    $('#select_sku').select2('enable', false)
    $.get '/categories/product_templates', {category_id: category_id}, (p_data)->
      if p_data.length == 0
        alert("此分类下目前无商品")
      $('#select_product').val("")
      $('#select_sku').val("")
      $("#select_product").select2 data: p_data
      $('#select_sku').select2 data: []
      $('#select_product').select2('enable', true)
      $('#select_sku').select2('enable', true)

  change_sku: ->
    product_id = $('#select_product').val()
    $('#select_sku').select2('enable', false)
    $.get '/categories/sku_templates', {product_id: product_id}, (s_data)=>
      $('#select_sku').val("")
      $('#select_sku').select2 data: s_data
      $('#select_sku').select2('enable', true)

  add_gift: ->
    if $('#gift_list').find('tr:last td:first').text() == ''
      gift_num = 0
    else
      gift_num = parseInt($('#gift_list').find('tr:last td:first').text().slice(-1))
    gift_tid = @model.get('tid')+"G"+(gift_num+1)
    category_id = $("#select_category").val()
    product_id = $("#select_product").val()
    sku_id = $("#select_sku").val()
    num = $('#gift_num').val()

    if category_id == ""
      alert("请选择分类")
      return

    if product_id == ""
      alert("请选择商品")
      return

    if (sku_id == "" and @has_sku == true)
      alert("请选择SKU")
      return

    if num == ''
      alert("数量不能为空。")
      return

    if /^[1-9]{1}[0-9]*$/.test(num) != true
      alert("数量格式不正确。")
      return

    sku_ids = $("#gift_list tr").map(->
      if $(this).attr('style') != "display: none;"
        return $(this).attr "id"
    ).get()
    if $.inArray(sku_id, sku_ids) != -1
      alert("已添加过赠品")
      return

    product_name = $("#select_product").select2('data').text
    if $("#select_sku").select2('data') != null
      sku_name = $("#select_sku").select2('data').text
    else
      sku_name = ""
    gift_title = product_name + sku_name

    if $('#add_gift_tid').is(':checked')
      trade_tid = @model.get('tid')
      split_text = "拆分"
    else
      trade_tid = ''
      split_text = "不拆分"
    $('#gift_list').append("<tr id='"+sku_id+"' class='product_"+product_id+" new_add_gift'>"+
                           "  <td>"+gift_tid+"</td>"+
                           "  <td>"+gift_title+"</td>"+
                           "  <td>"+trade_tid+"</td>"+
                           "  <td>"+num+"</td>"+
                           "  <td>"+split_text+"</td>"+
                           "  <td><button class='btn delete_a_gift'>删除</button></td>"+
                           "</tr>")

  delete_gift: (e) ->
    e.preventDefault()
    $(e.currentTarget).closest('tr').hide()

  save: ->
    blocktheui()
    @add_gifts = {}
    @delete_gifts = []
    length = $('#gift_list').find('tr').length
    if length != 0
      for i in [0..(length-1)]
        $gift_info = $('#gift_list').find("tr:eq("+i+")")
        if $gift_info.attr('style') == "display: none;"
          gift_tid = $gift_info.children("td:eq(0)").text()
          @delete_gifts.push(gift_tid)
        else
          if $gift_info.attr('class').slice(-12) == "new_add_gift"

            sku_id = $gift_info.attr('id')
            product_id = $gift_info.attr('class').slice(8, -13)
            gift_tid = $gift_info.children("td:eq(0)").text()
            gift_title = $gift_info.children("td:eq(1)").text()
            if $gift_info.children("td:eq(2)").text() == ''
              trade_id = ''
            else
              trade_id = @model.get('id')
            num = $gift_info.children("td:eq(3)").text()
            @add_gifts[i] = {"sku_id": sku_id, "gift_tid": gift_tid, "gift_title": gift_title, "trade_id": trade_id, "product_id": product_id, "num": num}

    new_model = new MagicOrders.Models.Trade(id: @model.id)
    new_model.save {operation: "赠品修改", delete_gifts: @delete_gifts, add_gifts: @add_gifts, gift_memo: $("#gift_memo_text").val()},
      success: (model, response) =>
        $.unblockUI()

        view = new MagicOrders.Views.TradesRow(model: model)
        $("#trade_#{model.get('id')}").replaceWith(view.render().el)
        view.reloadOperationMenu()
        $("a[rel=popover]").popover({placement: 'left', html:true})
        $('#trade_gift_memo').modal('hide')

      error: (model, error, response) =>
        $.unblockUI()
        alert("操作频率过大")
        $('#trade_gift_memo').modal('hide')