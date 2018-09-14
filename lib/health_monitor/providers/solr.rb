require 'health_monitor/providers/base'

module HealthMonitor
  module Providers
    class SolrException < StandardError; end

    class Solr < Base
      class Configuration
        DEFAULT_SOLR_URL = "http://localhost:8983/solr/collection1"

        attr_accessor :solr_url, :ping_url

        def initialize
          @solr_url = DEFAULT_SOLR_URL
          @ping_url = nil
        end

        def ping_url
          @ping_url ||= self.solr_url + '/admin/ping?wt=json'
        end
      end

      def check!
        # Check connection to the DB:
        response = open(configuration.ping_url)
        if response.try(:status).try(:first) == "200"
          json = JSON.parse(response.read)
          if json["status"] == "OK"
            json
          else
            raise SolrException.new("Solr Ping Failed #{configuration.ping_url} response was #{json}")
          end
        else
          raise SolrException.new("Could Not Ping Solr URL #{configuration.ping_url} status was #{response.status}")
        end
      rescue Exception => e
        raise SolrException.new(e.message)
      end

      private
      class << self
        private

        def configuration_class
          ::HealthMonitor::Providers::Solr::Configuration
        end
      end

    end
  end
end
