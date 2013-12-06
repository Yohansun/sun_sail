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

    if $("#select_category").val() == ""
      alert("请选择分类")
      return

    product_id = $("#select_product").val()
    if product_id == ""
      alert("请选择商品")
      return

    sku_id = $("#select_sku").val()
    if (sku_id == "" and @has_sku == true)
      alert("请选择SKU")
      return

    num = $('#gift_num').val()
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

    gift_title = $("#select_product").select2('data').text + $("#select_sku").select2('data').text

    $.get '/trades/verify_add_gift', {ids: @trade_ids, sku_id: sku_id}, (data) ->
      if data['has_jingdong_trade'] == true
        alert("京东订单,一号店订单目前不支持此功能，请重新选择订单")
        return
      else if data['has_gift_trade'] == true
        alert("赠品订单不能添加赠品！")
        return
      else
        $('#gift_list').append(
          "<tr data-sku_id='"+sku_id+"' data-product_id='"+product_id+"' class='new_add_gift'>"+
          "  <td>"+gift_title+"</td>"+
          "  <td>"+num+"</td>"+
          "</tr>"
        )

    $.get '/trades/verify_add_gift', {ids: @trade_ids, sku_id: sku_id}, (data) ->
      if data['tids'] != ""
        $('.error').html('订单'+data['tids']+"已添加过"+gift_title)

  save: ->
    blocktheui()
    @add_gifts = {}
    @add_gifts['gift_orders'] = {}
    length = $('#gift_list').find('tr').length
    if length != 0
      @add_gifts['is_split'] = $('#add_gift_tid').is(':checked')
      for i in [0..(length-1)]
        $gift_info = $('#gift_list').find("tr:eq("+i+")")
        if $gift_info.attr('class') == "new_add_gift"
          sku_id      = $gift_info.data('sku_id')
          product_id  = $gift_info.data('product_id')
          gift_title  = $gift_info.children("td:eq(0)").text()
          num         = $gift_info.children("td:eq(1)").text()
          @add_gifts['gift_orders'][i] = {"sku_id": sku_id, "gift_title": gift_title, "product_id": product_id, "num": num}

    operation = "批量添加赠品"
    gift_memo = $("#gift_memo_text").val()

    $.get '/trades/batch_add_gift', {ids: @trade_ids, operation: "批量添加赠品", add_gifts: @add_gifts, gift_memo: gift_memo}, (result) ->
      $.unblockUI()
      $('#trade_batch_add_gift').modal('hide')
