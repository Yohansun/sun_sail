class AccountSetup

  bindEvents: ->
    # invoke only once.
    this.start_data_fetch()

  start_data_fetch: ->
    $('#js-data-start').bind 'click', (e) ->
      dom = $(e.currentTarget)
      dom.attr('disabled', true)
      # alert 'data fetch starting...'
      $.post "/account_setups/"+dom.data('account-id')+"/data_fetch_start"
      # checking the data fetch processing progress every 15*1000ms
      window.AccountSetup.check_data_fetch(current_account.id)
      $(this).data("check_timer", setInterval("AccountSetup.check_data_fetch(current_account.id)", 2 * 1000))

  check_data_fetch: (account_id)->
    $.ajax "/account_setups/"+account_id+"/data_fetch_check",
      type: 'GET'
      dataType: 'json'
      success: (response) ->
        if response.ready is true
          $(".progress .bar").each ->
            clearInterval($(this).data("timer"));
            clearInterval($('#js-data-start').data("check_timer"))
            $(this).css("width","100%");

          $('#btn-next-step').removeAttr("disabled");
        else
          run_times = parseInt($("div#run_times").html())
          if isNaN(run_times)
            run_times = 1
          else
            run_times += 1
          $("div#run_times").html(run_times)
window.AccountSetup ?= new AccountSetup
