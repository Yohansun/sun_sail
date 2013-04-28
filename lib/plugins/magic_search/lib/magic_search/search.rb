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

      def build_wheres(rebuild_searchs,parameter_key,parameter_key_value)

        @_relation_name, @_field_name,@item = parse_key(parameter_key)
        searchs_attrs = to_condition(@_relation_name,@_field_name,parameter_key_value,@item)
    
        rebuild_searchs.merge!(searchs_attrs) {|old,h1,h2| h1.merge!(h2)} if parameter_key_value.present?
      end
  
      def parse_key(parameter_key)
        _fields_name = nil
        _prefix_name = nil
        _relation_name = nil
        _realtions = self.embedded_relations
        _realtion = _realtions.select do |k,v|
          _relation_name,null =  /^(#{k})/.match(parameter_key).captures if  /^(#{k})/.match(parameter_key)
        end
      
        item = DEFALUT_WHERE.select do |k,v|
          _fields_name,_prefix_name = /(.+)(#{k}|#{v[:alias]})$/.match(parameter_key).captures rescue []
        
          if _relation_name
            _relation_name,_fields_name,_prefix_name = /^(#{_relation_name})_(.+)(#{k}|#{v[:alias]})$/.match(parameter_key).captures rescue []
          end
      
          /#{k}$/.match(_prefix_name) || /#{v[:alias]}$/.match(_prefix_name) if _prefix_name
        end
    
        [_realtion,_fields_name,item.values.shift]
      end
  
      def to_condition(_relation_name,_field_name,parameter_key_value,item)
        realtion_klass = _relation_name.values.shift.class_name.constantize rescue false
        field_klass = (realtion_klass || self).fields[_field_name]
    
        @news_value = if [DateTime,Date,Time].any? {|obj| field_klass.type.is_a?(obj)}
          field_klass.mongoize(parameter_key_value)
        else
          parameter_key_value
        end rescue(raise NoMethodError,"Not found method #{_field_name}")
    
        _mod,_convert = item[:to], item[:convert]

        searchs_attrs = Hash.new{|k,v| k[v] = Hash.new {|i,o| i[o] = {}}}
    
        @news_value = (_convert.blank? ? @news_value :  _convert.call(parameter_key_value))
      
        if _relation_name.present?
          eval("searchs_attrs[\"#{_relation_name.keys.first}.#{_field_name}\"]%s = @news_value" % (_mod.present? ? "[_mod]" : "") )
        else
          eval("searchs_attrs[_field_name]%s = @news_value" % (_mod.present? ? "[_mod]" : "") )
        end
      
        searchs_attrs
      end
    end
  end
end