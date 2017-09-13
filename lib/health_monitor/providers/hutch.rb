require 'health_monitor/providers/base'

module HealthMonitor
  module Providers
    class HutchException < StandardError; end

    class Hutch < Base
      class Configuration
        DEFAULT_CONFIG = {}

        attr_accessor :params

        def initialize
          @params = DEFAULT_CONFIG
        end
      end

      class << self
        private

        def configuration_class
          ::HealthMonitor::Providers::Hutch::Configuration
        end
      end

      def check!
        ::Hutch::Config.initialize(configuration.params) if configuration.present?
        ::Hutch.connect
        return if ::Hutch.connected?
      rescue Exception => e
        raise HutchException.new(e.message)
      end
    end
  end
end
