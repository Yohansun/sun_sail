class MagicOrders.Views.TradesGiftMemo extends Backbone.View

  template: JST['trades/gift_memo']

  events:
    'click .save': 'save'
    'click #add_gift_to_list' : 'add_gift'
    'click .delete_a_gift' : 'delete_gift'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  add_gift: ->
    if $('#gift_list').find('tr:last td:first').text() == ''
      gift_num = 0
    else
      gift_num = parseInt($('#gift_list').find('tr:last td:first').text().slice(-1))

    product_id = $("#select_gift").val()
    gift_title = $("#select_gift").children('option:selected').text()
    gift_tid = @model.get('tid')+"G"+(gift_num+1)
    if product_id == "void"
      alert("请选择赠品（如果没有可选赠品,请先进入商品管理模块添加赠品）")
    else
      if $('#add_gift_tid').is(':checked')
        trade_tid = @model.get('tid')
        split_text = "拆分"
      else
        trade_tid = ''
        split_text = "不拆分"
      $('#gift_list').append("<tr class='product_"+product_id+" new_add_gift'>"+
                             "  <td>"+gift_tid+"</td>"+
                             "  <td>"+gift_title+"</td>"+
                             "  <td>"+trade_tid+"</td>"+
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
      for num in [0..(length-1)]
        if $('#gift_list').find("tr:eq("+num+")").attr('style') == "display: none;"
          gift_tid = $('#gift_list').find("tr:eq("+num+")").children("td:eq(0)").text()
          @delete_gifts.push(gift_tid)
          console.log(@delete_gifts)
        else
          if $('#gift_list').find("tr:eq("+num+")").attr('class').slice(-12) == "new_add_gift"
            product_id = $('#gift_list').find("tr:eq("+num+")").attr('class').slice(8, -13)
            gift_tid = $('#gift_list').find("tr:eq("+num+")").children("td:eq(0)").text()
            gift_title = $('#gift_list').find("tr:eq("+num+")").children("td:eq(1)").text()
            if $('#gift_list').find("tr:eq("+num+")").children("td:eq(2)").text() == ''
              trade_id = ''
            else
              trade_id = @model.get('id')
            @add_gifts[num] = {"product_id": product_id, "gift_tid": gift_tid, "gift_title": gift_title, "trade_id": trade_id}
            console.log(@add_gifts)

    @model.set "operation", "赠品修改"
    @model.set "delete_gifts", @delete_gifts
    @model.set "add_gifts", @add_gifts
    @model.save {"gift_memo": $("#gift_memo_text").val()},
      success: (model, response) =>
        $.unblockUI()

        view = new MagicOrders.Views.TradesRow(model: model)
        $("#trade_#{model.get('id')}").replaceWith(view.render().el)
        $("a[rel=popover]").popover({placement: 'left', html:true})
        $('#trade_gift_memo').modal('hide')

      error: (model, error, response) =>
        $.unblockUI()
        alert("输入错误")