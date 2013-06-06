module MagicEnum
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def enum_attr(*args)
      raise ArgumentError, "You have to supply at least two format like :attr_name,[['China',1],.....]" if args.empty?

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

      validates _attr.to_sym,:presence => true, :inclusion => { :in => const_get(const_value) } if respond_to?(:validates)

      define_method("#{_attr}_name") do
        raise NoMethodError,"Not defined #{_attr}" if !respond_to?("#{_attr}")
        if ary = summary.rassoc(send(_attr))
          ary.__send__(:first)
        end
      end if !respond_to?("#{_attr}_name")

      summary.each do |name,target|
        define_method("#{_attr}_#{target.to_s.downcase}?") { eval("#{_attr} == '#{target}'") }
      end
    end

    private
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