require 'health_monitor/providers/base'
require 'dalli'

module HealthMonitor
  module Providers
    class MemcachedException < StandardError; end

    class Memcached < Base
      class Configuration

        attr_accessor :db_host

        def initialize
          @db_host = ''
        end
      end

      class << self
        private

        def configuration_class
          ::HealthMonitor::Providers::Memcached::Configuration
        end
      end

      def check!
        dc = configuration.present? ? ::Dalli::Client.new(configuration.db_host) : ::Dalli::Client.new
        dc.set('check', 123)
        return if dc.get('check')
      rescue Exception => e
        raise MemcachedException.new(e.message)
      end

    end
  end
end
