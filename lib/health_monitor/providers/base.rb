module HealthMonitor
  module Providers
    class Base
      attr_reader :request
      attr_accessor :configuration

      def provider_name
        @name ||= self.class.name.demodulize
      end

      def configure
        return unless configurable?

        @configuration = configuration_class.new

        yield configuration if block_given?
      end

      def initialize(request: nil)
        @request = request

        configure
      end

      # @abstract
      def check!
        raise NotImplementedError
      end

      def configurable?
        configuration_class
      end

      # @abstract
      def configuration_class; end
    end
  end
end
