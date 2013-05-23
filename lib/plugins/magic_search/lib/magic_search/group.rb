#encoding: utf-8
module MagicSearch
  module Group
    def group_by(*args)
      options = args.extract_options!
      options.stringify_keys!
      options["selects"] ||= []
      options["selects"] = Array.wrap(options["selects"]).map(&:to_s)
      options["$limit"] = options["limit"] ||= 20
      args = args.map(&:to_s)
      valid_args(args,options)
      cond = ParseParameter.new(args,options,fields.keys)
      collection.aggregate(cond.query,options.slice("$limit","$sort"))
    end
    
    private 
    def valid_args(args,options)
      fieldsname = fields.keys
      targes = (args + options["selects"]).uniq
      targes = targes.map(&:to_s)
      foo = targes | fieldsname
      raise "not found fields #{(foo - fieldsname).join(',')}" if foo.sort != fieldsname.sort
      raise "can't be blank" if args.blank?
    end
    
    class ParseParameter
      attr_accessor :group_fields,:selects
      def initialize(args,options,fieldsname)
        @options      = options
        @args         = args
        @fieldsname   = fieldsname
        @group_fields = compose_group
        @selects      = compose_selects.except("_id")
      end
      
      def compose_group
        @group_fields = if @args.length < 2
          {"_id" => "$#{@args.first}"}
        else
          foo = {}
          @args.each {|arg| foo.merge!({"#{arg}" => "$#{arg}"}) }
          {"_id" => foo}
        end
      end
      
      def compose_selects
        if @options["selects"].blank?
          keep_fields = @fieldsname - @args
          selects(keep_fields)
        else
          selects(@options["selects"])
        end
      end
      
      def query
        @query = {"$group" => {}}
        @query["$group"].merge!(@group_fields)
        @query["$group"].merge!(@selects)
        @query["$group"].merge!({"count" => {"$sum" =>1} })
        @query
      end
      
      private
      def selects(keep_fields)
        @selects ||= {}
        keep_fields.each {|field| @selects.merge!({field => {"$first" => "$#{field}"}})}
        @selects
      end
    end
  end
end