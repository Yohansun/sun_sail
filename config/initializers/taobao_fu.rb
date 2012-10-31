require 'taobao_fu'

select_source_function = %q{
	def self.select_source(source_id)
    source = TradeSource.find_by_id(source_id)

    if source
      settings = {}
      settings['app_key'] = source.app_key
      settings['secret_key'] = source.secret_key
      settings['session'] = source.session
      TaobaoFu.settings = settings
    end
  end
}

TaobaoFu.module_eval(select_source_function)