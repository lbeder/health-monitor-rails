require 'health_monitor/providers/base'

module HealthMonitor
  module Providers
    class RedisException < StandardError; end

    class Redis < Base
      class Configuration
        DEFAULT_URL = nil

        attr_accessor :url, :connection

        def initialize
          @url = DEFAULT_URL
        end
      end

      class << self
        private

        def configuration_class
          ::HealthMonitor::Providers::Redis::Configuration
        end
      end

      def check!
        time = Time.now.to_s(:rfc2822)

        redis = if configuration.connection
          configuration.connection
        elsif configuration.url
          ::Redis.new(url: configuration.url)
        else
          ::Redis.new
        end

        redis.set(key, time)
        fetched = redis.get(key)

        raise "different values (now: #{time}, fetched: #{fetched})" if fetched != time
      rescue Exception => e
        raise RedisException.new(e.message)
      ensure
        redis.close
      end

      private

      def key
        @key ||= ['health', request.try(:remote_ip)].join(':')
      end
    end
  end
end
