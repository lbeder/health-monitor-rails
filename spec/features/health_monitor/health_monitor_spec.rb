# frozen_string_literal: true

require 'spec_helper'

describe 'Health Monitor' do
  context 'when check is ok' do
    it 'renders html' do
      visit '/check'
      expect(page).to have_css('h2', count: 1)
      expect(page).to have_css('h2', text: 'Services')
      expect(page).to have_css('.services dt.name', text: 'Database')
      expect(page).to have_css('.services div.state', text: 'OK')
    end
  end

  context 'when check failed' do
    before do
      Providers.stub_database_failure
    end

    it 'renders html' do
      visit '/check'
      expect(page).to have_css('h2', count: 1)
      expect(page).to have_css('h2', text: 'Services')
      expect(page).to have_css('.services dt.name', text: 'Database')
      expect(page).to have_css('.services div.state', text: 'ERROR')
      expect(page).to have_css('.services div.message', text: 'unable to connect to: database1,database2')
    end
  end

  context 'when response threshold is configured' do
    let(:response_threshold) { 0.5 }

    before do
      HealthMonitor.configure do |config|
        config.response_threshold = response_threshold
      end

      allow(HealthMonitor).to receive(:measure_response_time).and_return(response_threshold)
    end

    it 'renders html' do
      visit '/check'

      expect(page).to have_css('h2', count: 1)
      expect(page).to have_css('h2', text: 'Services')
      expect(page).to have_css('.services dt.name', text: 'Database')
      expect(page).to have_css('.services div.response', text: response_threshold)
    end
  end

  context 'when env variables are configured' do
    let(:environment_variables) { { build_number: '12', git_sha: 'example_sha' } }

    before do
      HealthMonitor.configure do |config|
        config.environment_variables = environment_variables
      end
    end

    it 'renders html' do
      visit '/check'
      expect(page).to have_css('h2', count: 2)
      expect(page).to have_css('h2', text: 'Services')
      expect(page).to have_css('h2', text: 'Environment Variables')
      expect(page).to have_css('.env-variables dt', count: 2)
      expect(page).to have_css('.env-variables dt', text: 'build_number')
      expect(page).to have_css('.env-variables dd', text: '12')
      expect(page).to have_css('.env-variables dt', text: 'git_sha')
      expect(page).to have_css('.env-variables dd', text: 'example_sha')
    end
  end
end
