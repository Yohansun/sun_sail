module MagicSearch
  class ParseSearch
    attr_reader :splited_fields,:search_key,:search_value
    def initialize(search_key,search_value)
      @search_key = search_key.dup
      @search_value = search_value
      @mode = nil
      @search_type = default_where
      @searchs_attrs = {}
      @result = {}
    end
  
    def default_where
      default_where = DEFALUT_WHERE.select {|k,v| /(#{k}|#{v[:alias]})$/.match(@search_key) && @search_key.gsub!(/(#{k}|#{v[:alias]})$/,'') && @mode = $& }
      default_where[@mode]
    end
  
    def splited_key(keys,fields)
      @splited_fields = /(#{keys.join('|')})?_?(#{fields.join('|')})/.match(@search_key)
      raise "not found method #{search_key}" if @splited_fields.blank?
      @splited_fields
    end
  
    def parsed_keys(keys,fields)
      splited_key(keys,fields)
      @splited_fields.captures
    end
  
    def parse_value(field_klass)
      [DateTime,Date,Time,Integer,Float].any? {|obj| (field_klass.type == obj) && (@search_value = field_klass.mongoize(@search_value)) }
      @search_value = @search_type[:convert].call(@search_value) if @search_type[:convert].present?
      if @search_value.blank? || @search_value.is_a?(Array) && @search_value.join.blank?
        @search_value = nil 
        return
      end
      @search_value = @search_type[:to].blank? ? @search_value : {"#{@search_type[:to]}" => @search_value}
    end
    
    def build_condition(field_klass,relation_name,field_name)
      parse_value(field_klass)
      
      return {} if @search_value.blank?
      if relation_name.blank?
        @result["#{field_name}"] = @search_value
      else
        @result["#{relation_name}"] = {"$elemMatch" => {"#{field_name}" => @search_value } }
      end
      @result
    end
  end
end