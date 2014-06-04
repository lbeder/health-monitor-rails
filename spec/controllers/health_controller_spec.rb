require 'spec_helper'
require './app/controllers/health_monitor/health_controller'

describe HealthMonitor::HealthController, :type => :controller do
  describe '#check' do
    it 'should succesfully check!' do
      expect {
        get :check, :use_route => :health_monitor
      }.not_to raise_error

      expect(response).to be_ok
      expect(response.body).to include('Health check has passed')
    end

    context 'failing' do
      before do
        Providers.stub_database_failure
      end

      it 'should fail' do
        expect {
          get :check, :use_route => :health_monitor
        }.not_to raise_error

        expect(response).to be_error
        expect(response.body).to include('Health check has failed')
      end
    end
  end
end
