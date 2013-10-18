class MagicOrders.Routers.LogisticBills extends Backbone.Router
  routes:
    'logistic_bills': 'index'
    'logistic_bills/:trade_mode-:trade_type?sid=:trade_search_id': 'index'
    'logistic_bills/:trade_mode-:trade_type': 'index'
    'logistic_bills/:id/splited': 'splited'
    'logistic_bills/:id/:operation': 'operation'
    'logistic_bills/:id/recover': 'recover'

  initialize: ->
    @trade_type = null
    $('#content').html('')
    @collection = new MagicOrders.Collections.DeliverBills()

    MagicOrders.original_path = window.location.hash
    $('.logistic_bill.modal').on 'hidden', (event) ->
      refresh = ($('#content').html() == '')
      if _.str.include(MagicOrders.original_path,'-')
        Backbone.history.navigate("#{MagicOrders.original_path}", refresh)
      else
        Backbone.history.navigate("logistic_bills", refresh)

    $('[data-toggle="modal"]').bind 'show', (event) ->
      blocktheui()

  show_top_nav: ->
    $("#top-nav li").hide()
    $("#top-nav li.trades").show()

  processScroll: =>
    $('.js-affix').affix()

  index: (trade_mode = "logistic_bills", trade_type = null, trade_search_id = '') ->
    # reset the index stage, hide all popups
    $('.modal').modal('hide')

    @isFixed = false

    $('#content').html ""
    @trade_type = trade_type
    MagicOrders.trade_mode = trade_mode
    MagicOrders.trade_type = trade_type
    search_data = {trade_type: trade_type}
    if /[0-9a-z]{24}/.exec(trade_search_id)
      MagicOrders.search_id = trade_search_id
      search_data["search_id"] = trade_search_id
    else
      MagicOrders.search_id = ''
    blocktheui()
    @show_top_nav()
    @collection.fetch data: search_data, success: (collection, response) =>
      @mainView = new MagicOrders.Views.LogisticBillsIndex(collection: collection, trade_type: trade_type)
      $('#content').html(@mainView.render().el)
      @searchView = new MagicOrders.Views.TradesAdvancedSearch()
      $("#search_form").html(@searchView.render().el)
      $("a[rel=popover]").popover(placement: 'left')
      $(window).on 'scroll', @processScroll
      switch trade_type
        when 'unprinted' then $('.trade_nav').html('未打印')
        when 'printed' then $('.trade_nav').html('已打印')
      $.unblockUI()

  newTradesNotifer: =>
    $.get "/api/trades/notifer", {trade_type: @trade_type, timestamp: @latest_trade_timestamp}, (response) =>
      if response > 0
        $("#newTradesNotifer span").text(response)
        $("#newTradesNotifer").show()
        $("#newTradesNotiferLink").on 'click', (event) =>
          event.preventDefault()
          $("#newTradesNotiferLink").off 'click'
          @mainView.fetch_new_trades()

  operation: (id, operation_key) ->
    viewClassName = "LogisticBills" + _.classify(operation_key)
    modalDivID = "#logistic_bill_" + operation_key

    @model = new MagicOrders.Models.DeliverBill(id: id)
    @model.fetch success: (model, response) =>
      $.unblockUI()

      view = new MagicOrders.Views[viewClassName](model: model)
      $(modalDivID).html(view.render().el)
      $(modalDivID + ' .datepicker').datetimepicker(format: 'yyyy-mm-dd',autoclose: true,minView: 2)

      if operation_key == 'print_logistic_bill'
        $.get '/logistics/logistic_templates', {type: 'all'}, (t_data)->
          html_options = ''
          for item in t_data
            html_options += '<option lid="' + item.id + '" value="' + item.xml + '">' + item.name + '</option>'

          $('#logistic_select').html(html_options)
          $('#logistic_select').show()
          $('#logistic_select').change ()->
            bind_logistic_swf model.get('id'), $(this).val()

          $(modalDivID).on 'hidden', ()->
            if $('.print_logistic_button').attr('data-click') == '1'
              $.get '/deliver_bills/batch-print-logistic', {ids: [model.get('id')], logistic: $("#logistic_select").find("option:selected").attr('lid')}

            $('.print_logistic_button').removeAttr('data-click')

          $.get ('/deliver_bills/' + model.get('id') + '/logistic_info'), {}, (data)->
            if data == " "
              #ytong = $('#logistic_select').find('[lid="3"]')
              data = $("#logistic_select").find("option:first").val()
              $('#logistic_select').find("option:first").attr('selected', 'selected')
            else
              $('#logistic_select').find('[value="' + data + '"]').attr('selected', 'selected')

            pageInit()
            bind_logistic_swf(model.get('id'), data)
        $(modalDivID).modal('show')
      else
        $(modalDivID).modal('show')
