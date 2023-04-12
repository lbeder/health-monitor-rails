# frozen_string_literal: true

require 'spec_helper'

describe HealthMonitor::Providers::Base do
  subject { described_class.new }

  describe '#initialize' do
    it 'sets the configuration' do
      expect(subject.configuration).to be_a(HealthMonitor::Providers::Base::Configuration)
    end
  end

  describe '#name' do
    it { expect(subject.name).to eq('Base') }
  end

  describe '#check!' do
    it 'abstract' do
      expect {
        subject.check!
      }.to raise_error(NotImplementedError)
    end
  end

  describe '#configuration_class' do
    it 'abstract' do
      expect(subject.send(:configuration_class)).to be(HealthMonitor::Providers::Base::Configuration)
    end
  end
end
