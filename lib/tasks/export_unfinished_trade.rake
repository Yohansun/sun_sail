# -*- encoding:utf-8 -*-

desc "导出交易还未成功订单数据"
task :export_unfinished_trade => :environment do
  account = Account.find_by_name("多乐士官方旗舰店")

  unknown_trades = []
  unimported_color_info = []
  unimported_color_num = []
  CSV.foreach("#{Rails.root}/import_unfinished_dulux_trade.csv") do |row|

    ## 导出未完成订单
    tid = row[1]
    trade = nil

    if row[0] == "unfinished"
      p "导出未完成订单#{tid}"
      trade = account.trades.where(tid: tid).first

      ## 导出找不到的trade
      if trade.present?
        trade.update_attributes(JSON.parse(row[2]))
      else
        unknown_trades << tid
        next
      end

    else
      p "导出已完成订单#{tid}"
      trade = account.trades.where(tid: tid).first
      if trade.present?
        trade.update_attributes(JSON.parse(row[2]))
      else
        trade = account.trades.create(JSON.parse(row[2]))
      end
    end

    ## 调色信息转属性备注
    if row[3].present?
      trade.trade_property_memos.delete_all
      color_infos = JSON.parse(row[3])
      color_infos.each do |color_info|
        oid = color_info.keys[0]
        values = color_info.values[0]
        values.each do |value|
          if value['colors'].present?
            order = trade.orders.where(oid: oid).first

            ## 导出找不到的子订单的调色信息
            if order.blank?
              unimported_color_info << [trade.id, oid, value['colors']]
              next
            end

            ## 写入调色信息
            value['colors'].each do |color_value, color_num|
              category_property_value = CategoryPropertyValue.find_by_value(color_value)

              ## 导出找不到的颜色和此颜色对应的子订单的调色信息
              if category_property_value.blank?
                unimported_color_num << color_value
                unimported_color_info << [trade.id, oid, value['colors']]
                next
              end
              category_property_name = category_property_value.category_property.name
              color_num[0].times do
                property_memo = order.trade_property_memos.create(
                  trade_id:          trade.id,
                  outer_id:          value['iid'],
                  account_id:        account.id,
                )
                property_memo.property_values.create(
                  category_property_value_id: category_property_value.id,
                  value:                      category_property_value.value,
                  name:                       category_property_name
                )
                p property_memo
              end
            end

          end
        end

      end
    end
  end

  if unknown_trades.present?
    p "----这些订单并没有被抓取到，或者可能是多乐士线下订单或拆分订单----"
    p unknown_trades
  end

  if unimported_color_info.present?
    p "----这些子订单的调色信息没有设置-----"
    p unimported_color_info.uniq
  end

  if unimported_color_info.present?
    p "----这些颜色没有被初始化-----"
    p unimported_color_num.uniq
  end
end