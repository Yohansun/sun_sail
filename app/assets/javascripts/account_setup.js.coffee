class AccountSetup

  bindEvents: ->
    this.start_data_fetch()

  start_data_fetch: ->
    $('.account-setup .js-data-start').bind 'click', (e) ->
      dom = $(e.currentTarget)
      dom.attr('disabled', true)
      alert 'data fetch starting...'
      $.post "/account_setups/"+dom.data('account-id')+"/data_fetch_start"
      # checking the data fetch processing progress every 15*1000ms
      setInterval("AccountSetup.check_data_fetch(current_account.id)", 15 * 1000)

  check_data_fetch: (account_id)->
    $.ajax "/account_setups/"+account_id+"/data_fetch_check",
      type: 'GET'
      dataType: 'json'
      success: (response) ->
        if response.ready is true
          $('.js-data-fetch').toggle()
          $('.js-data-other-settings').toggle()
        else
          alert 'processing...'

window.AccountSetup ?= new AccountSetup
