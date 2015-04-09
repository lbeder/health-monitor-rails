module HealthMonitor
  module Providers
    class Base
      attr_reader :request
      cattr_accessor :configuration

      def self.configure
        return unless configurable?

        self.configuration ||= configuration_class.new

        yield self.configuration if block_given?
      end

      def initialize(request: nil)
        @request = request

        self.class.configure
      end

      # @abstract
      def check!
        raise NotImplementedError
      end

      private

      def self.configurable?
        configuration_class
      end

      # @abstract
      def self.configuration_class
      end
    end
  end
end
