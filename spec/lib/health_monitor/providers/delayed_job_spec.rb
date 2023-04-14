# frozen_string_literal: true

require 'spec_helper'

describe HealthMonitor::Providers::DelayedJob do
  subject { described_class.new }

  describe 'defaults' do
    it { expect(subject.configuration.name).to eq('DelayedJob') }
    it { expect(subject.configuration.queue_size).to eq(HealthMonitor::Providers::DelayedJob::Configuration::DEFAULT_QUEUES_SIZE) }
  end

  describe '#name' do
    it { expect(subject.name).to eq('DelayedJob') }
  end

  describe '#check!' do
    subject { described_class.new }

    before do
      subject.request = test_request
      Providers.stub_delayed_job
    end

    it 'succesfully checks' do
      expect {
        subject.check!
      }.not_to raise_error
    end

    context 'when failing' do
      context 'with queue_size' do
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

  describe '#configure' do
    let(:queue_size) { 123 }

    it 'queue size can be configured' do
      expect {
        subject.configure do |config|
          config.queue_size = queue_size
        end
      }.to change { subject.configuration.queue_size }.to(queue_size)
    end
  end
end
