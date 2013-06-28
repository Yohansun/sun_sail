if Rails.env.production?
  $biaogan_client = "http://58.210.118.230:9012/order/BMLservices"
  $biaogan_customer_id = "AY_BLS"
  $biaogan_customer_password= "BML39390"
else
  $biaogan_client = "http://58.210.118.230:9021/order/BMLservices/BMLQuery?wsdl"
  $biaogan_customer_id = "ALLYES"
  $biaogan_customer_password= "BML33570"
end