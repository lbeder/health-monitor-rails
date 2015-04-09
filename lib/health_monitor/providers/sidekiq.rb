require 'health_monitor/providers/base'
require 'sidekiq/api'

module HealthMonitor
  module Providers
    class SidekiqException < StandardError; end

    class Sidekiq < Base
      class Configuration
        DEFAULT_LATENCY_TIMEOUT = 30.freeze

        attr_accessor :latency

        def initialize
          @latency = DEFAULT_LATENCY_TIMEOUT
        end
      end

      def check!
        check_workers!
        check_latency!
        check_redis!
      rescue Exception => e
        raise SidekiqException.new(e.message)
      end

      private

      def self.configuration_class
        Configuration
      end

      def check_workers!
        ::Sidekiq::Workers.new.size
      end

      def check_latency!
        latency = ::Sidekiq::Queue.new.latency

        if latency > self.configuration.latency
          raise "latency #{latency} is greater than #{self.configuration.latency}"
        end
      end

      def check_redis!
        ::Sidekiq.redis { |conn| conn.info }
      end
    end
  end
end
