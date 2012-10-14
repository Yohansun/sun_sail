class MagicOrders.Views.AreasInputs extends Backbone.View

  template: JST['areas/inputs']

  events:
    'change [name=trade_state]': 'refresh_cities'
    'change [name=trade_city]': 'refresh_districts'
    'change [name=trade_district]': 'refresh_district_seller'

  initialize: (options) ->
    @seller_name = ''
    @trade_id = options.order_id

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
      @get_seller(area_id)

  refresh_district_seller: ->
    unless $("#trade_district").val() == undefined or $("#trade_district").val() == '请选择...'
      area_id = $("#trade_district").val()
      @get_seller(area_id)

  reset_seller: =>
    $("#trade_seller_id").val(-1)
    @seller_name = ''
    $(".trade_seller").text('')


  get_seller: (area_id)->
    $.get('/api/trades/' + @trade_id + '/seller_for_area', {area_id: area_id}, (data)=>
      $("#trade_seller_id").val(data.seller_id);
      $('.trade_seller').html(data.seller_name);
      unless data.dispatchable
        $('.trade_seller').css('color', 'red')
        $('.set_seller').hide()
      else
        $('.set_seller').show()
    )

