class MagicOrders.Models.DeliverBill extends Backbone.Model
  url: ->
    if this.isNew()
      'api/deliver_bills'
    else
      'api/deliver_bills/' + this.id
