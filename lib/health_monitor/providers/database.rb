# frozen_string_literal: true

require 'health_monitor/providers/base'

module HealthMonitor
  module Providers
    class DatabaseException < StandardError; end

    class Database < Base
      def check!
        failed_databases = []

        ActiveRecord::Base.connection_handler.all_connection_pools.each do |cp|
          cp.connection.check_version
        rescue Exception
          failed_databases << cp.db_config.name
        end

        raise "unable to connect to: #{failed_databases.uniq.join(',')}" unless failed_databases.empty?
      rescue Exception => e
        raise DatabaseException.new(e.message)
      end
    end
  end
end
