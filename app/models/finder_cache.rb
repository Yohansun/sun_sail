module FinderCache
  NAMESPACE = name
  EXPIRES_TIME = 1.week

  def self.included(base)
    base.send(:extend,ClassMethods)
    base.class_eval do
      class << self
        def self.find(*args)
          super
        end

        alias_method_chain :find,:cache 
      end
    end
  end

  module ClassMethods

    def find_with_cache(*args)
      args.length == 1 ? fetch_cache(args.first) : find_without_cache(args)
    end

    def read_cache(primary_value)
      finder_cache.read(cache_path(primary_value),namespace: FinderCache::NAMESPACE)
    end

    def write_cache(primary_value)
      finder_cache.write(cache_path(primary_value),find_without_cache(primary_value),expires_in: FinderCache::EXPIRES_TIME,namespace: FinderCache::NAMESPACE)
      read_cache(primary_value)
    end
    
    def prefix
      name
    end
    
    def cache_path(name)
      [prefix,name].join('/')
    end

    def fetch_cache(primary_value)
      read_cache(primary_value) || write_cache(primary_value)
    end

    def finder_cache
      Rails.cache
    end
  end

  def cache_path
    [self.class.prefix,send(self.class.primary_key)].join("/")
  end
end