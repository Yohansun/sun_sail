class MagicOrders.Routers.Trades extends Backbone.Router
  routes:
    '': 'index'
    'trades': 'index'
    'trades/:trade_type': 'index'
    'trades/:id/detail': 'show'
    'trades/:id/seller': 'seller'
    'trades/:id/deliver': 'deliver'
    'trades/:id/cs_memo': 'cs_memo'
    'trades/:id/color': 'color'
    'trades/:id/invoice': 'invoice'

  initialize: ->
    $('#content').html('')
    @collection = new MagicOrders.Collections.Trades()

  show_top_nav: ->
    $("#top-nav li").hide()
    $("#top-nav li.trades").show()

  processScroll: =>
    console.log 'processScroll'
    scrollTop = $(window).scrollTop()
    if scrollTop >= @navTop && !@isFixed
        @isFixed = true
        @nav.addClass('subnav-fixed')
    else
      if scrollTop <= @navTop && @isFixed
        @isFixed = false
        @nav.removeClass('subnav-fixed')

  index: (trade_type = null) ->
    $("body").spin()
    @isFixed = false

    @show_top_nav()
    @collection.fetch data: {trade_type: trade_type}, success: (collection, response) =>
      view = new MagicOrders.Views.TradesIndex(collection: collection, trade_type: trade_type)
      $('#content').html(view.render().el)
      $("a[rel=popover]").popover(placement: 'left')

      @nav = $('.subnav')
      @navTop = $('.subnav').length && $('.subnav').offset().top - 40
      $(window).off 'scroll'
      $(window).on 'scroll', @processScroll
      @processScroll

      $("body").spin(false)

      $('#trades_bottom').waypoint view.fetch_more_trades, {offset: '100%'}

  show: (id) ->
    $("body").spin()
    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      $("body").spin false

      view = new MagicOrders.Views.TradesShow(model: model)
      $('#trade_detail').html(view.render().el)

      $('#trade_detail').on 'hide', (event) ->
        window.history.back()
      $('#trade_detail').modal('show')

  seller: (id) ->
    $("body").spin()

    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      view = new MagicOrders.Views.TradesSeller(model: model)
      $("body").spin(false)

      $('#trade_seller').html(view.render().el)

      $('#trade_seller').on 'hide', (event) ->
        window.history.back()
      $('#trade_seller').modal('show')

  deliver: (id) ->
    $("body").spin()

    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      $("body").spin(false)

      view = new MagicOrders.Views.TradesDeliver(model: model)
      $('#trade_deliver').html(view.render().el)

      $('#trade_deliver').on 'hide', (event) ->
        window.history.back()

      $('#trade_deliver').modal('show')

  cs_memo: (id) ->
    $("body").spin()

    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      $("body").spin(false)

      view = new MagicOrders.Views.TradesCsMemo(model: model)

      $('#trade_cs_memo').html(view.render().el)
      $('#trade_cs_memo').on 'hide', (event) ->
        window.history.back()

      $('#trade_cs_memo').modal('show')

  color: (id) ->
    $("body").spin()

    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      $("body").spin(false)

      view = new MagicOrders.Views.TradesColor(model: model)

      $('#trade_color').html(view.render().el)
      $('#trade_color').on 'hide', (event) ->
        window.history.back()

      $('#trade_color').modal('show')


  invoice: (id) ->
    $("body").spin()

    @model = new MagicOrders.Models.Trade(id: id)
    @model.fetch success: (model, response) =>
      $("body").spin(false)

      view = new MagicOrders.Views.TradesInvoice(model: model)

      $('#trade_invoice').html(view.render().el)
      
      $('#trade_invoice').on 'hide', (event) ->
        window.history.back()

      $('#trade_invoice').modal('show')

      #$('.datepicker').datepicker(format: 'yyyy-mm-dd')
