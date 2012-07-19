class MagicOrders.Views.AreasInputs extends Backbone.View

  template: JST['areas/inputs']

  events:
    'change [name=trade_state]': 'refresh_cities'
    'change [name=trade_city]': 'refresh_districts'
    'change [name=trade_district]': 'refresh_seller'

  initialize: (options) ->
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
    @districts.on("reset", @refresh_seller, this)

  render: ->
    $(@el).html(@template(states: @states, cities: @cities, districts: @districts, state: @state, city: @city, district: @district))
    this

  select_state: ->
    @refresh_cities()

  select_city: ->
    @refresh_districts()

  refresh_cities: ->
    newid = $("#trade_state").val()
    @state = $("#trade_state option[value=#{newid}]").data("name") unless newid == '请选择...'
    @cities.fetch({data: {parent_id: newid}})

  refresh_districts: ->
    $("#trade_seller_id").val(-1)
    newid = $("#trade_city").val()
    @city = $("#trade_city option[value=#{newid}]").data("name") unless newid == '请选择...'
    @districts.fetch({data: {parent_id: $("#trade_city").val()}})

  refresh_seller: ->
    unless $("#trade_district").val() == '请选择...'
      area_id = $("#trade_district").val()
      seller_id = $("#trade_district option[value=#{area_id}]").data("seller-id")
      $("#trade_seller_id").val(seller_id)
      $(".trade_seller").html($("#trade_district option[value=#{area_id}]").data("seller-name"))