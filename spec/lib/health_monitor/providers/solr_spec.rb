require 'spec_helper'

describe HealthMonitor::Providers::Solr do
  describe HealthMonitor::Providers::Solr::Configuration do
    describe 'defaults' do
      it { expect(described_class.new.solr_url).to eq(HealthMonitor::Providers::Solr::Configuration::DEFAULT_SOLR_URL) }
      it { expect(described_class.new.ping_url).to eq(HealthMonitor::Providers::Solr::Configuration::DEFAULT_SOLR_URL + '/admin/ping?wt=json') }
    end
  end

  subject { described_class.new(request: test_request) }

  describe '#provider_name' do
    it { expect(described_class.provider_name).to eq('Solr') }
  end

  describe '#check!' do
    before do
      described_class.configure
      Providers.stub_solr
    end

    it 'successfully checks' do
      expect {
        subject.check!
      }.not_to raise_error
    end

    context 'failing' do
      before do
        Providers.stub_solr_failure
      end

      it 'fails check!' do
        expect {
          subject.check!
        }.to raise_error(HealthMonitor::Providers::SolrException)
      end
    end
  end

  describe '#configurable?' do
    it { expect(described_class).to be_configurable}
  end

  describe '#configure' do
    described_class.configure
  end

  let(:solr_url) { "http://localhost:8984" }

  it 'solr_url can be configured' do
    expect {
      described_class.configure do |config|
        config.solr_url = solr_url
      end
    }.to change { described_class.new.configuration.solr_url }.to(solr_url)
  end
end
