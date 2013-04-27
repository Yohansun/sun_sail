module MagicSearch
  module Search

    module ClassMethods
      def search(searchs)
        searchs = {} if searchs.blank?
        rebuild_searchs = {}
        searchs.tap do |parameters|
          parameters.each do |k,v|
            build_wheres(rebuild_searchs,k,v)
          end
        end
        result(rebuild_searchs)
      end

  
      private
      def result(conditions)
        where(conditions)
      end

      def build_wheres(rebuild_searchs,key,value)
        news_key      = nil
        news_value    = nil
        _key          = nil
        item = DEFALUT_WHERE.select do |k,v|
          news_key,_key = (/(.+)(#{k}|#{v[:alias]})$/.match(key).captures) rescue []
        end

        klass = self.fields[_key]
        news_value = if self == DateTime || self == Date || self == Time
          klass.mongoize(value)
        else
          value
        end
    
        _mod = item[_key] && item[_key][:to]

        searchs_attrs = {}
        searchs_attrs[news_key] = {}
        
        _convert = item[_key][:convert]
        
        news_value = (_convert.blank? ? news_value :  _convert.call(value))

        if _mod.present?
          searchs_attrs[news_key][_mod]     = news_value
        else
          searchs_attrs[news_key]           = news_value
        end
    
        rebuild_searchs.merge!(searchs_attrs) if value.present?
      end
    end
  end
end