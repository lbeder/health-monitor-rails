module HealthMonitor
  module Providers
    class Base
      attr_reader :request

      def self.provider_name
        @name ||= name.demodulize
      end

      def self.configure
        return unless configurable?

        @configuration = configuration_class.new

        yield @configuration if block_given?
      end

      def initialize(request: nil)
        @request = request

        self.class.configure
      end

      def configuration
        self.class.instance_variable_get('@configuration')
      end

      # @abstract
      def check!
        raise NotImplementedError
      end

      def self.configurable?
        configuration_class
      end

      # @abstract
      def self.configuration_class
      end
    end
  end
end
