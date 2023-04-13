# frozen_string_literal: true
require 'forwardable'

module HealthMonitor
  module Providers
    class Base
      extend Forwardable

      class Configuration
        attr_accessor :name
        attr_accessor :critical

        def initialize(provider)
          @name = provider.class.name.demodulize
          @critical = true
        end
      end

      attr_reader :request
      attr_reader :configuration

      def_delegators :@configuration, :name, :critical

      def initialize
        @configuration = configuration_class.new(self)
      end

      def configure
        yield @configuration if block_given?
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
