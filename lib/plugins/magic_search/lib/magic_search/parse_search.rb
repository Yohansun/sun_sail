module MagicSearch
  class ParseSearch
    attr_reader :splited_fields,:search_key,:search_value,:mode
    def initialize(search_key,search_value)
      @search_key = nil
      @search_value = search_value
      @mode = nil
      @search_type = default_where(search_key.dup)
      @searchs_attrs = {}
      @result = {}
    end
    
    def default_where(key)
      @where_mode = DEFALUT_WHERE.select {|k,v| /(#{k}|#{v[:alias]})$/.match(key) && (@search_key = key.gsub(/(#{k}|#{v[:alias]})$/,'')) && @mode = $& }
      raise "Not found mod: #{@search_key} search_key:#{key}" if @where_mode.blank?
      @where_mode[@mode]
    end
  
    def splited_key(keys,fields)
      @splited_fields = /(#{keys.join('|')})?_?(#{fields.join('|')})/.match(@search_key)
      @splited_fields
    end
  
    def parsed_keys(keys,fields)
      splited_key(keys,fields)
      @splited_fields.captures
    end
  
    def parse_value(field_klass)
      [DateTime,Date,Time,Integer,Float].any? {|obj| (field_klass.try(:type) == obj) && (@search_value = to_mongoize(field_klass,search_value)) }
      @search_value = @search_type[:convert].call(@search_value) if @search_type[:convert].present?
      
      @search_value = @search_type[:to].blank? ? @search_value : {"#{@search_type[:to]}" => @search_value}
    end
    
    def build_condition(field_klass,relation_name,field_name)
      parse_value(field_klass)
      
      if relation_name.blank?
        @result["#{field_name}"] = @search_value
      else
        @result["#{relation_name}"] = {"$elemMatch" => {"#{field_name}" => @search_value } }
      end
      @result
    end
    
    private
    def to_mongoize(field_klass,search_value)
      return (search_value == "nil" ? nil : search_value) if mode =~ /_not_eq|eq/
      search_value = search_value.to_time if field_klass.options[:type].eql?(DateTime)
      val = field_klass.mongoize(search_value) rescue ""
      val.nil? ? "" : val
    end
  end
end

