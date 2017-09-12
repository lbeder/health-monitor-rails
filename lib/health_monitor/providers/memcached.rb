require 'health_monitor/providers/base'

module HealthMonitor
  module Providers
    class MemcachedException < StandardError; end

    class Memcached < Base
      def check!
        return unless ActiveSupport::Cache.lookup_store(:mem_cache_store).stats.values.include? nil

        raise 'Memcached is not running'
      rescue Exception => e
        raise MemcachedException.new(e.message)
      end

    end
  end
end
