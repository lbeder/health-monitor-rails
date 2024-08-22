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

    context 'with a specified collection' do
      let(:solr_collection_config) { 'example-collection' }

      before do
        subject.request = test_request
        subject.configure do |config|
          config.url = solr_url_config
          config.collection = solr_collection_config
        end
        Providers.stub_solr_collection(solr_collection_config)
      end

      context 'with a standard connection' do
        it 'checks against the configured solr url' do
          subject.check!
          expect(Providers.stub_solr_collection(solr_collection_config)).to have_been_requested
        end

        it 'succesfully checks' do
          expect {
            subject.check!
          }.not_to raise_error
        end

        context 'when failing' do
          let(:solr_failure) { Providers.stub_solr_collection(solr_collection_config, body: '', status: 404) }

          before do
            solr_failure
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
            expect(solr_failure).to have_been_requested
          end
        end
      end

      context 'with a configured url that includes a path' do
        let(:solr_url_config) { 'http://www.example-solr.com:8983/solr/blacklight-core-development' }

        it 'checks against the configured solr url' do
          subject.check!
          expect(Providers.stub_solr_collection(solr_collection_config)).to have_been_requested
        end
      end

      context 'with a connection with authentication' do
        let(:solr_url_config) { 'http://solr:SolrRocks@localhost:8888' }

        before { Providers.stub_solr_collection_with_auth(solr_collection_config) }

        it 'checks against the configured solr url' do
          subject.check!
          expect(Providers.stub_solr_collection_with_auth(solr_collection_config)).to have_been_requested
        end

        it 'succesfully checks' do
          expect {
            subject.check!
          }.not_to raise_error
        end

        context 'when failing' do
          let(:provider_failure) { Providers.stub_solr_collection_with_auth(solr_collection_config, status: 404, body: '') }

          before do
            provider_failure
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
            expect(provider_failure).to have_been_requested
          end
        end
      end
    end
  end

  describe '#configure' do
    before do
      subject.configure
    end

    let(:url) { 'solr://user:password@fake.solr.com:8983/' }
    let(:collection) { 'my-collection' }

    it 'url can be configured' do
      expect {
        subject.configure do |config|
          config.url = url
        end
      }.to change { subject.configuration.url }.to(url)
    end

    it 'collection can be configured' do
      expect {
        subject.configure do |config|
          config.collection = collection
        end
      }.to change { subject.configuration.collection }.to(collection)
    end

    it 'url and collection can be configured' do
      expect {
        subject.configure do |config|
          config.url = url
          config.collection = collection
        end
      }.to change { subject.configuration.collection }.to(collection)
       .and change { subject.configuration.url }.to(url)
    end
  end
end
