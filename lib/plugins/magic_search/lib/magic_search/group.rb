#encoding: utf-8
module MagicSearch
  module Group
    # Example
    #   StockOutBill.group(:tid,:count.gt => 2)                 # 找出出库单重复的tid分组数量大于2的
    #   StockOutBill.group(:tid,:count => 2)                    # 找出出库单重复的tid分组数量等于2的
    #   StockOutBill.where(:status.ne => "CLOSED").group(:tid)  # 找出出库单状态不为"CLOSED"的tid分组数量大于1
    def group(*args)
      options = args.extract_options!
      args.any? {|x| raise "Not defined fields `#{rel.join(',')}' for #{self.inspect}" if self.fields[x.to_s].nil?}
      options.symbolize_keys!
      selector = where(default_group_options.merge(options)).selector
      collection.aggregate(build_query(args,selector))
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
      aggregate << {"$group" => {"_id" => convert_keys(args),count: {"$sum" => 1}}}
      aggregate << {"$match" => match}
    end
  end
end