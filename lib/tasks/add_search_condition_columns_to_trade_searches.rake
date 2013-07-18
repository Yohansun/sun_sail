# -*- encoding:utf-8 -*-

desc "给旧的TradeSearch记录添加trade_type, trade_mode和search_hash属性"
task :add_search_condition_to_trade_searchs => :environment do
  TradeSearch.each do |t|
    next if t.search_hash.present?
    next if t.html.blank?

    search_hash = {}
    scan_results = t.html.scan(%r{<input type="hidden" name="([\w|-]*)" value="([\w|-]*)">})
    scan_results.each do |res|
      key = res.first
      search_hash[key] ||= []
      search_hash[key] << res.last
    end

    t.trade_mode = "trades"
    t.trade_type = "all"
    t.search_hash = search_hash
    t.save
  end
end
