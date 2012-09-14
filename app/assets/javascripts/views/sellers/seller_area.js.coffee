class MagicOrders.Views.SellersSellerArea extends Backbone.View

  template: JST['sellers/seller_area']

  #events:
    # 'click .save': 'save'
    # 'click .decontrol_child': 'decontrol_child'

  initialize: ->
    @model.on("fetch", @render, this)

  render: ->
    $(@el).html(@template(seller: @model))
    this

  # decontrol_child: ->    
  #   @child_ids = []
  #   for item,i in $(".decontrol_child") 
  #     child_ids[i] = $(item).data("child-id")

  # save: (e) ->
  #   e.preventDefault()
  #   @model.save {},
  #     success: (model, response) =>
  #       $.unblockUI()

  #       view = new MagicOrders.Views.SellersRow(model: model)
  #       $("#trade_#{model.get('id')}").replaceWith(view.render().el)
  #       $("a[rel=popover]").popover(placement: 'left', trigger:'hover')

  #       $('#seller_area').modal('hide')