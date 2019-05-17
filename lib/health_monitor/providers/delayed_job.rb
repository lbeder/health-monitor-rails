# frozen_string_literal: true

require 'health_monitor/providers/base'
require 'delayed_job'

module HealthMonitor
  module Providers
    class DelayedJobException < StandardError; end

    class DelayedJob < Base
      class Configuration
        DEFAULT_QUEUES_SIZE = 100

        attr_accessor :queue_size

        def initialize
          @queue_size = DEFAULT_QUEUES_SIZE
        end
      end

      def check!
        check_queue_size!
      rescue Exception => e
        raise DelayedJobException.new(e.message)
      end

      private

      class << self
        private

        def configuration_class
          ::HealthMonitor::Providers::DelayedJob::Configuration
        end
      end

      def check_queue_size!
        size = job_class.count

        return unless size > configuration.queue_size

        raise "queue size #{size} is greater than #{configuration.queue_size}"
      end

      def job_class
        @job_class ||= ::Delayed::Job
      end
    end
  end
end
