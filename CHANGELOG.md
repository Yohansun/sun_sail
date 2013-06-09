*   更新 `回头顾客` 可先把状态为 `TRADE_FINISHED` 的 `Trade` `news` 改为 1, 

    然后通过 `CustomersPuller.update` 来更新顾客信息.

    ** Zhoubin **


*   StockBill入/出库类型格式为:入库类型前面为I,出库类型前面为O,可以通过:

        update_attributes(:stock_type => "(I|O)..")

    如果想使用以前的不加`I`,`O`前缀,可使用:

        StockInBill#update_attributes(:stock_typs => "OT")

        StockOutBill#update_attributes(:stock_typs => "OT")

    如果本地的入/出库类型还是老数据的话,记得:

        StockBill.each {|bill| bill.update_attributes(:stock_typs => bill.stock_type)}

    ** ZhouBin **