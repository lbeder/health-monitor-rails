require 'health_monitor/providers/base'

module HealthMonitor
  module Providers
    class DatabaseException < StandardError; end

    class Database < Base
      def check!
        # Check connection to the DB:
        ActiveRecord::Migrator.current_version
      rescue Exception => e
        raise DatabaseException.new(e.message)
      end
    end
  end
end
