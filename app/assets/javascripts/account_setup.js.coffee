class AccountSetup

  bindEvents: ->
    # invoke only once.
    this.start_data_fetch()

  start_data_fetch: ->
    $('.account-setup .js-data-start').bind 'click', (e) ->
      dom = $(e.currentTarget)
      dom.attr('disabled', true)
      # alert 'data fetch starting...'
      $.post "/account_setups/"+dom.data('account-id')+"/data_fetch_start"
      # checking the data fetch processing progress every 15*1000ms
      window.AccountSetup.check_data_fetch(current_account.id)
      $(this).data("check_timer", setInterval("AccountSetup.check_data_fetch(current_account.id)", 15 * 1000))

  check_data_fetch: (account_id)->
    $.ajax "/account_setups/"+account_id+"/data_fetch_check",
      type: 'GET'
      dataType: 'json'
      success: (response) ->
        if response.ready is true
          $(".progress .bar").each ->
            clearInterval($(this).data("timer"));
            clearInterval($('.account-setup .js-data-start').data("check_timer"))
            $(this).css("margin-left","0").css("width","100%");

          $('.js-data-fetch').toggle()
          $('.js-data-next-step').toggle()
        else
          # alert 'processing...'

window.AccountSetup ?= new AccountSetup
