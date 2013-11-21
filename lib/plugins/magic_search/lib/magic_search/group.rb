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

    # Example
    #   StockOutBill.group(:tid,:count.gt => 2)                 # 找出出库单重复的tid分组数量大于2的
    #   StockOutBill.group(:tid,:count => 2)                    # 找出出库单重复的tid分组数量等于2的
    #   StockOutBill.where(:status.ne => "CLOSED").group(:tid)  # 找出出库单状态不为"CLOSED"的tid分组数量大于1
    def group(*args)
      options = parse_args(args)
      conditions = where(default_group_options.merge(options)).selector
      collection.aggregate(build_query(args,conditions))
    end

    def parse_args(args)
      valid_fields(args)
      options = args.extract_options!
      options.symbolize_keys!
    end

    def default_group_options
      {:count.gt => 1,:_type => sti_name}.reject {|k,v| v.nil?}
    end

    # Single table name
    def sti_name
      fields["_type"] && hereditary? && fields["_type"].options[:default]
    end

    # klass.convert_keys([:tid,:account_id])  # => {:tid => "$tid",:account_id => "$account_id"}
    def convert_keys(args)
      args.reduce(Hash.new){|con,key| con[key] = "$#{key}"; con}
    end

    def build_query(args,conditions)
      match = {"count" => conditions.delete("count")}
      aggregate = []
      aggregate << {"$match" => conditions} if conditions.present?
      aggregate << {"$group" => {
          "_id" => convert_keys(args),
          count: {"$sum" => 1}
          }
        }
      aggregate << {"$match" => match}
    end

    def valid_fields(args)
      rel = []
      raise "Not defined fields `#{rel.join(',')}' for #{self.inspect}" if args.any? {|x| rel << x if self.fields[x.to_s].nil?}
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