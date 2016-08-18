require 'spec_helper'
require 'timecop'
require './app/controllers/health_monitor/health_controller'

describe HealthMonitor::HealthController, :type => :controller do
  routes { HealthMonitor::Engine.routes }

  let(:time) { Time.local(1990) }

  before do
    Timecop.freeze(time)
  end

  after do
    Timecop.return
  end

  describe 'basic authentication' do
    let(:username) { 'username' }
    let(:password) { 'password' }

    before do
      HealthMonitor.configure do |config|
        config.basic_auth_credentials = { username: username, password: password }
        config.environmet_variables = nil
      end
    end

    context 'valid credentials provided' do
      before do
        request.env['HTTP_AUTHORIZATION'] =
          ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
      end

      it 'succesfully checks' do
        expect {
          get :check
        }.not_to raise_error

        expect(response).to be_ok
        expect(JSON.parse(response.body)).to eq([
          {
            "environmet_variables"=>{"time"=>"1990-01-01 00:00:00"}
          },
          {
          'database' => {
            'message' => '',
            'status' => 'OK',
            'timestamp' => time.to_s(:db)
          }
        }])
      end
    end

    context 'invalid credentials provided' do
      before do
        request.env['HTTP_AUTHORIZATION'] =
          ActionController::HttpAuthentication::Basic.encode_credentials('', '')
      end

      it 'fails' do
        expect {
          get :check
        }.not_to raise_error

        expect(response).not_to be_ok
        expect(response.status).to eq(401)
      end
    end
  end

  describe 'environmet variables' do
    let(:environmet_variables) { { build_number: '12', git_sha: 'example_sha' } }

    before do
      HealthMonitor.configure do |config|
        config.basic_auth_credentials = nil
        config.environmet_variables = environmet_variables
      end
    end

    context 'valid environmet variables synatx provided' do
      it 'succesfully checks' do
        expect {
          get :check
        }.not_to raise_error

        expect(response).to be_ok
        expect(JSON.parse(response.body)).to eq(
          [
            {
              'environmet_variables' => {
                'build_number' => '12',
                'git_sha' => 'example_sha',
                'time'=>'1990-01-01 00:00:00'
              }
            },
            {
              'database' => {
                'message' => '',
                'status' => 'OK',
                'timestamp' => time.to_s(:db)
              }
            }
          ]
        )
      end
    end
  end

  describe '#check' do
    before do
      HealthMonitor.configure do |config|
        config.basic_auth_credentials = nil
        config.environmet_variables = nil
      end
    end

    it 'succesfully checks' do
      expect {
        get :check
      }.not_to raise_error

      expect(response).to be_ok
      expect(JSON.parse(response.body)).to eq([
        {
            "environmet_variables"=>{"time"=>"1990-01-01 00:00:00"}
        },
        {
        'database' => {
          'message' => '',
          'status' => 'OK',
          'timestamp' => time.to_s(:db)
        }
      }])
    end

    context 'failing' do
      before do
        Providers.stub_database_failure
      end

      it 'should fail' do
        expect {
          get :check
        }.not_to raise_error

        expect(response).to be_error
        expect(JSON.parse(response.body)).to eq([
          {
            "environmet_variables"=>{"time"=>"1990-01-01 00:00:00"}
          },
          {
            'database' => {
              'message' => 'Exception',
              'status' => 'ERROR',
              'timestamp' => time.to_s(:db)
            }
          }
        ])
      end
    end
  end
end
