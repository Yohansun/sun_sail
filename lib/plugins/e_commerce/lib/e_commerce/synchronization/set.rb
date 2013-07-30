module ECommerce
  module Synchronization
    module Set
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include,InstanceMethods)
      end
      
      module ClassMethods
        # class Foo
        #   set_variable :name,
        # end
        def set_variable(name,value=nil)
          define_method(name) do
            instance_variable_get("@#{name}") or
            instance_variable_set("@#{name}",value.is_a?(Proc) ? instance_eval(&value) : value)
          end
        end
      end
      
      module InstanceMethods
        def method_missing(method_id,value=nil, &block)
          if /^set_(?<name>\w+)/ =~ method_id
            raise "Already defined `#{name}'" if respond_to?(name)
            self.class.send(:define_method,name) { instance_variable_set("@_#{name}",value) }
          else
            super
          end
        end
      end
    end
  end
end