# frozen_string_literal: true

require 'spec_helper'

describe HealthMonitor::Providers::FileAbsence do
  subject { described_class.new }

  context 'with defaults' do
    it { expect(subject.configuration.name).to eq('FileAbsence') }
    it { expect(subject.configuration.filename).to eq(HealthMonitor::Providers::FileAbsence::Configuration::DEFAULT_FILENAME) }
  end

  describe '#name' do
    it { expect(subject.name).to eq('FileAbsence') }
  end

  describe '#check!' do
    let(:filename) { 'bad-file' }

    before do
      subject.request = test_request
      subject.configure do |config|
        config.filename = filename
      end
      allow(File).to receive('exist?').with(filename).and_return(false)
    end

    context 'with a standard connection' do
      it 'checks the file' do
        subject.check!
        expect(File).to have_received('exist?')
      end

      it 'succesfully checks' do
        expect {
          subject.check!
        }.not_to raise_error
      end

      context 'when failing' do
        before do
          allow(File).to receive('exist?').with(filename).and_return(true)
        end

        it 'fails check!' do
          expect {
            subject.check!
          }.to raise_error(HealthMonitor::Providers::FileAbsenceException)
        end

        it 'checks against the configured solr url' do
          expect {
            subject.check!
          }.to raise_error(HealthMonitor::Providers::FileAbsenceException)
          expect(File).to have_received('exist?')
        end
      end
    end
  end

  describe '#configure' do
    before do
      subject.configure
    end

    let(:filename) { 'public/bad-file' }

    it 'filename can be configured' do
      expect {
        subject.configure do |config|
          config.filename = filename
        end
      }.to change { subject.configuration.filename }.to(filename)
    end
  end
end
