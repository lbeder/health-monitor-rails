require 'health_monitor/providers/base'

module HealthMonitor
  module Providers
    class MemcachedException < StandardError; end

    class Memcached < Base
      def check!
        return unless Rails.cache.stats.values.include? nil

        # raise 'Memcached is not running'
      rescue Exception => e
        raise MemcachedException.new(e.message)
      end

    end
  end
end
