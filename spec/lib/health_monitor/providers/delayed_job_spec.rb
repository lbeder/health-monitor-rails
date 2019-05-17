# frozen_string_literal: true

require 'spec_helper'

describe HealthMonitor::Providers::DelayedJob do
  describe HealthMonitor::Providers::DelayedJob::Configuration do
    describe 'defaults' do
      it { expect(described_class.new.queue_size).to eq(HealthMonitor::Providers::DelayedJob::Configuration::DEFAULT_QUEUES_SIZE) }
    end
  end

  subject { described_class.new(request: test_request) }

  describe '#provider_name' do
    it { expect(described_class.provider_name).to eq('DelayedJob') }
  end

  describe '#check!' do
    before do
      described_class.configure
      Providers.stub_delayed_job
    end

    it 'succesfully checks' do
      expect {
        subject.check!
      }.not_to raise_error
    end

    context 'failing' do
      context 'queue_size' do
        before do
          Providers.stub_delayed_job_queue_size_failure
        end

        it 'fails check!' do
          expect {
            subject.check!
          }.to raise_error(HealthMonitor::Providers::DelayedJobException)
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

    let(:queue_size) { 123 }

    it 'queue size can be configured' do
      expect {
        described_class.configure do |config|
          config.queue_size = queue_size
        end
      }.to change { described_class.new.configuration.queue_size }.to(queue_size)
    end
  end
end
