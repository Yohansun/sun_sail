class MagicOrders.Models.Trade extends Backbone.Model
  urlRoot: '/api/trades'

  validate: (attrs) ->
  	# if attrs.logistic_code =='YTO' and (/^(0|1|2|3|5|6|7|8|E|D|F|G|V|W|e|d|f|g|v|w)[0-9]{9}$/.test(attrs.logistic_waybill)) == false
   #    return "格式错误,请输入10位物流单号"
  	# else if attrs.logistic_code =='ZTO' and (/^((618|680|778|688|618|828|988|118|888|571|518|010|628|205|880|717|718|728|738|761|762|763|701|757)[0-9]{9})$|^((2008|2010|8050|7518)[0-9]{8})$/.test(attrs.logistic_waybill)) == false
   #    return "格式错误,请输入12位物流单号"
    # else if attrs.logistic_code == 'OTHER' and (/^[0-9A-Za-z]{13}$/.test(attrs.logistic_waybill)) == false
    #   return "格式错误,请输入13位物流单号"
    
    # if attrs.invoice_name == ""
    #   return "发票抬头不能为空"