class MagicOrders.Views.AreasSelectState extends Backbone.View

  template: JST['areas/select_state']

  events:
    'change #state_option': 'refresh_cities'
    'change #city_option': 'refresh_districts'
  
  initialize: ->
    @state = $("#state_option").val()
    @city = $("#city_option").val()

    @states = new MagicOrders.Collections.Areas()
    @cities = new MagicOrders.Collections.Areas()
    @districts = new MagicOrders.Collections.Areas()

    @states.fetch()
    
    @states.on("reset", @render, this)
    @cities.on("reset", @render, this)
    @districts.on("reset", @render, this)

  render: ->
    $(@el).html(@template(state: @state, city: @city, states: @states, cities: @cities, districts: @districts))
    this

  refresh_cities: ->
    newid = $("#state_option").val()
    @state = $("#state_option option[value=#{newid}]").data("id") unless newid == '请选择...'
    @cities.fetch {data: {parent_id: @state}}
    @state = $("#state_option").val()

  refresh_districts: =>
    newid = $("#city_option").val()
    @city = $("#city_option option[value=#{newid}]").data("id") unless newid == '请选择...'
    @districts.fetch data: {parent_id: @city}
    @city = $("#city_option").val()