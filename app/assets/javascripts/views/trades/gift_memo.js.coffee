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

    gift_title = $("#select_product").select2('data').text + $("#select_sku").select2('data').text

    $('#gift_list').append(
      "<tr data-sku_id='"+sku_id+"' data-product_id='"+product_id+"' class='new_add_gift'>"+
      "  <td>"+gift_title+"</td>"+
      "  <td>"+num+"</td>"+
      "  <td>待定</td>"+
      "  <td>待定</td>"+
      "  <td><button class='btn delete_a_gift'>删除</button></td>"+
      "</tr>"
    )

  delete_gift: (e) ->
    e.preventDefault()
    if $(e.currentTarget).closest('tr').attr('class') == 'new_add_gift'
      $(e.currentTarget).closest('tr').remove()
    else
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
          order_id = $gift_info.data("order")
          @delete_gifts.push(order_id)
        else
          if $gift_info.attr('class') == "new_add_gift"
            sku_id      = $gift_info.data('sku_id')
            product_id  = $gift_info.data('product_id')
            gift_title  = $gift_info.children("td:eq(0)").text()
            num         = $gift_info.children("td:eq(1)").text()

            @add_gifts[i] = {"sku_id": sku_id, "gift_title": gift_title, "product_id": product_id, "num": num}
            @add_gifts['should_split'] = $('#add_gift_tid').is(':checked')

    new_model = new MagicOrders.Models.Trade(id: @model.id)
    new_model.save {operation: "赠品修改", delete_gifts: @delete_gifts, add_gifts: @add_gifts, gift_memo: $("#gift_memo_text").val()},
      success: (model, response) =>
        $.unblockUI()

        view = new MagicOrders.Views.TradesRow(model: model)
        $("#trade_#{model.get('id')}").replaceWith(view.render().el)
        view.reloadOperationMenu()

        $('#trade_gift_memo').modal('hide')

      error: (model, error, response) =>
        $.unblockUI()
        alert("操作频率过大")
        $('#trade_gift_memo').modal('hide')