# frozen_string_literal: true

require 'spec_helper'

describe HealthMonitor::Providers::Database do
  subject { described_class.new(request: test_request) }

  describe '#provider_name' do
    it { expect(described_class.provider_name).to eq('Database') }
  end

  describe '#check!' do
    it 'succesfully checks' do
      expect {
        subject.check!
      }.not_to raise_error
    end

    context 'failing' do
      before do
        Providers.stub_database_failure
      end

      it 'fails check!' do
        expect {
          subject.check!
        }.to raise_error(HealthMonitor::Providers::DatabaseException)
      end
    end
  end

  describe '#configurable?' do
    it { expect(described_class).not_to be_configurable }
  end
end
