require 'spec_helper'

describe HealthMonitor::Providers::Memcached do
  describe HealthMonitor::Providers::Memcached::Configuration do
    describe 'defaults' do
      it { expect(described_class.new.db_host).to eq('') }
    end
  end
  subject { described_class.new(request: test_request) }

  describe '#provider_name' do
    it { expect(described_class.provider_name).to eq('Memcached') }
  end

  describe '#check!' do
    it 'succesfully checks' do
      expect {
        subject.check!
      }.not_to raise_error
    end

    context 'failing' do
      before do
        Providers.stub_memcached_failure
      end

      it 'fails check!' do
        expect {
          subject.check!
        }.to raise_error(HealthMonitor::Providers::MemcachedException)
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

    let(:db_host) { 'localhost:11211' }

    it 'sets configuration parameters that are specified' do
      expect {
        described_class.configure do |config|
          config.db_host = db_host
        end
      }.to change { described_class.new.configuration.db_host }.to(db_host)
    end
  end
end
