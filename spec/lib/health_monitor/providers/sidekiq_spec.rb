require 'spec_helper'

describe HealthMonitor::Providers::Sidekiq do
  describe HealthMonitor::Providers::Sidekiq::Configuration do
    describe 'defaults' do
      it { expect(described_class.new.latency).to eq(HealthMonitor::Providers::Sidekiq::Configuration::DEFAULT_LATENCY_TIMEOUT) }
    end
  end

  subject { described_class.new(request: ActionController::TestRequest.new) }

  before do
    redis_conn = proc { Redis.new }

    Sidekiq.configure_client do |config|
      config.redis = ConnectionPool.new(&redis_conn)
    end

    Sidekiq.configure_server do |config|
      config.redis = ConnectionPool.new(&redis_conn)
    end
  end

  describe '#check!' do
    it 'succesfully checks' do
      expect {
        subject.check!
      }.not_to raise_error
    end

    context 'failing' do
      context 'workers' do
        before do
          Providers.stub_sidekiq_workers_failure
        end

        it 'fails check!' do
          expect {
            subject.check!
          }.to raise_error(HealthMonitor::Providers::SidekiqException)
        end
      end

      context 'latency' do
        before do
          Providers.stub_sidekiq_latency_failure
        end

        it 'fails check!' do
          expect {
            subject.check!
          }.to raise_error(HealthMonitor::Providers::SidekiqException)
        end
      end

      context 'redis' do
        before do
          Providers.stub_sidekiq_redis_failure
        end

        it 'fails check!' do
          expect {
            subject.check!
          }.to raise_error(HealthMonitor::Providers::SidekiqException)
        end
      end
    end
  end

  describe '#configurable?' do
    it { expect(described_class).to be_configurable }
  end

  describe '#configure' do
    it 'latency can be configured' do
      latency = 123

      expect {
        described_class.configure do |config|
          config.latency = latency
        end
      }.to change { described_class.configuration.latency }.to(latency)
    end
  end
end
