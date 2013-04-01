# -*- encoding : utf-8 -*-

class TaobaoProductsPuller
  class << self   

    # Below methods are strongly recommed to use oauth2.

    def sync_pic(trade_source_id)
      trade_source = TradeSource.find_by_id(trade_source_id)
      account = Account.find_by_id(trade_source.account_id)
      if account.key == "nippon"
        nick = '立邦漆官方旗舰店'
      else
        nick = trade_source.name
      end 

      response = TaobaoQuery.get({method: 'taobao.products.get', nick: nick, fields: 'pic_url, name'}, trade_source_id)   
      if  response['products_get_response']['products'].present? &&  response['products_get_response']['products']['product'].present?
        products = response['products_get_response']['products']['product']
        products.each do |product|
          local_product = Product.where(name: product['name']).first
          if local_product
            local_product.pic_url = product['pic_url']
            local_product.save!(validate: false)  
          end     
        end 
      end
    end 

    # after create products, remember to sync cat_name
    def sync_cat_name(trade_source_id)
      trade_source = TradeSource.find_by_id(trade_source_id)
      account = Account.find_by_id(trade_source.account_id)
      total_pages = nil
      page_no = 0
      if  account.key == "nippon"
        nick = '立邦漆官方旗舰店'
      else
        nick = trade_source.name
      end

      begin
        response = TaobaoQuery.get({method: 'taobao.products.get', nick: nick,  fields: 'cat_name, product_id', page_no: page_no, page_size: 100}, trade_source_id)   
        if  response['products_get_response']['products'].present? &&  response['products_get_response']['products']['product'].present?
          products = response['products_get_response']['products']['product']
          total_results = products.count
          total_pages ||= total_results / 100
          products.each do |product|
            local_product = Product.where(product_id: product['product_id']).first
            if local_product
              if product['cat_name'].present?
                category = Category.where(name: product['cat_name'], account_id: account.id).first_or_create
              else
                category = Category.where(name: '其他').first_or_create  
              end  
              local_product.category_id = category.id
              local_product.save!(validate: false)  
            end     
          end 
        end
        page_no += 1
      end until(total_pages.nil? || total_pages == 0 || page_no > total_pages )       

    end 


    def create_item(trade_source_id, num_iid)
      trade_source = TradeSource.find_by_id(trade_source_id)
      account = Account.find_by_id(trade_source.account_id)
      if account.key == "nippon "
        nick = '立邦漆官方旗舰店'
      else
        nick = trade_source.name
      end
      item_get_response = TaobaoQuery.get({method: 'taobao.item.get',  fields: 'num,detail_url,title,sku.properties_name,sku.properties,sku.quantity, sku.sku_id, outer_id, product_id, pic_url,cid,price', num_iid: num_iid, nick: nick}, trade_source_id)   
      sku_items = item_get_response['item_get_response']['item']
      sku_items_count = sku_items.count
      if sku_items_count > 0
        name = sku_items['title']
        detail_url = sku_items['detail_url']
        outer_id =  sku_items['outer_id']
        product_id = sku_items['product_id']
        cid = sku_items['cid']
        pic_url = sku_items['pic_url']
        price = sku_items['price']
        
        #Create product and sku
        #Remember to add account_id
        #Remember to sync nippon and dulux stock
        local_product = Product.create(account_id: account.id, name: name, detail_url: detail_url, outer_id: outer_id,  num_iid: num_iid, product_id: product_id, cid: cid, pic_url: pic_url, price: price) unless Product.find_by_num_iid(num_iid)
        if local_product
          if sku_items['skus'] && sku_items['skus']['sku'].count > 0
            sku_items['skus']['sku'].each do |sku|
              sku_id = sku['sku_id']
              quantity = sku['quantity']
              properties_name = sku['properties_name']
              properties = sku['properties']
              #Remember to add account_id
              Sku.create!(product_id: local_product.id, quantity: quantity, num_iid: num_iid, sku_id: sku_id, properties_name:properties_name, properties: properties)  unless Sku.find_by_sku_id(sku_id)
            end  
          else
            quantity = sku_items['num']
            #Remember to add account_id
            Sku.create!(product_id: local_product.id, quantity: quantity, num_iid: num_iid) unless Sku.find_by_num_iid(num_iid)
          end    
        end
      end    
    end  

    def create(trade_source_id)
      trade_source = TradeSource.find_by_id(trade_source_id)
      account = Account.find_by_id(trade_source.account_id)
      total_pages = nil
      page_no = 0

      if account.key == "nippon "
        nick = '立邦漆官方旗舰店'
      else
        nick = trade_source.name
      end

      num_iids = []
      begin
        #调用taobao.items.onsale.get获取获取当前用户作为卖家的出售中的商品num_iid
        items_onsale_response = TaobaoQuery.get({method: 'taobao.items.onsale.get', fields: 'num_iid', nick: nick}, trade_source_id)   
        if  items_onsale_response['items_onsale_get_response']['items'].present? &&  items_onsale_response['items_onsale_get_response']['items']['item'].present?
          items = items_onsale_response['items_onsale_get_response']['items']['item']
          total_results = items_onsale_response['items_onsale_get_response']['total_results']
          total_pages ||= total_results / 100
          if total_results > 0
            items.each do |item|
              num_iids << item['num_iid']
            end
          end 
        end 
        page_no += 1
      end until(total_pages.nil? || total_pages == 0 || page_no > total_pages )     

      num_iids.each do |num_iid|
        #通过num_iid调用taobao.item.get获取sku相关信息
        item_get_response = TaobaoQuery.get({method: 'taobao.item.get',  fields: 'num,detail_url,title,sku.properties_name,sku.properties,sku.quantity, sku.sku_id, outer_id, product_id, pic_url,cid,price', num_iid: num_iid, nick: nick}, trade_source_id)   
        next unless item_get_response['item_get_response']
        sku_items = item_get_response['item_get_response']['item']
        next unless sku_items
        sku_items_count = sku_items.count
        if sku_items_count > 0
          name = sku_items['title']
          detail_url = sku_items['detail_url']
          outer_id =  sku_items['outer_id']
          product_id = sku_items['product_id']
          cid = sku_items['cid']
          pic_url = sku_items['pic_url']
          price = sku_items['price']
          
          #Create product and sku
          #Remember to add account_id
          #Remember to sync nippon and dulux stock
          local_product = Product.create(account_id: account.id, name: name, detail_url: detail_url, outer_id: outer_id,  num_iid: num_iid, product_id: product_id, cid: cid, pic_url: pic_url, price: price) unless Product.find_by_num_iid(num_iid)
          if local_product
            if sku_items['skus'] && sku_items['skus']['sku'].count > 0
              sku_items['skus']['sku'].each do |sku|
                sku_id = sku['sku_id']
                quantity = sku['quantity']
                properties_name = sku['properties_name']
                properties = sku['properties']
                #Remember to add account_id
                Sku.create!(product_id: local_product.id, quantity: quantity, num_iid: num_iid, sku_id: sku_id, properties_name:properties_name, properties: properties)  unless Sku.find_by_sku_id(sku_id)
              end  
            else
              quantity = sku_items['num']
              #Remember to add account_id
              Sku.create!(product_id: local_product.id, quantity: quantity, num_iid: num_iid) unless Sku.find_by_num_iid(num_iid)
            end    
          end  
        end  
      end # num_iids each ends

    end # create ends


    def create_from_trades(trade_source_id)
      trade_source = TradeSource.find_by_id(trade_source_id)
      account = Account.find_by_id(trade_source.account_id)

      trades = Trade.where(trade_source_id: trade_source_id).only(:trade_source_id, "taobao_orders.num_iid").where(trade_source_id: trade_source_id)
      num_iids = trades.map(&:taobao_orders).flatten.map(&:values).flatten.uniq
      num_iids.each do |num_iid|
        #通过num_iid调用taobao.item.get获取sku相关信息
        item_get_response = TaobaoQuery.get({method: 'taobao.item.get',  fields: 'num,detail_url,title,sku.properties_name,sku.properties,sku.quantity, sku.sku_id, outer_id, product_id, pic_url,cid,price', num_iid: num_iid}, trade_source_id)   
        next unless item_get_response['item_get_response']
        sku_items = item_get_response['item_get_response']['item']
        next unless sku_items
        sku_items_count = sku_items.count
        if sku_items_count > 0
          name = sku_items['title']
          detail_url = sku_items['detail_url']
          outer_id =  sku_items['outer_id']
          product_id = sku_items['product_id']
          cid = sku_items['cid']
          pic_url = sku_items['pic_url']
          price = sku_items['price']
          
          #Create product and sku
          #Remember to add account_id
          #Remember to sync nippon and dulux stock
          local_product = Product.create(account_id: account.id, name: name, detail_url: detail_url, outer_id: outer_id,  num_iid: num_iid, product_id: product_id, cid: cid, pic_url: pic_url, price: price) unless Product.find_by_num_iid(num_iid)
          if local_product
            if sku_items['skus'] && sku_items['skus']['sku'].count > 0
              sku_items['skus']['sku'].each do |sku|
                sku_id = sku['sku_id']
                quantity = sku['quantity']
                properties_name = sku['properties_name']
                properties = sku['properties']
                #Remember to add account_id
                Sku.create!(product_id: local_product.id, quantity: quantity, num_iid: num_iid, sku_id: sku_id, properties_name:properties_name, properties: properties)  unless Sku.find_by_sku_id(sku_id)
              end  
            else
              quantity = sku_items['num']
              #Remember to add account_id
              Sku.create!(product_id: local_product.id, quantity: quantity, num_iid: num_iid) unless Sku.find_by_num_iid(num_iid)
            end    
          end  
        end  
      end # num_iids each ends
    end # create_from_trades ends

   end  #self chain ends
 end
