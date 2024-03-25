# frozen_string_literal: true

require 'health_monitor/providers/base'

module HealthMonitor
  module Providers
    class DatabaseException < StandardError; end

    class Database < Base
      def check!
        failed_databases = []

        ActiveRecord::Base.connection_handler.connection_pool_list(:all).each do |cp|
          cp.connection.execute('SELECT 1')
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
