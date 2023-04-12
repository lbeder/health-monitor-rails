# frozen_string_literal: true

require 'spec_helper'

describe HealthMonitor::Providers::Resque do
  subject { described_class.new }

  describe '#name' do
    it { expect(subject.name).to eq('Resque') }
  end

  describe '#check!' do
    before { subject.request = test_request }

    it 'succesfully checks' do
      expect {
        subject.check!
      }.not_to raise_error
    end

    context 'when failing' do
      before do
        Providers.stub_resque_failure
      end

      it 'fails check!' do
        expect {
          subject.check!
        }.to raise_error(HealthMonitor::Providers::ResqueException)
      end
    end
  end
end
