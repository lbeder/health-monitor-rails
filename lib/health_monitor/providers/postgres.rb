require 'health_monitor/providers/base'

module HealthMonitor
  module Providers
    class PostgresException < StandardError; end

    class Postgres < Base
      class Configuration
        DEFAULT_CONFIG = {}

        attr_accessor :params

        def initialize
          @params = DEFAULT_CONFIG
        end
      end

      class << self
        private

        def configuration_class
          ::HealthMonitor::Providers::Postgres::Configuration
        end
      end

      def check!
        begin
          con = PG.connect :dbname => configuration.params.database, :user => configuration.params.username
          return if con
        rescue PG::Error => e
          raise PostgresException.new(e.message) and return
        ensure
          con.close if con
        end
      end
    end
  end
end
