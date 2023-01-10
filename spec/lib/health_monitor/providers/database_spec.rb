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

    context 'when failing' do
      before do
        Providers.stub_database_failure
      end

      it 'fails check!' do
        expect {
          subject.check!
        }.to raise_error(HealthMonitor::Providers::DatabaseException, 'unable to connect to: database1,database2')
      end
    end

    context 'with multiple databases' do
      let(:database1) { :database1 }
      let(:database2) { :database2 }

      it 'succesfully checks' do
        expect {
          subject.check!
        }.not_to raise_error
      end
    end

    context 'with the first database failing' do
      before do
        Providers.stub_database_failure(:database1)
      end

      it 'fails check!' do
        expect {
          subject.check!
        }.to raise_error(HealthMonitor::Providers::DatabaseException, 'unable to connect to: database1')
      end
    end

    context 'with the second database failing' do
      before do
        Providers.stub_database_failure(:database2)
      end

      it 'fails check!' do
        expect {
          subject.check!
        }.to raise_error(HealthMonitor::Providers::DatabaseException, 'unable to connect to: database2')
      end
    end
  end

  describe '#configurable?' do
    it { expect(described_class).not_to be_configurable }
  end
end
