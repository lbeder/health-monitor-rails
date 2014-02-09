module HealthMonitor
  module Providers
    class CacheException < StandardError; end

    class Cache
      def check!
        time = Time.now.to_s

        Rails.cache.write(:health, time)
        fetched = Rails.cache.read(:health)

        raise "different values (now: #{time}, fetched: #{fetched}" if fetched != time
      rescue Exception => e
        raise CacheException.new(e.message)
      end
    end
  end
end
