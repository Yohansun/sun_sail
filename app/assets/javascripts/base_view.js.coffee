class MagicOrders.Views.BaseView extends Backbone.View

  render: ->
    @loadStatusCount(@collection.counter_cache)

  loadStatusCount:(counter_cache)->
    $("[data-trade-status]",@el).each ->
      trade_mode = $(this).data("trade-mode")
      trade_type = $(this).data("trade-status")
      $("em",this).text("(" + (counter_cache && counter_cache[trade_mode + "/" + trade_type ]) + ")")