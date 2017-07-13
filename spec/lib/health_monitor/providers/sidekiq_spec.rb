require 'spec_helper'

describe HealthMonitor::Providers::Sidekiq do
  describe HealthMonitor::Providers::Sidekiq::Configuration do
    describe 'defaults' do
      it { expect(described_class.new.latency).to eq(HealthMonitor::Providers::Sidekiq::Configuration::DEFAULT_LATENCY_TIMEOUT) }
    end
  end

  subject { described_class.new(request: test_request) }

  before do
    redis_conn = proc { Redis.new }

    Sidekiq.configure_client do |config|
      config.redis = ConnectionPool.new(&redis_conn)
    end

    Sidekiq.configure_server do |config|
      config.redis = ConnectionPool.new(&redis_conn)
    end
  end

  describe '#provider_name' do
    it { expect(described_class.provider_name).to eq('Sidekiq') }
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
      context 'sidekiq warns' do
        before do
          Providers.stub_sidekiq_latency_warning
          described_class.configure do |config|
            config.warning_latency = 10
          end
        end

        it 'succesfully checks with concern' do
          expect {
            subject.check!
          }.to raise_error(HealthMonitor::HealthWarning)
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
    before do
      described_class.configure
    end

    let(:latency) { 123 }

    it 'latency can be configured' do
      expect {
        described_class.configure do |config|
          config.latency = latency
        end
      }.to change { described_class.new.configuration.latency }.to(latency)
    end
    it 'error_latency can be configured' do
      expect {
        described_class.configure do |config|
          config.error_latency = latency
        end
      }.to change { described_class.new.configuration.error_latency }.to(latency)
    end
    it 'warning_latency can be configured' do
      expect {
        described_class.configure do |config|
          config.warning_latency = latency
        end
      }.to change { described_class.new.configuration.warning_latency }.to(latency)
    end
    it 'error_latency can be configured by configuring latency' do
      expect {
        described_class.configure do |config|
          config.latency = latency
        end
      }.to change { described_class.new.configuration.error_latency }.to(latency)
    end
  end
end
