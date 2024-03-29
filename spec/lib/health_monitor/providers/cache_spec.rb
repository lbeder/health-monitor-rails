# frozen_string_literal: true

require 'spec_helper'

describe HealthMonitor::Providers::Cache do
  subject { described_class.new }

  describe '#name' do
    it { expect(subject.name).to eq('Cache') }
  end

  describe '#check!' do
    subject { described_class.new }

    before { subject.request = test_request }

    it 'succesfully checks' do
      expect {
        subject
      }.not_to raise_error
    end

    context 'when failing' do
      before do
        Providers.stub_cache_failure
      end

      it 'fails check!' do
        expect {
          subject.check!
        }.to raise_error(HealthMonitor::Providers::CacheException)
      end
    end
  end

  describe '#key' do
    before do
      subject.request = test_request
    end

    it { expect(subject.send(:key)).to eq('health:0.0.0.0') }
  end
end
