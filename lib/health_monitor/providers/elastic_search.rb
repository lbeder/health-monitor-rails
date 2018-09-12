require 'health_monitor/providers/base'

module HealthMonitor
  module Providers
    class ElasticSearchException < StandardError; end

    class ElasticSearch < Base
      class Configuration
        DEFAULT_ELASTIC_SEARCH_URL = "http://localhost:9200"

        attr_accessor :elastic_search_url, :ping_url

        def initialize
          @elastic_search_url = DEFAULT_ELASTIC_SEARCH_URL
          @ping_url = nil
        end

        def ping_url
          @ping_url ||= self.elastic_search_url + '/_cluster/health'
        end
      end

      def check!
        # Check connection to the DB:
        response = open(configuration.ping_url)
        if response.try(:status).try(:first) == "200"
          json = JSON.parse(response.read)
          if json["status"] == "green"
            json
          else
            raise ElasticSearchException.new("ElasticSearch Ping Failed #{self.ping_url} response was #{json}")
          end
        else
          raise ElasticSearchException.new("Could Not Ping ElasticSearch URL #{self.ping_url} status was #{response.status}")
        end
      rescue Exception => e
        raise ElasticSearchException.new(e.message)
      end

      private
      class << self
        private

        def configuration_class
          ::HealthMonitor::Providers::ElasticSearch::Configuration
        end
      end

    end
  end
end
