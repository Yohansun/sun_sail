class MagicOrders.Views.AreasInputs extends Backbone.View

  template: JST['areas/inputs']

  events:
    'change [name=trade_state]': 'refresh_cities'
    'change [name=trade_city]': 'refresh_districts'

  initialize: (options) ->
    @state = options.state
    @city = options.city
    @district = options.district

    @states = options.states
    @states.on("reset", @render, this)
    @states.on("reset", @select_state, this)

    @cities = new MagicOrders.Collections.Areas()
    @cities.on("reset", @render, this)

    @districts = new MagicOrders.Collections.Areas()
    @districts.on("reset", @render, this)

  render: ->
    $(@el).html(@template(states: @states, cities: @cities, districts: @districts,
      state: @state, city: @city, district: @district))
    this

  select_state: ->
    console.log "select_state"
    console.log @state
    $("#trade_state").val(@state)

  refresh_cities: (event) ->
    @cities.fetch({data: {parent_id: $(event.target).val()}})

  refresh_districts: (event) ->
    @districts.fetch({data: {parent_id: $(event.target).val()}})