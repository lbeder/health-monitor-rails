# frozen_string_literal: true

require 'spec_helper'

describe HealthMonitor::Providers::Sidekiq do
  let(:default_latency) { HealthMonitor::Providers::Sidekiq::Configuration::DEFAULT_LATENCY_TIMEOUT }
  let(:default_queue_size) { HealthMonitor::Providers::Sidekiq::Configuration::DEFAULT_QUEUES_SIZE }
  let(:default_queue_name) { HealthMonitor::Providers::Sidekiq::Configuration::DEFAULT_QUEUE_NAME }

  describe HealthMonitor::Providers::Sidekiq::Configuration do
    describe 'defaults' do
      it { expect(described_class.new.latency).to eq(default_latency) }
      it { expect(described_class.new.queue_size).to eq(default_queue_size) }
      it do
        expect(described_class.new.queues[default_queue_name]).to eq(latency: default_latency,
          queue_size: default_queue_size)
      end
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
    before do
      Providers.stub_sidekiq
    end

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

      context 'processes' do
        before do
          Providers.stub_sidekiq_no_processes_failure
        end

        it 'fails check!' do
          expect {
            subject.check!
          }.to raise_error(HealthMonitor::Providers::SidekiqException)
        end
      end

      context 'latency' do
        before do
          Providers.stub_sidekiq_latency_failure(queue)
        end

        context 'fails' do
          let(:queue) { 'default' }
          it 'fails check!' do
            expect {
              subject.check!
            }.to raise_error(HealthMonitor::Providers::SidekiqException)
          end
        end
        context 'on a different queue' do
          let(:queue) { 'critical' }
          it 'successfully checks' do
            expect {
              subject.check!
            }.not_to raise_error
          end
        end
      end

      context 'queue_size' do
        before do
          Providers.stub_sidekiq_queue_size_failure
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
    before do
      described_class.configure
    end

    let(:latency) { 123 }
    let(:queue_size) { 50 }

    it 'latency can be configured' do
      expect {
        described_class.configure do |config|
          config.latency = latency
        end
      }.to change { described_class.new.configuration.latency }.to(latency).and \
        change { described_class.new.configuration.queues[default_queue_name] }.to(
          latency: latency,
          queue_size: default_queue_size
        )
    end

    it 'queue_size can be configured' do
      expect {
        described_class.configure do |config|
          config.queue_size = queue_size
        end
      }.to change { described_class.new.configuration.queue_size }.to(queue_size).and \
        change { described_class.new.configuration.queues[default_queue_name] }.to(
          latency: default_latency,
          queue_size: queue_size
        )
    end
  end
end
