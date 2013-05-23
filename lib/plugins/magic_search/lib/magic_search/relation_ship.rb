module MagicSearch
  class RelationShip
    attr_accessor :all_fields
    def initialize(klass)
      @relations = klass.embedded_relations
      @relation_names = @relations.keys
      @relation_klass_name = relations_klass_names
    end

    def relations_klass_names
      @relations.map(&:last).map(&:class_name)
    end

    def relations_klass
      relations_klass_names.collect {|klass| klass.constantize}
    end

    def all_fields
      @all_fields ||= relations_klass.map(&:fields).flatten
    end
  
    def all_fields_name
      all_fields.map(&:keys).flatten
    end
  end
end