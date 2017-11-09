require 'health_monitor/providers/base'
require 'mongo'
Mongo::Logger.logger.level = ::Logger::DEBUG

module HealthMonitor
  module Providers
    class MongoidException < StandardError; end

    class Mongoid < Base
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
          ::HealthMonitor::Providers::Mongoid::Configuration
        end
      end

      def check!
        begin
          client = ::Mongo::Client.new([configuration.params.host], :database => configuration.params.name)
          return if client.cluster.servers.first.connectable?
          client.close
        rescue
          raise MongoidException.new("Could not connect to mongo") and return
        end
      end
    end
  end
end
