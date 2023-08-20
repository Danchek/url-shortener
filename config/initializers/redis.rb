require 'connection_pool'
require 'redis'

redis_config = { host: 'localhost', port: 6379, db: 0 }

redis_connection_pool = ConnectionPool.new(size: 5, timeout: 5) do
  Redis.new(redis_config)
end

$redis = redis_connection_pool
