require 'health_monitor/providers/base'
require 'sidekiq/api'

module HealthMonitor
  module Providers
    LATENCY_TIMEOUT = 30.freeze

    class SidekiqException < StandardError; end

    class Sidekiq < Base
      def check!
        check_workers!
        check_latency!
        check_redis!
      rescue Exception => e
        raise SidekiqException.new(e.message)
      end

      private

      def check_workers!
        ::Sidekiq::Workers.new.size
      end

      def check_latency!
        latency = ::Sidekiq::Queue.new.latency

        raise "latency #{latency} is greater than #{LATENCY_TIMEOUT}" if latency > LATENCY_TIMEOUT
      end

      def check_redis!
        ::Sidekiq.redis { |conn| conn.info }
      end
    end
  end
end
