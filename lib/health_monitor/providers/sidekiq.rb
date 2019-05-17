# frozen_string_literal: true

require 'health_monitor/providers/base'
require 'sidekiq/api'

module HealthMonitor
  module Providers
    class SidekiqException < StandardError; end

    class Sidekiq < Base
      class Configuration
        DEFAULT_QUEUE_NAME = 'default'
        DEFAULT_LATENCY_TIMEOUT = 30
        DEFAULT_QUEUES_SIZE = 100

        attr_reader :queues

        def initialize
          @queues = {}
          @queues[DEFAULT_QUEUE_NAME] = { latency: DEFAULT_LATENCY_TIMEOUT, queue_size: DEFAULT_QUEUES_SIZE }
        end

        def latency=(value)
          default_queue[:latency] = value
        end

        def latency
          default_queue[:latency]
        end

        def queue_size=(value)
          default_queue[:queue_size] = value
        end

        def queue_size
          default_queue[:queue_size]
        end

        def default_queue
          queues[DEFAULT_QUEUE_NAME]
        end

        def add_queue_configuration(queue_name, latency: DEFAULT_LATENCY_TIMEOUT, queue_size: DEFAULT_QUEUES_SIZE)
          raise SidekiqException.new('Queue name is mandatory') if queue_name.blank?

          queues[queue_name] = { latency: latency, queue_size: queue_size }
        end
      end

      def check!
        check_workers!
        check_processes!
        check_latency!
        check_queue_size!
        check_redis!
      rescue Exception => e
        raise SidekiqException.new(e)
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
        configuration.queues.each do |queue, config|
          latency = queue(queue).latency

          raise "queue '#{queue}': latency #{latency} is greater than #{config[:latency]}" if latency > config[:latency]
        end
      end

      def check_queue_size!
        configuration.queues.each do |queue, config|
          size = queue(queue).size
          raise "queue '#{queue}': size #{size} is greater than #{config[:queue_size]}" if size > config[:queue_size]
        end
      end

      def check_redis!
        if ::Sidekiq.respond_to?(:redis_info)
          ::Sidekiq.redis_info
        else
          ::Sidekiq.redis(&:info)
        end
      end

      def queue(queue_name)
        @queue ||= {}
        @queue[queue_name] ||= ::Sidekiq::Queue.new(queue_name)
      end
    end
  end
end
