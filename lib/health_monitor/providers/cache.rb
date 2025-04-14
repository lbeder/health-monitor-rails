# frozen_string_literal: true

require 'health_monitor/providers/base'

module HealthMonitor
  module Providers
    class CacheException < StandardError; end

    class Cache < Base
      EXPIRED_TIME_SECONDS = 3

      def check!
        time = Time.now.to_formatted_s(:rfc2822)

        Rails.cache.write(key, time, expires_in: EXPIRED_TIME_SECONDS)
        fetched = Rails.cache.read(key)

        raise "different values (now: #{time}, fetched: #{fetched})" if fetched != time
      rescue Exception => e
        raise CacheException.new(e.message)
      end

      private

      def key
        @key ||= ['health', request.try(:remote_ip)].join(':')
      end
    end
  end
end
