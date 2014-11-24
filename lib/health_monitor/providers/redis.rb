require 'health_monitor/providers/base'
require 'redis/namespace'

module HealthMonitor
  module Providers
    class RedisException < StandardError; end

    class Redis < Base
      def check!
        time = Time.now.to_s(:db)

        redis = ::Redis.new
        redis.set(key, time)
        fetched = redis.get(key)

        raise "different values (now: #{time}, fetched: #{fetched}" if fetched != time
      rescue => e
        raise RedisException.new(e.message)
      ensure
        redis.client.disconnect
      end

      private

      def key
        @key ||= ['health', request.try(:remote_ip)].join(':')
      end
    end
  end
end
