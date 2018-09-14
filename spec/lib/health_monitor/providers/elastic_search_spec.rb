require 'spec_helper'

describe HealthMonitor::Providers::ElasticSearch do
  describe HealthMonitor::Providers::ElasticSearch::Configuration do
    describe 'defaults' do
      it { expect(described_class.new.elastic_search_url).to eq(HealthMonitor::Providers::ElasticSearch::Configuration::DEFAULT_ELASTIC_SEARCH_URL) }
      it { expect(described_class.new.ping_url).to eq(HealthMonitor::Providers::ElasticSearch::Configuration::DEFAULT_ELASTIC_SEARCH_URL + '/_cluster/health') }
    end
  end

  subject { described_class.new(request: test_request) }

  describe '#provider_name' do
    it { expect(described_class.provider_name).to eq('ElasticSearch') }
  end

  describe '#check!' do
    before do
      described_class.configure
      Providers.stub_elastic_search
    end

    it 'successfully checks' do
      expect {
        subject.check!
      }.not_to raise_error
    end

    context 'failing' do
      before do
        Providers.stub_elastic_search_failure
      end

      it 'fails check!' do
        expect {
          subject.check!
        }.to raise_error(HealthMonitor::Providers::ElasticSearchException)
      end
    end
  end

  describe '#configurable?' do
    it { expect(described_class).to be_configurable }
  end

  describe '#configure' do
    described_class.configure
  end

  let(:elastic_search_url) { "http://localhost:9100" }

  it 'elastic_search_url can be configured' do
    expect {
      described_class.configure do |config|
        config.elastic_search_url = elastic_search_url
      end
    }.to change { described_class.new.configuration.elastic_search_url }.to(elastic_search_url)
  end
end
