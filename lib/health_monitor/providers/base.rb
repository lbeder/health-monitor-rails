# frozen_string_literal: true

module HealthMonitor
  module Providers
    class Base
      class Configuration
        attr_accessor :name

        def initialize(provider)
          @name = provider.class.name.demodulize
        end
      end

      attr_reader :request
      attr_reader :configuration

      def initialize
        @configuration = configuration_class.new(self)
      end

      def configure
        yield @configuration if block_given?
      end

      def name
        @configuration.name
      end

      def request=(request)
        @request ||= request
      end

      # @abstract
      def check!
        raise NotImplementedError
      end

      private

      def configuration_class
        Configuration
      end
    end
  end
end
