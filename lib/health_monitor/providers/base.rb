module HealthMonitor
  module Providers
    class Base
      attr_reader :request

      def initialize(request: nil)
        @request = request
      end

      # @abstract
      def check!
        raise NotImplementedError
      end
    end
  end
end
