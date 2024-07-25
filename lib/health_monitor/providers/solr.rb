# frozen_string_literal: true

require 'health_monitor/providers/base'

module HealthMonitor
  module Providers
    class SolrException < StandardError; end

    class Solr < Base
      class Configuration < Base::Configuration
        DEFAULT_URL = nil
        attr_accessor :url

        def initialize(provider)
          super(provider)

          @url = DEFAULT_URL
        end
      end

      def check!
        check_solr_connection!
      rescue Exception => e
        raise SolrException.new(e.message)
      end

      private

      def configuration_class
        ::HealthMonitor::Providers::Solr::Configuration
      end

      def check_solr_connection!
        json = JSON.parse(solr_response.body)
        raise "The solr has an invalid status #{status_uri}" if json['responseHeader']['status'] != 0
      end

      def status_uri
        @status_uri ||= begin
          uri = URI(configuration.url)
          uri.path = '/solr/admin/cores'
          uri.query = 'action=STATUS'
          uri
        end
      end

      def solr_request
        @solr_request ||= begin
          req = Net::HTTP::Get.new(status_uri)
          req.basic_auth(status_uri.user, status_uri.password) if status_uri.user && status_uri.password
          req
        end
      end

      def solr_response
        Net::HTTP.start(status_uri.hostname, status_uri.port) { |http| http.request(solr_request) }
      end
    end
  end
end
