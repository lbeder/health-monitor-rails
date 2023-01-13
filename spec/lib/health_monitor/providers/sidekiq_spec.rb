# frozen_string_literal: true

require 'spec_helper'

describe HealthMonitor::Providers::Sidekiq do
  subject { described_class.new(request: test_request) }

  let(:default_latency) { HealthMonitor::Providers::Sidekiq::Configuration::DEFAULT_LATENCY_TIMEOUT }
  let(:default_queue_size) { HealthMonitor::Providers::Sidekiq::Configuration::DEFAULT_QUEUES_SIZE }
  let(:default_queue_name) { HealthMonitor::Providers::Sidekiq::Configuration::DEFAULT_QUEUE_NAME }
  let(:default_retry_check) { HealthMonitor::Providers::Sidekiq::Configuration::DEFAULT_RETRY_CHECK }

  describe HealthMonitor::Providers::Sidekiq::Configuration do
    describe 'defaults' do
      it { expect(described_class.new.latency).to eq(default_latency) }
      it { expect(described_class.new.queue_size).to eq(default_queue_size) }

      it do
        expect(described_class.new.queues[default_queue_name]).to eq(
          latency: default_latency,
          queue_size: default_queue_size
        )
      end
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

    context 'when failing' do
      context 'with workers' do
        before do
          Providers.stub_sidekiq_workers_failure
        end

        it 'fails check!' do
          expect {
            subject.check!
          }.to raise_error(HealthMonitor::Providers::SidekiqException)
        end
      end

      context 'with processes' do
        before do
          Providers.stub_sidekiq_no_processes_failure
        end

        it 'fails check!' do
          expect {
            subject.check!
          }.to raise_error(HealthMonitor::Providers::SidekiqException)
        end
      end

      context 'with latency' do
        before do
          Providers.stub_sidekiq_latency_failure(queue)
        end

        context 'when fails' do
          let(:queue) { 'default' }

          it 'fails check!' do
            expect {
              subject.check!
            }.to raise_error(HealthMonitor::Providers::SidekiqException)
          end
        end

        context 'with a different queue' do
          let(:queue) { 'queue' }

          it 'successfully checks' do
            expect {
              subject.check!
            }.not_to raise_error
          end
        end
      end

      context 'with queue_size' do
        before do
          Providers.stub_sidekiq_queue_size_failure
        end

        it 'fails check!' do
          expect {
            subject.check!
          }.to raise_error(HealthMonitor::Providers::SidekiqException)
        end
      end

      context 'with redis' do
        before do
          Providers.stub_sidekiq_redis_failure
        end

        it 'fails check!' do
          expect {
            subject.check!
          }.to raise_error(HealthMonitor::Providers::SidekiqException)
        end
      end

      context 'with retries over limit' do
        before do
          Providers.stub_sidekiq_over_retry_limit_failure
        end

        it 'fails check!' do
          expect {
            subject.check!
          }.to raise_error(HealthMonitor::Providers::SidekiqException, "amount of retries for a job is greater than 20")
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

    it 'latency and queue_size can be configured' do
      expect {
        described_class.configure do |config|
          config.latency = latency
          config.queue_size = queue_size
        end
      }.to change { described_class.new.configuration.latency }.to(latency).and \
        change { described_class.new.configuration.queues[default_queue_name] }.to(
          latency: latency,
          queue_size: queue_size
        )
    end
  end
end
