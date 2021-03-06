require 'e_commerce/synchronization/state'
require 'e_commerce/synchronization/set'
require 'e_commerce/notifer_exception'
module ECommerce
  #同步类
  module Synchronization
    class Base
      include ECommerce::Synchronization::State
      include ECommerce::Synchronization::Set
      include ECommerce::NotiferException

      attr_accessor :klass

      def self.inherited(base)
        base.class_eval {
          def klass
            @klass ||= self.class.name.gsub(/Sync$/,'').constantize
          end
        }
      end

      def initialize(*args)
        response
        raise "alias_columns must be Hash" unless alias_columns.is_a?(Hash)
        raise "Not initialized `identifier' for #{self.class.name}" if primary_key.blank?
        raise NameError,"uninitialized constant #{klass}" if !Object.const_defined?(klass.to_s)
        @changed = []
        @latest = []
      end

      def response
        raise "Not defined method #response in #{self.class.name}"
      end
    end
  end
end