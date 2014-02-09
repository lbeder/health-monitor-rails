module HealthMonitor
  module Providers
    class DatabaseException < StandardError; end

    class Database
      def check!
        # Check connection to the DB:
        query = 'SELECT version FROM schema_migrations'
        ActiveRecord::Base.connection.select_value(query).to_i
      rescue Exception => e
        raise DatabaseException.new(e.message)
      end
    end
  end
end
