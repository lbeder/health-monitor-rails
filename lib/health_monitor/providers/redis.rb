# frozen_string_literal: true

require 'health_monitor/providers/base'

module HealthMonitor
  module Providers
    CONNECTION_POOL_SIZE = 1

    class RedisException < StandardError; end

    class Redis < Base
      class Configuration < Base::Configuration
        DEFAULT_URL = nil

        attr_accessor :url, :connection, :max_used_memory

        def initialize(provider)
          super

          @url = DEFAULT_URL
        end
      end

      class << self
        private

        def as_connection_pool(connection)
          ConnectionPool.new(size: CONNECTION_POOL_SIZE) { connection }
        end
      end

      def check!
        check_values!
        check_max_used_memory!
      rescue Exception => e
        raise RedisException.new(e.message)
      end

      private

      def configuration_class
        ::HealthMonitor::Providers::Redis::Configuration
      end

      def check_values!
        time = Time.now.to_formatted_s(:rfc2822)

        redis.with { |conn| conn.set(key, time) }
        fetched = redis.with { |conn| conn.get(key) }

        raise "different values (now: #{time}, fetched: #{fetched})" if fetched != time
      end

      def check_max_used_memory!
        return unless configuration.max_used_memory
        return if used_memory_mb <= configuration.max_used_memory

        raise "#{used_memory_mb}Mb memory using is higher than #{configuration.max_used_memory}Mb maximum expected"
      end

      def key
        @key ||= ['health', request.try(:remote_ip)].join(':')
      end

      def redis
        @redis =
          if configuration.connection
            if configuration.connection.is_a?(ConnectionPool)
              configuration.connection
            else
              ConnectionPool.new(size: CONNECTION_POOL_SIZE) { configuration.connection }
            end
          elsif configuration.url
            ConnectionPool.new(size: CONNECTION_POOL_SIZE) { ::Redis.new(url: configuration.url) }
          else
            ConnectionPool.new(size: CONNECTION_POOL_SIZE) { ::Redis.new }
          end
      end

      def bytes_to_megabytes(bytes)
        (bytes.to_f / 1024 / 1024).round
      end

      def used_memory_mb
        bytes_to_megabytes(redis.with { |conn| conn.info['used_memory'] })
      end
    end
  end
end
