# frozen_string_literal: true

require 'spec_helper'

describe HealthMonitor::Providers::Base do
  let(:request) { test_request }

  subject { described_class.new(request: request) }

  describe '#initialize' do
    it 'sets the request' do
      expect(described_class.new(request: request).request).to eq(request)
    end
  end

  describe '#provider_name' do
    it { expect(described_class.provider_name).to eq('Base') }
  end

  describe '#check!' do
    it 'abstract' do
      expect {
        subject.check!
      }.to raise_error(NotImplementedError)
    end
  end

  describe '#configurable?' do
    it { expect(described_class).not_to be_configurable }
  end

  describe '#configuration_class' do
    it 'abstract' do
      expect(described_class.send(:configuration_class)).to be_nil
    end
  end
end
