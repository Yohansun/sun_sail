#encoding: utf-8
module CacheMethod
  extend ActiveSupport::Concern

  module ClassMethods
    # 缓存方法
    # Options:
    #   +class+         用来设置缓存失效的回调函数的类
    #   +expires+       缓存失效设置
    #     :in:            失效时间
    #     :if:            判断是否失效(暂未实现)
    #   +hook+          回调函数名称(比如 after_save), 需要当前类或者指定的 :class 支持
    #   +primary_key+   cache key 的后缀(用来区分同类的不同对象), 默认为当前对象的 :id ,如果当前对象没有 id 方法,则自己指定
    #   +foreign_key+   使缓存失效对应的 primary_key.
    #
    #    class Use
    #      include CacheMethod
    #
    #      def permission
    #        roles.map(&:permissions)
    #      end
    #      # 注意应该放在方法下面
    #      cache_method :permissions,class: Role,hook: :after_commit,foreign_key: :user_ids, expires: 1.hour
    #    end
    def cache_method(method_id,options={})
      options[:class] ||= self                                                                # User
      options[:primary_key] ||= :id                                                           # id
      options[:foreign_key] ||= options[:class].name.foreign_key if options[:class] != self   # user_id

      _validate_cache_options!(options)

      expires_in = (options[:expires].is_a?(Hash) ? expires[:in] : options[:expires]) || 1.hour

      cache_key = "#{self.name}/#{method_id}"

      cache_methods[method_id.to_sym] = options

      class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1

        def #{method_id}_with_cache_method(*args,&block)
          key = send(:#{options[:primary_key]})
          Rails.cache.fetch("#{cache_key}/" << key.to_s,namespace: "cache_method",expires_in: #{expires_in}) { #{method_id}_without_cache_method }
        end

        #{options[:class]}.class_eval do
          #{options[:hook]} do
            Array.wrap(send(:#{options[:foreign_key] || options[:primary_key]})).each do |k|
              Rails.cache.delete("#{cache_key}/" << k.to_s,namespace: "cache_method")
            end
          end
        end

        alias_method :#{method_id}_without_cache_method, :#{method_id}
        alias_method :#{method_id}, :#{method_id}_with_cache_method
      RUBY_EVAL
    end

    def cache_methods
      @_cache_methods ||= {}
    end

    private
    def _validate_cache_options!(options)
      options.assert_valid_keys(*[:expires,:hook,:class,:primary_key,:foreign_key])
      raise ArgumentError, "The option hook can't be nil" if options[:hook].nil?
    end
  end
end