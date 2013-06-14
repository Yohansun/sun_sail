# encoding : utf-8 -*-
class TaobaoLogisticsOrdersPuller
  class << self
    def create(start_time = nil, end_time = nil, trade_source_id)
      total_pages = nil
      page_no = 0

      start_time ||= Time.now - 3.months
      end_time ||= Time.now

      trade_source = TradeSource.find_by_id(trade_source_id)
      account_id = trade_source.try(:account_id)

#      p "starting add_logistics.................."

      logistics_response = TaobaoQuery.get({method: 'taobao.logistics.companies.get', fields: 'code,name'}, trade_source_id)
      logistics = {}.tap do |lg|
        logistics_response['logistics_companies_get_response']['logistics_companies']['logistics_company'].each do |info|
          new_lg = Logistic.where(name: info["name"], code: info["code"], account_id: account_id).first_or_create
          lg[info["name"]] = [new_lg.id, info["code"]]
        end
      end

#      p "starting add_logistics_to_trades: since #{start_time}"

      begin
        response = TaobaoQuery.get({
          method: 'taobao.logistics.orders.get',
          fields: 'tid, out_sid, company_name',
          start_created: start_time.strftime("%Y-%m-%d %H:%M:%S"), end_created: end_time.strftime("%Y-%m-%d %H:%M:%S"),
          page_no: page_no, page_size: 40
          }, trade_source_id
        )

        unless response['logistics_orders_get_response']
#          p response
          break
        end

        total_results = response['logistics_orders_get_response']['total_results']
        total_results = total_results.to_i
        total_pages ||= total_results / 40

        next if total_results < 1
        shippings = response['logistics_orders_get_response']['shippings']['shipping']
        unless shippings.is_a?(Array)
          shippings = [] << shippings
        end
        next if shippings.blank?

        shippings.each do |shipping|
          next if shipping["company_name"] == nil
          trade = Trade.where(tid: shipping["tid"]).first
          if trade
            if shipping["company_name"] == "OTHER"
              trade.logistic_name = "其他"
            elsif logistics.keys.include?(shipping["company_name"]) != true
              trade.logistic_name = "其他"
            else
              trade.logistic_name = shipping["company_name"]
            end
            trade.logistic_waybill = shipping["out_sid"]
            trade.logistic_id = logistics[trade.logistic_name][0]
            trade.logistic_code = logistics[trade.logistic_name][1]

            trade.save
#            p "update trade #{trade.tid}"
          end
        end
        page_no += 1
        puts "PAGE " + page_no.to_s + " OF " + total_pages.to_s
      end until(page_no > total_pages || total_pages == 0)
    end

  end
end