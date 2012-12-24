# Load the redis.yml configuration file
unless Rails.env.test?
  redis_config = YAML.load_file(Rails.root.join('config', 'redis.yml'))[Rails.env]
  # Connect to Redis using the redis_config host and port
  if redis_config
    $redis = Redis::Namespace.new(host: redis_config['host'], port: redis_config['port'])
  end
end