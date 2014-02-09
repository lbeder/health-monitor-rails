module HealthMonitor
  module Providers
    class DBException < StandardError; end

    class Database
      def check!
        # Check connection to the DB:
        query = "SELECT max(version, '0') FROM schema_migrations"
        ActiveRecord::Base.connection.select_value(query).to_i
      rescue => e
        raise DBException.new(e.message)
      end
    end
  end
end
