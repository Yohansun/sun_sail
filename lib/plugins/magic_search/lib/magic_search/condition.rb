require 'magic_search/relation_ship'
require 'magic_search/parse_search'
module MagicSearch
  class Condition
    attr_accessor :relations,:relation_ship
    def initialize(klass,searches)
      @klass = klass
      @relations = klass.relations
      @conditions = {}
      @relation_ship = RelationShip.new(klass)
      @parameters = searches.stringify_keys || {}
    end

    def to_condition
      @parameters.each_pair { |k,v| @conditions.deep_merge!(parse_key(k,v)) }
      @conditions
    end

    # params[:search]  # => {:name_like => "ddl1st"}
    # result {"seller_name" => { "$regex"=> /ddl1st/ }}
    def parse_key(search_key,search_value)
      fields = @relation_ship.all_fields_name | @klass.fields.keys | ["_type"]
      parse_search = ParseSearch.new(search_key,search_value)
      relation_name,field_name = parse_search.parsed_keys(@relations.keys,fields)
      fielklass = field_klass(relation_name,field_name)
      parse_search.build_condition(fielklass,relation_name,field_name)
    end
    
    def field_klass(relation_name,field_name)
      relation_klass = nil
      relation = relation_name && @relations[relation_name]
      realtion_klass = relation.class_name.constantize if relation.present?
      (realtion_klass || @klass).fields[field_name]
    end
  end
end