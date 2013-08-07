class MagicOrders.Views.TradesBatchAddGift extends Backbone.View

  template: JST['trades/batch_add_gift']

  events:
    'click .save': 'save'
    'click #add_gift_to_list' : 'add_gift'
    'change #select_category': 'change_product'
    'change #select_product' : 'change_sku'

  initialize: ->
    @collection.on("fetch", @render, this)
    @has_sku = true
    @trade_ids = @collection.map((trade)->
      return trade.id
    )

  render: ->
    $(@el).html(@template(trades: @collection))
    this

  # 赠品三级联动
  change_product: ->
    category_id = $('#select_category').val()
    $.get '/categories/product_templates', {category_id: category_id}, (p_data)->
      if p_data.length == 0
        alert("此分类下目前无商品")
        $("#select_product").select2 data: []
        $('#select_sku').select2 data: []
      else
        $("#select_product").select2 data: p_data

  change_sku: ->
    product_id = $('#select_product').val()
    $.get '/categories/sku_templates', {product_id: product_id}, (s_data)=>
      if s_data.length == 0 or (s_data.length == 1 and s_data[0].text == "")
        $('#select_sku').select2 data: []
        @has_sku = false
      else
        $('#select_sku').select2 data: s_data

  add_gift: ->
    if $('#gift_list').find('tr:last td:first').text() == ''
      gift_num = 0
    else
      gift_num = parseInt($('#gift_list').find('tr:last td:first').text().slice(-1))
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

    product_ids = $("#gift_list tr").map(->
      $(this).attr "id"
    ).get()
    if $.inArray(product_id, product_ids) != -1
      alert("已添加过赠品")
      return

    product_name = $("#select_product").select2('data').text
    if $("#select_sku").select2('data') != null
      sku_name = $("#select_sku").select2('data').text
    else
      sku_name = ""
    gift_title = product_name + sku_name

    if $('#add_gift_tid').is(':checked')
      split_text = "拆分"
    else
      split_text = "不拆分"

    $.get '/trades/verify_add_gift', {ids: @trade_ids, sku_id: sku_id}, (data) ->
      if data['has_jingdong_trade'] == true
        alert("京东订单目前不支持此功能，请重新选择订单")
        return
      else
        $('#gift_list').append("<tr id='"+product_id+"' class='product_"+sku_id+" new_add_gift'>"+
                               "  <td>"+gift_title+"</td>"+
                               "  <td>"+num+"</td>"+
                               "  <td>"+split_text+"</td>"+
                               "</tr>")

    $.get '/trades/verify_add_gift', {ids: @trade_ids, sku_id: sku_id}, (data) ->
      if data['tids'] != ""
        $('.error').html('订单'+data['tids']+"已添加过"+gift_title)

  save: ->
    blocktheui()
    @add_gifts = {}
    length = $('#gift_list').find('tr').length
    if length != 0
      for i in [0..(length-1)]
        $gift_info = $('#gift_list').find("tr:eq("+i+")")
        product_id = $gift_info.attr('id')
        sku_id = $gift_info.attr('class').slice(8, -13)
        gift_title = $gift_info.children("td:eq(0)").text()
        num = $gift_info.children("td:eq(1)").text()
        has_main_trade = ($gift_info.children("td:eq(2)").text() == "拆分" ? true : false)
        @add_gifts[i] = {"sku_id": sku_id, "gift_title": gift_title, "product_id": product_id, "num": num, "has_main_trade": has_main_trade}

    operation = "批量添加赠品"
    gift_memo = $("#gift_memo_text").val()

    $.get '/trades/batch_add_gift', {ids: @trade_ids, operation: "批量添加赠品", add_gifts: @add_gifts, gift_memo: gift_memo}, (result) ->
      $.unblockUI()
      $('#trade_batch_add_gift').modal('hide')
