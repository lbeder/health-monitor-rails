# frozen_string_literal: true

require 'spec_helper'

describe HealthMonitor::Providers::Solr do
  subject { described_class.new }

  context 'with defaults' do
    it { expect(subject.configuration.name).to eq('Solr') }
    it { expect(subject.configuration.url).to eq(HealthMonitor::Providers::Solr::Configuration::DEFAULT_URL) }
  end

  describe '#name' do
    it { expect(subject.name).to eq('Solr') }
  end

  describe '#check!' do
    let(:solr_url_config) { 'http://www.example-solr.com:8983' }

    before do
      subject.request = test_request
      subject.configure do |config|
        config.url = solr_url_config
      end
      Providers.stub_solr
    end

    context 'with a standard connection' do
      it 'checks against the configured solr url' do
        subject.check!
        expect(Providers.stub_solr).to have_been_requested
      end

      it 'succesfully checks' do
        expect {
          subject.check!
        }.not_to raise_error
      end

      context 'when failing' do
        before do
          Providers.stub_solr_failure
        end

        it 'fails check!' do
          expect {
            subject.check!
          }.to raise_error(HealthMonitor::Providers::SolrException)
        end

        it 'checks against the configured solr url' do
          expect {
            subject.check!
          }.to raise_error(HealthMonitor::Providers::SolrException)
          expect(Providers.stub_solr_failure).to have_been_requested
        end
      end
    end

    context 'with a configured url that includes a path' do
      let(:solr_url_config) { 'http://www.example-solr.com:8983/solr/blacklight-core-development' }

      it 'checks against the configured solr url' do
        subject.check!
        expect(Providers.stub_solr).to have_been_requested
      end
    end

    context 'with a connection with authentication' do
      let(:solr_url_config) { 'http://solr:SolrRocks@localhost:8888' }

      before { Providers.stub_solr_with_auth }

      it 'checks against the configured solr url' do
        subject.check!
        expect(Providers.stub_solr_with_auth).to have_been_requested
      end

      it 'succesfully checks' do
        expect {
          subject.check!
        }.not_to raise_error
      end

      context 'when failing' do
        before do
          Providers.stub_solr_failure_with_auth
        end

        it 'fails check!' do
          expect {
            subject.check!
          }.to raise_error(HealthMonitor::Providers::SolrException)
        end

        it 'checks against the configured solr url' do
          expect {
            subject.check!
          }.to raise_error(HealthMonitor::Providers::SolrException)
          expect(Providers.stub_solr_failure_with_auth).to have_been_requested
        end
      end
    end
  end

  describe '#configure' do
    before do
      subject.configure
    end

    let(:url) { 'solr://user:password@fake.solr.com:8983/' }

    it 'url can be configured' do
      expect {
        subject.configure do |config|
          config.url = url
        end
      }.to change { subject.configuration.url }.to(url)
    end
  end
end
