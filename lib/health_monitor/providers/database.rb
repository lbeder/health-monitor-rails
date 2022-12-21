# frozen_string_literal: true

require 'health_monitor/providers/base'

module HealthMonitor
  module Providers
    class DatabaseException < StandardError; end

    class Database < Base
      class Configuration
        attr_accessor :databases

        def initialize
          @databases = [nil]
        end
      end

      def check!
        configuration.databases.each do |database|
          ActiveRecord::Base.establish_connection(database)
        end
      rescue Exception => e
        raise DatabaseException.new(e.message)
      end

      class << self
        private

        def configuration_class
          ::HealthMonitor::Providers::Database::Configuration
        end
      end
    end
  end
end
