# -*- encoding:utf-8 -*-

desc "重新导入订单调色信息"
task :export_trade_memo_properties => :environment do

  account = Account.find_by_name("多乐士官方旗舰店")
  trade_source = account.taobao_sources.first

  unimported_color_info = []
  unimported_color_num = []

  CSV.foreach("#{Rails.root}/import_unfinished_dulux_trade.csv") do |row|
    tid = row[1]
    trade = account.trades.where(tid: tid).first

    ## 调色信息转属性备注
    if trade && row[3].present?
      p "导出调色信息#{tid}"
      trade.trade_property_memos.delete_all
      color_infos = JSON.parse(row[3])
      color_infos.each do |color_info|
        oid = color_info.keys[0]
        values = color_info.values[0]
        values.each do |value|

          next if value['iid'].blank?

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

  if unimported_color_info.present?
    p "----这些子订单的调色信息没有设置-----"
    p unimported_color_info.uniq
  end

  if unimported_color_info.present?
    p "----这些颜色没有被初始化-----"
    p unimported_color_num.uniq
  end

end