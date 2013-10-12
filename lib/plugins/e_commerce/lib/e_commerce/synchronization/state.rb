#encoding: utf-8
require "e_commerce/core_ext/array/delete"
require "e_commerce/core_ext/hash/convert_value"

module ECommerce
  #同步类
  module Synchronization
    module State
      attr_accessor :changed,:latest,:alias_columns

      def parsing
        @changed ||= []
        @latest ||= []

        response_ary = response
        rdup = response_ary.dup

        relations(response_ary).find_each do |record|
          attrs = response_ary.delete {|u| u[primary_key].to_s == record.send(primary_key).to_s}
          update_attributes(record,attrs)
          @changed << record if record.changed?
        end

        response_ary.each do |attrs|
          record = update_attributes(klass.new,attrs)
          @latest << record if record.present?
        end
        rdup
      end

      def perform(iden=nil)
        hash = {:changed => @changed,:latest => @latest}

        records = if iden.present?
          raise "参数必须是 #{hash.keys} 中的" if !hash.key?(iden.to_sym)
          hash[iden.to_sym]
        else
          hash.values.flatten.compact
        end
        records.map(&:save!)
      end

      def relations(response)
        klass.where(primary_key => response.map { |u| u[primary_key.to_s] })
      end

      def fields
        klass.columns_hash.keys + alias_columns.keys + nested_columns
      end

      private
      def update_attributes(record,attrs)
        attrs.merge!(default_attributes)
        attrs.stringify_keys!
        attrs.slice(*fields).each_pair { |column_name,value| record.send("#{alias_column(column_name)}=",mongoize(column_name,value))}
        record
      end

      def mongoize(column,value)
        column = alias_column(column)

        if nested_columns.include?(column)
          value
        else
          klass.columns_hash[column].klass.mongoize(value)
        end
      end

      def alias_columns
        @alias_columns ||= {}
      end
      
      def nested_columns
        klass.nested_attributes_options.collect {|k,v| "#{k}_attributes"}
      end

      def alias_column(column_name)
        alias_columns[column_name] || column_name
      end

      def default_attributes
        @default_attributes || {}
      end
    end
  end
end