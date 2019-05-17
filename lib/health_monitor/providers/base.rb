# frozen_string_literal: true

module HealthMonitor
  module Providers
    class Base
      attr_reader :request
      attr_accessor :configuration

      def self.provider_name
        @provider_name ||= name.demodulize
      end

      def self.configure
        return unless configurable?

        @global_configuration = configuration_class.new

        yield @global_configuration if block_given?
      end

      def initialize(request: nil)
        @request = request

        return unless self.class.configurable?

        self.configuration = self.class.instance_variable_get('@global_configuration')
      end

      # @abstract
      def check!
        raise NotImplementedError
      end

      def self.configurable?
        configuration_class
      end

      # @abstract
      def self.configuration_class; end
    end
  end
end
