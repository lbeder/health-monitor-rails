require 'health_monitor/providers/base'
require 'redis/namespace'

module HealthMonitor
  module Providers
    class RedisException < StandardError; end

    class Redis < Base
      def check!
        time = Time.now.to_s(:db)

        r = ::Redis.new
        r.set(key, time)
        fetched = r.get(key)

        raise "different values (now: #{time}, fetched: #{fetched}" if fetched != time
      rescue => e
        raise RedisException.new(e.message)
      end

      private

      def key
        @key ||= ['health', request.try(:remote_ip)].join('_')
      end
    end
  end
end
