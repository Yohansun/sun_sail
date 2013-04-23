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

      const_set(const,summary) if !const_defined?(const) || summary != const_get(const)
      define_method("#{_attr}_name") do
        raise NoMethodError,"Not defined #{_attr}" if !respond_to?("#{_attr}")
        summary.rassoc(send(_attr)).try(:first) 
      end if !respond_to?("#{_attr}_name")
    end
  end
end