require 'resque'

module HealthMonitor
  module Providers
    class ResqueException < StandardError; end

    class Resque
      def check!
        ::Resque.info
      rescue Exception => e
        raise ResqueException.new(e.message)
      end
    end
  end
end
