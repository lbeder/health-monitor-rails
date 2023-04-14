# frozen_string_literal: true

require 'spec_helper'

describe HealthMonitor::Providers::Sidekiq do
  subject { described_class.new }

  let(:default_queue_name) { HealthMonitor::Providers::Sidekiq::Configuration::DEFAULT_QUEUE_NAME }

  context 'with defaults' do
    let(:default_latency) { HealthMonitor::Providers::Sidekiq::Configuration::DEFAULT_LATENCY_TIMEOUT }
    let(:default_queue_size) { HealthMonitor::Providers::Sidekiq::Configuration::DEFAULT_QUEUES_SIZE }

    it { expect(subject.configuration.name).to eq('Sidekiq') }
    it { expect(subject.configuration.latency).to eq(default_latency) }
    it { expect(subject.configuration.queue_size).to eq(default_queue_size) }

    it do
      expect(subject.configuration.queues[default_queue_name]).to eq(
        latency: default_latency,
        queue_size: default_queue_size
      )
    end
  end

  describe '#name' do
    it { expect(subject.name).to eq('Sidekiq') }
  end

  describe '#check!' do
    before do
      Providers.stub_sidekiq
      subject.request = test_request
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

        let(:default_retry_check) { HealthMonitor::Providers::Sidekiq::Configuration::DEFAULT_RETRY_CHECK }

        it 'fails check!' do
          expect {
            subject.check!
          }.to raise_error(
            HealthMonitor::Providers::SidekiqException,
            "amount of retries for a job is greater than #{default_retry_check}"
          )
        end
      end
    end
  end

  describe '#configure' do
    let(:latency) { 123 }
    let(:queue_size) { 50 }

    it 'latency and queue_size can be configured' do
      expect {
        subject.configure do |config|
          config.latency = latency
          config.queue_size = queue_size
        end
      }.to change { subject.configuration.latency }.to(latency).and \
        change { subject.configuration.queues[default_queue_name] }.to(
          latency: latency,
          queue_size: queue_size
        )
    end
  end
end
