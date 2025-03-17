# frozen_string_literal: true

require 'health_monitor/providers/base'

module HealthMonitor
  module Providers
    class DatabaseException < StandardError; end

    class Database < Base
      class Configuration < Base::Configuration
        DEFAULT_CONFIG_NAME = nil

        attr_reader :config_name

        def initialize(provider)
          super

          @config_name = DEFAULT_CONFIG_NAME
        end

        def config_name=(value)
          @config_name = value.presence&.to_s
        end
      end

      def check!
        checked = false
        failed_databases = []

        ActiveRecord::Base.connection_handler.connection_pool_list(:all).each do |cp|
          next unless check_connection_pool?(cp)

          checked = true
          check_connection(cp)
        rescue Exception
          failed_databases << cp.db_config.name
        end

        raise "unable to connect to: #{failed_databases.uniq.join(',')}" unless failed_databases.empty?
        raise "no connections checked with name: #{configuration.config_name}" if configuration.config_name && !checked
      rescue Exception => e
        raise DatabaseException.new(e.message)
      end

      private

      def configuration_class
        ::HealthMonitor::Providers::Database::Configuration
      end

      def check_connection_pool?(connection_pool)
        configuration.config_name.nil? || configuration.config_name == connection_pool.db_config.name
      end

      def check_connection(connection_pool)
        if connection_pool.respond_to?(:lease_connection)
          connection_pool.lease_connection.execute('SELECT 1')
        else
          connection_pool.connection.execute('SELECT 1')
        end
      end
    end
  end
end
