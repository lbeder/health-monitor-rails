# frozen_string_literal: true

require 'health_monitor/providers/base'

module HealthMonitor
  module Providers
    class SolrException < StandardError; end

    class Solr < Base
      class Configuration < Base::Configuration
        DEFAULT_URL = nil
        DEFAULT_COLLECTION = nil
        attr_accessor :url, :collection

        def initialize(provider)
          super

          @url = DEFAULT_URL
          @collection = DEFAULT_COLLECTION
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
        if configuration.collection
          check_solr_collection!
        else
          check_solr_uri!
        end
      end

      def check_solr_collection!
        response = solr_response(uri: collection_uri)
        json = JSON.parse(response.body) if response.code == '200'
        return if response.is_a?(Net::HTTPSuccess) && json['status'].casecmp?('OK')

        raise "The Solr collection has an invalid status #{collection_uri}"
      end

      def check_solr_uri!
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

      def collection_uri
        @collection_uri ||= begin
          uri = URI(configuration.url)
          uri.path = "/solr/#{configuration.collection}/admin/ping"
          uri
        end
      end

      def solr_request(uri: status_uri)
        @solr_request ||= begin
          req = Net::HTTP::Get.new(uri)
          req.basic_auth(uri.user, uri.password) if uri.user && uri.password
          req
        end
      end

      def solr_response(uri: status_uri)
        Net::HTTP.start(status_uri.hostname, status_uri.port) { |http| http.request(solr_request(uri: uri)) }
      end
    end
  end
end
