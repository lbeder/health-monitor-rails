require 'redis/namespace'

module HealthMonitor
  module Providers
    class RedisException < StandardError; end

    class Redis
      def check!
        time = Time.now.to_s(:db)

        r = ::Redis.new
        r.set(:health, time)
        fetched = r.get(:health)

        raise "different values (now: #{time}, fetched: #{fetched}" if fetched != time
      rescue => e
        raise RedisException.new(e.message)
      end
    end
  end
end
