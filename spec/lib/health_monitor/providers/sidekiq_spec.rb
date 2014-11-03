require 'spec_helper'
require 'health_monitor/providers/sidekiq'

describe HealthMonitor::Providers::Sidekiq do
  before do
    redis_conn = proc { Redis.new }

    Sidekiq.configure_client do |config|
      config.redis = ConnectionPool.new(&redis_conn)
    end

    Sidekiq.configure_server do |config|
      config.redis = ConnectionPool.new(&redis_conn)
    end
  end

  it 'should succesfully check!' do
    expect {
      subject.check!
    }.not_to raise_error
  end

  context 'failing' do
    context 'workers' do
      before do
        Providers.stub_sidekiq_workers_failure
      end

      it 'should fail check!' do
        expect {
          subject.check!
        }.to raise_error(HealthMonitor::Providers::SidekiqException)
      end
    end

    context 'redis' do
      before do
        Providers.stub_sidekiq_redis_failure
      end

      it 'should fail check!' do
        expect {
          subject.check!
        }.to raise_error(HealthMonitor::Providers::SidekiqException)
      end
    end
  end
end
