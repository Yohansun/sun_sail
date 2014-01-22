class MagicOrders.Collections.BaseCollection extends Backbone.Collection
  parse: (response) ->
    @response = response
    @counter_cache = response["counter_cache"]
    return @response["list"]