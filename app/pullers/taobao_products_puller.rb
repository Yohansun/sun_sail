# encoding : utf-8 -*-
class TaobaoProductsPuller
  class << self

    # Below methods are strongly recommed to use oauth2.

    # after create products, remember to sync cat_name
    def sync_cat_name(trade_source_id)
      trade_source = TradeSource.find_by_id(trade_source_id)
      account = Account.find_by_id(trade_source.account_id)

      account.products.each do |product|
        response = TaobaoQuery.get({method: 'taobao.product.get', fields: 'cat_name', product_id: product.product_id}, trade_source_id)
        if response['product_get_response'].present? &&  response['product_get_response']['product'].present?
          response = response['product_get_response']['product']
          if response['cat_name'].present?
            category = account.categories.where(name: response['cat_name']).first_or_create
          else
            category = account.categories.where(name: '其他').first_or_create
          end
          product.cat_name = response['cat_name']
          product.category_id = category.id
          product.save!
          taobao_product = account.taobao_products.where(product_id: product.product_id).first
          if taobao_product
            taobao_product.category_id = category.id
            taobao_product.cat_name = response['cat_name']
            taobao_product.save!
          end
        end
      end
    end


    def create_item!(trade_source_id, num_iid)
      trade_source = TradeSource.find_by_id(trade_source_id)
      account = Account.find_by_id(trade_source.account_id)
      nick = trade_source.name rescue nil
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

        local_product = account.products.find_by_num_iid(num_iid)
        unless local_product
          local_product = account.products.create(name: name, detail_url: detail_url, outer_id: outer_id,  num_iid: num_iid, product_id: product_id, cid: cid, pic_url: pic_url, price: price)
        end
        taobao_product = account.taobao_products.find_by_num_iid(local_product.num_iid)
        unless taobao_product
          taobao_product = account.taobao_products.create(category_id: local_product.category_id, num_iid: local_product.num_iid, price: local_product.price, outer_id: local_product.outer_id, product_id: local_product.product_id, cat_name: local_product.cat_name, pic_url: local_product.pic_url, cid: local_product.cid, name: local_product.name)
        end
        if sku_items['skus'] && sku_items['skus']['sku'].count > 0
          sku_items['skus']['sku'].each do |sku|
            sku_id = sku['sku_id']
            quantity = sku['quantity']
            properties_name = sku['properties_name']
            properties = sku['properties']
            taobao_sku = taobao_product.taobao_skus.where(account_id: account.id,sku_id: sku_id).first
            unless taobao_sku
              taobao_sku = taobao_product.taobao_skus.create(account_id: account.id, num_iid: num_iid, sku_id: sku_id, properties_name: properties_name, properties: properties)
            end
            sku = local_product.skus.where(account_id: account.id, sku_id: sku_id).first
            unless sku
              sku = local_product.skus.create(account_id: account.id, num_iid: num_iid, sku_id: sku_id, properties_name: properties_name, properties: properties)
              local_product.stock_products.create(seller_id: account.sellers.first.id, sku_id: sku.id, num_iid: num_iid, account_id: account.id, max: 999999, actual: quantity, activity: quantity, safe_value: 20)
              SkuBinding.where(sku_id: sku.id, taobao_sku_id: taobao_sku.id, number: 1).first_or_create
            end
          end
        else
          quantity = sku_items['num']
          taobao_sku = taobao_product.taobao_skus.first
          unless taobao_sku
            taobao_sku = taobao_product.taobao_skus.create(account_id: account.id, num_iid: num_iid)
          end
          sku = local_product.skus.first
          unless sku
            sku = local_product.skus.create(account_id: account.id, num_iid: num_iid)
            local_product.stock_products.create(seller_id: account.sellers.first.id, sku_id: sku.id, num_iid: num_iid, account_id: account.id, max: 999999, actual: quantity, activity: quantity, safe_value: 20)
            SkuBinding.where(sku_id: sku.id, taobao_sku_id: taobao_sku.id, number: 1).first_or_create
          end
        end
      end
    end

    def create!(trade_source_id)
      trade_source = TradeSource.find_by_id(trade_source_id)
      account = Account.find_by_id(trade_source.account_id)

      # 每个店铺的create!方法只应该在店铺初始化的时候走一次
      return if account.products.exists?

      total_pages = nil
      page_no = 0
      nick = trade_source.name rescue nil

      num_iids = []
      begin
        #调用taobao.items.onsale.get获取获取当前用户作为卖家的出售中的商品num_iid
        items_onsale_response = TaobaoQuery.get({method: 'taobao.items.onsale.get', fields: 'num_iid', nick: nick, page_no: page_no, page_size: 40}, trade_source_id)
        if items_onsale_response['items_onsale_get_response']['items'].present? &&  items_onsale_response['items_onsale_get_response']['items']['item'].present?
          items = items_onsale_response['items_onsale_get_response']['items']['item']
          total_results = items_onsale_response['items_onsale_get_response']['total_results'].to_i
          total_pages ||= total_results / 40
          next if total_results < 1
          items.each do |item|
            num_iids << item['num_iid']
          end
        end
        page_no += 1
      end until(page_no > total_pages || total_pages == 0)

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
          local_product = account.products.find_by_num_iid(num_iid)
          unless local_product
            local_product = account.products.create(name: name, detail_url: detail_url, outer_id: outer_id,  num_iid: num_iid, product_id: product_id, cid: cid, pic_url: pic_url, price: price)
          end
          taobao_product = account.taobao_products.find_by_num_iid(local_product.num_iid)
          unless taobao_product
            taobao_product = account.taobao_products.create(category_id: local_product.category_id, num_iid: local_product.num_iid, price: local_product.price, outer_id: local_product.outer_id, product_id: local_product.product_id, cat_name: local_product.cat_name, pic_url: local_product.pic_url, cid: local_product.cid, name: local_product.name)
          end
          if sku_items['skus'] && sku_items['skus']['sku'].count > 0
            sku_items['skus']['sku'].each do |sku|
              sku_id = sku['sku_id']
              quantity = sku['quantity']
              properties_name = sku['properties_name']
              properties = sku['properties']
              taobao_sku = taobao_product.taobao_skus.where(account_id: account.id,sku_id: sku_id).first
              unless taobao_sku
                taobao_sku = taobao_product.taobao_skus.create(account_id: account.id, num_iid: num_iid, sku_id: sku_id, properties_name: properties_name, properties: properties)
              end
              sku = local_product.skus.where(account_id: account.id, sku_id: sku_id).first
              unless sku
                sku = local_product.skus.create(account_id: account.id, num_iid: num_iid, sku_id: sku_id, properties_name: properties_name, properties: properties)
                local_product.stock_products.create(seller_id: account.sellers.first.id, sku_id: sku.id, num_iid: num_iid, account_id: account.id, max: 999999, actual: quantity, activity: quantity, safe_value: 20)
                SkuBinding.where(sku_id: sku.id, taobao_sku_id: taobao_sku.id, number: 1).first_or_create
              end
            end
          else
            quantity = sku_items['num']
            taobao_sku = taobao_product.taobao_skus.first
            unless taobao_sku
              taobao_sku = taobao_product.taobao_skus.create(account_id: account.id, num_iid: num_iid)
            end
            sku = local_product.skus.first
            unless sku
              sku = local_product.skus.create(account_id: account.id, num_iid: num_iid)
              local_product.stock_products.create(seller_id: account.sellers.first.id, sku_id: sku.id, num_iid: num_iid, account_id: account.id, max: 999999, actual: quantity, activity: quantity, safe_value: 20)
              SkuBinding.where(sku_id: sku.id, taobao_sku_id: taobao_sku.id, number: 1).first_or_create
            end
          end
        end
      end # num_iids each ends

    end # create ends

    def create_from_trades!(trade_source_id)
      trade_source = TradeSource.find_by_id(trade_source_id)
      account = Account.find_by_id(trade_source.account_id)

      # 每个店铺的create_from_trades!方法只应该在店铺初始化的时候走一次
      return if account.products.exists?

      trades = Trade.where(trade_source_id: trade_source_id).only("taobao_orders.num_iid")
      num_iids = trades.map(&:taobao_orders).flatten.map(&:num_iid).flatten.uniq
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

          local_product = account.products.find_by_num_iid(num_iid)
          unless local_product
            local_product = account.products.create(name: name, detail_url: detail_url, outer_id: outer_id,  num_iid: num_iid, product_id: product_id, cid: cid, pic_url: pic_url, price: price)
          end
          taobao_product = account.taobao_products.find_by_num_iid(local_product.num_iid)
          unless taobao_product
            taobao_product = account.taobao_products.create(category_id: local_product.category_id, num_iid: local_product.num_iid, price: local_product.price, outer_id: local_product.outer_id, product_id: local_product.product_id, cat_name: local_product.cat_name, pic_url: local_product.pic_url, cid: local_product.cid, name: local_product.name)
          end
          if sku_items['skus'] && sku_items['skus']['sku'].count > 0
            sku_items['skus']['sku'].each do |sku|
              sku_id = sku['sku_id']
              quantity = sku['quantity']
              properties_name = sku['properties_name']
              properties = sku['properties']
              taobao_sku = taobao_product.taobao_skus.where(account_id: account.id,sku_id: sku_id).first
              unless taobao_sku
                taobao_sku = taobao_product.taobao_skus.create(account_id: account.id, num_iid: num_iid, sku_id: sku_id, properties_name: properties_name, properties: properties)
              end
              sku = local_product.skus.where(account_id: account.id, sku_id: sku_id).first
              unless sku
                sku = local_product.skus.create(account_id: account.id, num_iid: num_iid, sku_id: sku_id, properties_name: properties_name, properties: properties)
                local_product.stock_products.create(seller_id: account.sellers.first.id, sku_id: sku.id, num_iid: num_iid, account_id: account.id, max: 999999, actual: quantity, activity: quantity, safe_value: 20)
                SkuBinding.where(sku_id: sku.id, taobao_sku_id: taobao_sku.id, number: 1).first_or_create
              end
            end
          else
            quantity = sku_items['num']
            taobao_sku = taobao_product.taobao_skus.first
            unless taobao_sku
              taobao_sku = taobao_product.taobao_skus.create(account_id: account.id, num_iid: num_iid)
            end
            sku = local_product.skus.first
            unless sku
              sku = local_product.skus.create(account_id: account.id, num_iid: num_iid)
              local_product.stock_products.create(seller_id: account.sellers.first.id, sku_id: sku.id, num_iid: num_iid, account_id: account.id, max: 999999, actual: quantity, activity: quantity, safe_value: 20)
              SkuBinding.where(sku_id: sku.id, taobao_sku_id: taobao_sku.id, number: 1).first_or_create
            end
          end
        end
      end # num_iids each ends
    end # create_from_trades ends

   end  #self chain ends
 end
