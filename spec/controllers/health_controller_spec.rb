require 'spec_helper'
require './app/controllers/health_monitor/health_controller'

describe HealthMonitor::HealthController, :type => :controller do
  describe "Basic authentication" do
    let(:username) { "Some-Username" }
    let(:password) { "Some-Password" }

    before(:each) do
      HealthMonitor.configure do |config|
        config.basic_auth_credentials = {username: username, password: password}
      end
    end

    context "valid credentials provided" do
      before(:each) do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
      end

      it 'should successfully check!' do
        expect {
          get :check, :use_route => :health_monitor
        }.not_to raise_error

        expect(response).to be_ok
        expect(response.body).to include('Health check has passed')
      end
    end

    context "invalid credentials provided" do
      before(:each) do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials("", "")
      end

      it 'should fail' do
        expect {
          get :check, :use_route => :health_monitor
        }.not_to raise_error

        expect(response).not_to be_ok
        expect(response.status).to eq(401)
      end
    end
  end

  describe '#check' do
    before do
      HealthMonitor.configure do |config|
        config.basic_auth_credentials = nil
      end
    end

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
