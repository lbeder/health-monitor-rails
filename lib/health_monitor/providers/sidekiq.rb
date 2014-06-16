require 'sidekiq/api'

module HealthMonitor
  module Providers
    class SidekiqException < StandardError; end

    class Sidekiq
      def check!
        check_workers!
        check_redis!
      rescue Exception => e
        raise SidekiqException.new(e.message)
      end

      private
      def check_workers!
        ::Sidekiq::Workers.new.size
      end

      def check_redis!
        ::Sidekiq.redis { |conn| conn.info }
      end
    end
  end
end
