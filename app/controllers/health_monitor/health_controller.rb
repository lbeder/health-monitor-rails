class HealthController < ActionController::Base
  layout nil

   # GET /health/check
  def check
    HealthMonitor.check!

    render text: "Healh check has passed: #{Time.now.to_s(:db)}\n"
  rescue Exception => e
    render text: "Healh check has failed: #{Time.now.to_s(:db)}, error: #{e.message}\n",
      :status => :service_unavailable
  end

  private
  def process_with_silence(*args)
    logger.quietly do
      process_without_silence(*args)
    end
  end

  alias_method_chain :process, :silence
end
