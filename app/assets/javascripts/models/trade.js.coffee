class MagicOrders.Models.Trade extends Backbone.Model
  urlRoot: '/api/trades'

  validate: (attrs) ->
  	if attrs.logistic_code =='YTO' and (/^[0-9A-Za-z]{10}$/.test(attrs.logistic_waybill)) == false
  	   return "格式错误,请输入10位物流单号"
  	else if attrs.logistic_code =='ZTO' and (/^[0-9A-Za-z]{12}$/.test(attrs.logistic_waybill)) == false
       return "格式错误,请输入12位物流单号"
  	else if attrs.logistic_code == 'OTHER' and (/^[0-9A-Za-z]{13}$/.test(attrs.logistic_waybill)) == false
       return "格式错误,请输入13位物流单号"
