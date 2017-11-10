require 'spec_helper'

describe HealthMonitor::Providers::Mongoid do
  describe HealthMonitor::Providers::Mongoid::Configuration do
    describe 'defaults' do
      it { expect(described_class.new.params).to eq( {} ) }
    end
  end
  subject { described_class.new(request: test_request) }

  describe '#provider_name' do
    it { expect(described_class.provider_name).to eq('Mongoid') }
  end

  describe '#check!' do
    context 'failing' do
      before do
        Providers.stub_mongoid_failure
      end

      it 'fails check!' do
        expect {
          subject.check!
        }.to raise_error(HealthMonitor::Providers::MongoidException)
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

    let(:params) do
        {
          host: 'localhost:27017',
          name: 'check_db'
        }
    end

    it 'sets configuration parameters that are specified' do
      expect {
        described_class.configure do |config|
          config.params = params
        end
      }.to change { described_class.new.configuration.params }.to(params)
    end
  end
end
