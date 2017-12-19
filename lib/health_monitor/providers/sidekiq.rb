require 'health_monitor/providers/base'
require 'sidekiq/api'

module HealthMonitor
  module Providers
    class SidekiqException < HealthError; end
    class LatencyError < HealthError; end
    class LatencyWarning < HealthWarning; end
    class Sidekiq < Base
      class Configuration
        DEFAULT_LATENCY_TIMEOUT = 30

        attr_accessor :error_latency, :warning_latency, :latency

        def initialize
          @latency = DEFAULT_LATENCY_TIMEOUT
        end

        def error_latency
          @error_latency || @latency
        end

        def warn_latency
          @warning_latency || Float::INFINITY
        end
      end

      def check!
        check_workers!
        check_processes!
        check_latency!
        check_redis!
      rescue HealthWarning => e
        raise e
      rescue Exception => e
        raise SidekiqException.new(e.message)
      end

      private

      class << self
        private

        def configuration_class
          ::HealthMonitor::Providers::Sidekiq::Configuration
        end
      end

      def check_workers!
        ::Sidekiq::Workers.new.size
      end

      def check_processes!
        sidekiq_stats = ::Sidekiq::Stats.new
        return unless sidekiq_stats.processes_size.zero?

        raise 'Sidekiq alive processes number is 0!'
      end

      def check_latency!
        latency = ::Sidekiq::Queue.new.latency
        if latency > configuration.error_latency
          raise LatencyError.new(
            "latency #{latency} is greater than #{configuration.error_latency}"
          )
        elsif latency > configuration.warn_latency
          raise LatencyWarning.new(
            "latency #{latency} is greater than #{configuration.warn_latency}"
          )
        end
      end

      def check_redis!
        if ::Sidekiq.respond_to?(:redis_info)
          ::Sidekiq.redis_info
        else
          ::Sidekiq.redis(&:info)
        end
      end
    end
  end
end
