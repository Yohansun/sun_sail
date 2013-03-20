require "redis"
require "redis-namespace"
redis_config = YAML.load_file("#{Rails.root}/config/redis.yml")[Rails.env]
$redis = Redis::Namespace.new(redis_config['namespace'], :redis => $redis)