require 'e_commerce/synchronization/state'
require 'e_commerce/synchronization/set'
module ECommerce
  #同步类
  module Synchronization
    class Base
      include State
      include Set

      attr_accessor :klass
      extend Module.new {
        def set_klass(name)
          define_method(:klass) { @klass = name.to_s.camelize }
        end

        def identifier(name)
          define_method(:primary_key) { @primary_key = name }
        end
      }

      def self.inherited(base)
        base.class_eval {
          def klass
            @klass ||= self.class.name.gsub(/Sync$/,'').constantize
          end
        }
      end

      def initialize(name)
        response
        raise "Not initialized `identifier' for #{self.class.name}" if primary_key.blank?
      end

      def response
        raise "Not defined method #response in #{self.class.name}"
      end
    end
  end
end