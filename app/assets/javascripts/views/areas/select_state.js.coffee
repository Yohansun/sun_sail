class MagicOrders.Views.AreasSelectState extends Backbone.View

  template: JST['areas/select_state']

  events:
    'change #state_option': 'refresh_cities'
    'change #city_option': 'refresh_districts'

  initialize: ()->
    # support default selections
    location = @options.location
    if location
      @state = location.state #$("#state_option",@el).val()
      @city = location.city #$("#city_option",@el).val()
      @district = location.district

    @states = new MagicOrders.Collections.Areas()
    @cities = new MagicOrders.Collections.Areas()
    @districts = new MagicOrders.Collections.Areas()

    # fetch list for default selection
    @states.fetch()
    if @state
      @cities.fetch({data:{parent_name:@state}})
    if @city
      @districts.fetch({data:{parent_name:@city}})

    @states.on("reset", @render, this)
    @cities.on("reset", @render, this)
    @districts.on("reset", @render, this)

  render: ->
    $(@el).html(@template(state: @state, city: @city, district: @district,  states: @states, cities: @cities, districts: @districts))
    this

  refresh_cities: ->
    newid = $("#state_option",@el).val()
    if newid == ''
      @city = ''
      @cities.fetch {data: {parent_id: @state}}
      @districts.fetch data: {parent_id: @city}
    else
      @state = $("#state_option option[value=#{newid}]",@el).data("id")
      @cities.fetch {data: {parent_id: @state}}
    @state = $("#state_option",@el).val()

  refresh_districts: =>
    newid = $("#city_option",@el).val()
    if newid == ''
      @districts.fetch data: {parent_id: @city}
    else
      @city = $("#city_option option[value=#{newid}]",@el).data("id")
      @districts.fetch data: {parent_id: @city}
    @city = $("#city_option",@el).val()