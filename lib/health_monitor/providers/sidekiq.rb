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

      end

      def check!
        check_workers!
        check_latency!
        check_redis!
      rescue Exception => e
        if e.class.superclass == HealthWarning
          raise e
        else 
          raise SidekiqException.new(e.message) 
        end
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

      def check_latency!
        latency = ::Sidekiq::Queue.new.latency

        raise LatencyError.new(
          "latency #{latency} is greater than #{configuration.error_latency}"
          ) if latency > configuration.error_latency
        raise LatencyWarning.new(
          "latency #{latency} is greater than #{configuration.warning_latency}"
          ) if configuration.warning_latency and latency > configuration.warning_latency

        
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
