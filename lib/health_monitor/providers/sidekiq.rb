require 'health_monitor/providers/base'
require 'sidekiq/api'

module HealthMonitor
  module Providers
    class SidekiqException < StandardError; end

    class Sidekiq < Base
      class Configuration
        DEFAULT_LATENCY_TIMEOUT = 30

        attr_accessor :latency

        def initialize
          @latency = DEFAULT_LATENCY_TIMEOUT
        end
      end

      def check!
        check_workers!
        check_processes!
        check_latency!
        check_redis!
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
        if sidekiq_stats.processes_size.zero?
          raise 'Sidekiq alive processes number is 0!'
        end
      end

      def check_latency!
        latency = ::Sidekiq::Queue.new.latency

        return unless latency > configuration.latency

        raise "latency #{latency} is greater than #{configuration.latency}"
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
