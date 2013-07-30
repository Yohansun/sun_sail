# -*- encoding : utf-8 -*-
class BmlSingleSku
  def self.xml(product)
    stock = Builder::XmlMarkup.new
    stock.skus do
      stock.sku do
        stock.skucode product.outer_id
        stock.name product.name
        stock.desc ""
        stock.ALTERNATESKU1 ""
        stock.ALTERNATESKU2 ""
      end
    end
    stock.target!
  end

  #推送 SKU 同步信息至仓库
  def self.single_sku_to_wms(account, product)
    xml = BmlSingleSku.xml(product)
    client = Savon.client(wsdl: account.settings.biaogan_client)
    response = client.call(:single_sku_to_wms, message:{CustomerId: account.settings.biaogan_customer_id, PWD: account.settings.biaogan_customer_password,xml:xml})
    response.body[:single_sku_to_wms_response][:out]
  end

  def self.all_sku_to_wms(account)
    account.products.find_each do |product|
      BmlSingleSku.single_sku_to_wms(product)
    end
  end
end