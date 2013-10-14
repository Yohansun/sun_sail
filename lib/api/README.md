#MagicAPI

-------------------------------
Magic系统提供对外的API接口的两种方式

* rest风格

* method传值的方式

`rest`风格示例:
[POST] `http://magic-solo.networking.io/api/v1/warehouses/1/refund_products/1?private_token=abc&datas[status]=confirm&warehouse_id=1&refund_product_id=1`

`method`传值的方式:
[POST] `http://magic-solo.networking.io/api/v1?method=refund_product_verify&format=xml&private_token=abc`


`method`方式可以通过传入xml= xml对象. 系统会对其解析到datas[]  自动填充到`rest`访问的方式.  `method`方式只是一个协助解析成rest的方法.


________________
*helper.rb*
用户的授权及分页,设置数据格式(format)

*entities.rb*
返回给调用者的页面列表信息(可能有点不准确,详细的可以看相关文档)

*finger_apis*
通过url中传的method值自动调用对应的rest API. 如果添加一个api记得添加,比如:

    #对应url中method的名字
      api :stock_out_bill_verify do |data|
      #最终调用的API地址,如果系统中没有类似的路由helper的话手动拼装
        warehouse_stock_out_bill_path(data.id,data.tid)
      end


*api_logger.rb*
API日志

*data_parse.rb*
通过url传过来的xml或json自动转换成正常的参数