class MagicOrders.Views.AreasInputs extends Backbone.View

  template: JST['areas/inputs']

  events:
    'change [name=trade_state]': 'refresh_cities'
    'change [name=trade_city]': 'refresh_districts'
    'change [name=trade_district]': 'refresh_district_seller'

  initialize: (options) ->
    @seller_name = ''

    @state = options.state
    @city = options.city
    @district = options.district

    @states = options.states
    @states.on("reset", @render, this)
    @states.on("reset", @select_state, this)

    @cities = new MagicOrders.Collections.Areas()
    @cities.on("reset", @render, this)
    @cities.on("reset", @select_city, this)

    @districts = new MagicOrders.Collections.Areas()
    @districts.on("reset", @render, this)
    @districts.on("reset", @refresh_district_seller, this)

  render: ->
    $(@el).html(@template(states: @states, cities: @cities, districts: @districts, state: @state, city: @city, district: @district, seller_name: @seller_name))
    this

  select_state: ->
    @refresh_cities()

  select_city: ->
    @refresh_districts()

  refresh_cities: ->
    @reset_seller()

    newid = $("#trade_state").val()
    @state = $("#trade_state option[value=#{newid}]").data("name") unless newid == '请选择...'
    @cities.fetch {data: {parent_id: newid}}

  refresh_districts: =>
    @reset_seller()

    @refresh_city_seller()
    newid = $("#trade_city").val()
    @city = $("#trade_city option[value=#{newid}]").data("name") unless newid == '请选择...'
    @districts.fetch data: {parent_id: $("#trade_city").val()}, success: (collection) =>

  refresh_city_seller: ->
    unless $("#trade_city").val() == '请选择...'
      area_id = $("#trade_city").val()
      seller_id = $("#trade_city option[value=#{area_id}]").data("seller-id")
      if seller_id != ''
        $("#trade_seller_id").val(seller_id)
        @seller_name = $("#trade_city option[value=#{area_id}]").data("seller-name")
        $(".trade_seller").text(@seller_name)

  refresh_district_seller: ->
    unless $("#trade_district").val() == undefined or $("#trade_district").val() == '请选择...'
      area_id = $("#trade_district").val()
      seller_id = $("#trade_district option[value=#{area_id}]").data("seller-id")
      $("#trade_seller_id").val(seller_id)
      @seller_name = $("#trade_district option[value=#{area_id}]").data("seller-name")
      $(".trade_seller").text(@seller_name)

  reset_seller: =>
    $("#trade_seller_id").val(-1)
    @seller_name = ''
    $(".trade_seller").text('')