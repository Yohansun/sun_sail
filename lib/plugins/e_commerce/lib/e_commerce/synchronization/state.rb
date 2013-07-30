#encoding: utf-8
require "e_commerce/core_ext/array/delete"
require "e_commerce/core_ext/hash/convert_value"

module ECommerce
  #同步类
  module Synchronization
    module State
      attr_accessor :changed,:latest,:removed

      def parsing
        @changed,@latest,@removed = Array.new(3) { [] }

        relations.find_each do |record|
          attrs = response.delete {|u| u[primary_key].to_s == record.send(primary_key).to_s}
          update_attributes(record,attrs)
          @changed << record if record.changed?
        end

        response.each do |attrs|
          @latest << update_attributes(klass.new,attrs)
        end
      end

      def perform
        sames = [@changed,@latest].flatten
        sames.map(&:save!) && @removed.map(&:destroy)
      end

      def relations
        klass.where(primary_key => response.map { |u| u[primary_key.to_s] })
      end

      def fields
        @fields ||= klass.columns_hash.keys
      end

      private
      def update_attributes(record,attrs)
        attrs.slice(*fields).each_pair { |column_name,value| record.send("#{column_name}=",mongoize(column_name,value))}
        record
      end

      def mongoize(column,value)
        klass.columns_hash[column].klass.mongoize(value)
      end
    end
  end
end