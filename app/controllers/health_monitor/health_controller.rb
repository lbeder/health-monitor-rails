module HealthMonitor
  class HealthController < ActionController::Metal
     # GET /health/check
    def check
      HealthMonitor.check!

      self.status = :ok
      self.response_body = "Health check has passed: #{Time.now.to_s(:db)}\n"
    rescue Exception => e
      self.status = :service_unavailable
      self.response_body = "Health check has failed: #{Time.now.to_s(:db)}, error: #{e.message}\n"
    end

    private
    def process_with_silence(*args)
      Rails.logger.quietly do
        process_without_silence(*args)
      end
    end

    alias_method_chain :process, :silence
  end
end
