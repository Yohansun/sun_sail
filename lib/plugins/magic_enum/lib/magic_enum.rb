#encoding: utf-8
module MagicEnum
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    ## enum_attr :status , [["Open",0],[,"Close",1],["ReOpen",2]],:not_valid => true
    ## :not_valid  true 不使用验证  默认false
    def enum_attr(*args)
      options = {:not_valid => false}
      options.merge!(args.pop) if args.last.is_a?(Hash)
      raise ArgumentError, "You have to supply at least two format like :attr_name,[['China',1],.....]" if args.empty?

      options[:not_valid] = options[:valid] ? false : true if options.key?(:valid)
      _attr = args.shift
      const, summary = _attr.upcase, args.pop

      raise ArgumentError, "The last argument must be Two-dimensional array" if summary.any? {|x| !x.is_a?(Array)}

      vals = summary.map(&:last)
      if vals.uniq.length != vals.length
        raise ArgumentError, "The parameter(last parameter in array) must be unique"
      end
      const_value = "#{const}_VALUES"

      [[const,summary],[const_value,summary.map(&:last)]].each do |name,val|
        silence_warnings {const_set(name,val)} if !const_defined?(name) || val != const_get(name)
      end

      if respond_to?(:validates) && !options[:not_valid]
        validates_presence_of   _attr.to_sym  , :if => proc { respond_to?(:columns_hash) && self.columns_hash[_attr.to_s].type == :boolean }
        validates_inclusion_of  _attr.to_sym  , :in => const_get(const_value)
      end

      define_method("#{_attr}_name") do
        raise NoMethodError,"Not defined #{_attr}" if !respond_to?("#{_attr}")
        if ary = summary.rassoc(send(_attr))
          ary.__send__(:first)
        end
      end

      summary.each do |name,target|
        define_method("#{_attr}_#{target.to_s.downcase}?") { __send__(_attr) == target }
      end
    end

    private
    #TODO Remove to object methods.
    def silence_warnings
      with_warnings(nil) { yield }
    end
    
    def with_warnings(flag)
      old_verbose, $VERBOSE = $VERBOSE, flag
      yield
    ensure
      $VERBOSE = old_verbose
    end
  end
end