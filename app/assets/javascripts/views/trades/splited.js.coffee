class MagicOrders.Views.TradesSplited extends Backbone.View

  template: JST['trades/splited']

  events:
    'click .save' : 'save'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(trade: @model))
    this

  save: (e) ->
    e.preventDefault()
    if $(".modal-body div.ord_split span").find("input[value='']").length > 0
      alert('请输入完整')
    else
      data = {splits: []}
      $(".modal-body div.ord_split table tbody").each ->
        split = {}
        spans = $(this).find('tr td.bordered_top1 span')
        split["orders"] = []
        $(this).find("tr td.title").each ->
          split["orders"].push {oid: $(this).data("rel"),num: $(this).next().text()}
        split["total_fee"] = $(spans).eq(0).find("input").val()
        split["promotion_fee"]    = $(spans).eq(1).find("input").val()
        split["post_fee"]  = $(spans).eq(2).find("input").val()
        split["payment"]   = $(spans).eq(3).find("span").html()
        data["splits"].push split

      $.ajax '/api/trades/' + @model.id + '/split_trade',
        type:     'PUT'
        dataType: 'json'
        data:     data
        success: (data, textStatus, jqXHR) ->
          if data.success
            $('#ord_split').modal('hide')
            alert("拆分成功")
          else
            alert("拆分失败" + data.message)
            console.log(data)
        error: (jqXHR, textStatus, errorThrown)->
          console.log(jqXHR.status)