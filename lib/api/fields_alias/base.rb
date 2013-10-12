module FieldsAlias
  class Base < Hashie::Trash

    def initialize(attributes = {}, &block)
      assert_attributes!(attributes)
      super
    end

    def self.property(property_name, options = {})
      extracts << property_name if options.delete(:extract) == true
      properties_kana[property_name.to_sym] = options[:from] unless options[:form]
      super
    end

    def attributes
      to_hash.dup
    end

    def formater
      @new_hash = nil
      extract
    end

    def extract(hash=nil)
      @new_hash ||= {}
      hash ||= attributes

      hash.each do |key,value|

        if extract? key
          if @new_hash.key? key
            @new_hash[key] = @new_hash[key].to_a << value
          else
            @new_hash[key] = value
          end
        end

        extract(value) if value.is_a? Hash
        if value.is_a? Array
          value.reject {|v| !v.is_a? Hash}.each do |h|
            extract h
          end
        end

      end
      @new_hash
    end

    def self.extracts
      @extracts ||= []
    end

    def extract?(name)
      self.class.extracts.include? name.to_sym
    end

    private

    def self.properties_kana
      @properties_kana ||= {}
    end

    def assert_attributes!(attributes)
      attributes.reject! {|x,y| !self.class.translations.include?(x.to_sym)}
    end
  end

  class << self
    def third_part(name,api)
      klass = Class.new(Base)
      if FieldsAlias::Fields.third_part?(name)
        options = FieldsAlias::Fields.find(name,api)
        init!(klass,options)
      end
      klass
    end

    def init!(klass,hash)
      klass.class_eval do
        hash.each do |key,options|
          next if !options.is_a?(Hash)
          property key, options
        end
      end
    end
  end
end