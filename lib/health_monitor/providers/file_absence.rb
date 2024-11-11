# frozen_string_literal: true

require 'health_monitor/providers/base'

module HealthMonitor
  module Providers
    class FileAbsenceException < StandardError; end

    class FileAbsence < Base
      class Configuration < Base::Configuration
        DEFAULT_FILENAME = nil
        attr_accessor :filename

        def initialize(provider)
          super

          @filename = DEFAULT_FILENAME
        end
      end

      def check!
        return unless File.exist?(configuration.filename)

        raise FileAbsenceException.new("Unwanted file #{configuration.filename} exists!")
      end

      private

      def configuration_class
        ::HealthMonitor::Providers::FileAbsence::Configuration
      end
    end
  end
end
