require 'sidekiq'

module HealthMonitor
  module Providers
    class SidekiqException < StandardError; end

    class Sidekiq
      def check!
        ::Sidekiq::Workers.new.size
      rescue Exception => e
        raise SidekiqException.new(e.message)
      end
    end
  end
end
