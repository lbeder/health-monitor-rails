# frozen_string_literal: true

require 'spec_helper'
require 'timecop'
require './app/controllers/health_monitor/health_controller'

describe HealthMonitor::HealthController, type: :controller do
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
        config.environment_variables = nil
      end
    end

    context 'valid credentials provided' do
      before do
        request.env['HTTP_AUTHORIZATION'] =
          ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
      end

      it 'succesfully checks' do
        expect {
          get :check, format: :json
        }.not_to raise_error

        expect(response).to be_ok
        expect(JSON.parse(response.body)).to eq(
          'results' => [
            {
              'name' => 'Database',
              'message' => '',
              'status' => 'OK'
            }
          ],
          'status' => 'ok',
          'timestamp' => time.to_s(:rfc2822)
        )
      end

      context 'when filtering provider' do
        let(:params) do
          if Rails.version >= '5'
            { params: { providers: providers }, format: :json }
          else
            { providers: providers, format: :json }
          end
        end

        context 'multiple providers' do
          let(:providers) { %w[redis database] }
          it 'succesfully checks' do
            expect {
              get :check, params
            }.not_to raise_error

            expect(response).to be_ok
            expect(JSON.parse(response.body)).to eq(
              'results' => [
                {
                  'name' => 'Database',
                  'message' => '',
                  'status' => 'OK'
                }
              ],
              'status' => 'ok',
              'timestamp' => time.to_s(:rfc2822)
            )
          end
        end

        context 'single provider' do
          let(:providers) { %w[redis] }
          it 'returns empty providers' do
            expect {
              get :check, params
            }.not_to raise_error

            expect(response).to be_ok
            expect(JSON.parse(response.body)).to eq(
              'results' => [],
              'status' => 'ok',
              'timestamp' => time.to_s(:rfc2822)
            )
          end
        end

        context 'unknown provider' do
          let(:providers) { %w[foo-bar!] }
          it 'returns empty providers' do
            expect {
              get :check, params
            }.not_to raise_error

            expect(response).to be_ok
            expect(JSON.parse(response.body)).to eq(
              'results' => [],
              'status' => 'ok',
              'timestamp' => time.to_s(:rfc2822)
            )
          end
        end
      end
    end

    context 'invalid credentials provided' do
      before do
        request.env['HTTP_AUTHORIZATION'] =
          ActionController::HttpAuthentication::Basic.encode_credentials('', '')
      end

      it 'fails' do
        expect {
          get :check, format: :json
        }.not_to raise_error

        expect(response).not_to be_ok
        expect(response.status).to eq(401)
      end
    end
  end

  describe 'environment variables' do
    let(:environment_variables) { { build_number: '12', git_sha: 'example_sha' } }

    before do
      HealthMonitor.configure do |config|
        config.basic_auth_credentials = nil
        config.environment_variables = environment_variables
      end
    end

    context 'valid environment variables synatx provided' do
      it 'succesfully checks' do
        expect {
          get :check, format: :json
        }.not_to raise_error

        expect(response).to be_ok
        expect(JSON.parse(response.body)).to eq(
          'results' => [
            {
              'name' => 'Database',
              'message' => '',
              'status' => 'OK'
            }
          ],
          'status' => 'ok',
          'timestamp' => time.to_s(:rfc2822),
          'environment_variables' => {
            'build_number' => '12',
            'git_sha' => 'example_sha'
          }
        )
      end
    end
  end

  describe '#check' do
    before do
      HealthMonitor.configure do |config|
        config.basic_auth_credentials = nil
        config.environment_variables = nil
      end
    end

    context 'json rendering' do
      it 'succesfully checks' do
        expect {
          get :check, format: :json
        }.not_to raise_error

        expect(response).to be_ok
        expect(JSON.parse(response.body)).to eq(
          'results' => [
            {
              'name' => 'Database',
              'message' => '',
              'status' => 'OK'
            }
          ],
          'status' => 'ok',
          'timestamp' => time.to_s(:rfc2822)
        )
      end

      context 'failing' do
        before do
          Providers.stub_database_failure
        end

        it 'should fail' do
          expect {
            get :check, format: :json
          }.not_to raise_error

          expect(response).not_to be_ok
          expect(response.status).to eq(503)

          expect(JSON.parse(response.body)).to eq(
            'results' => [
              {
                'name' => 'Database',
                'message' => 'Exception',
                'status' => 'ERROR'
              }
            ],
            'status' => 'service_unavailable',
            'timestamp' => time.to_s(:rfc2822)
          )
        end
      end
    end

    context 'xml rendering' do
      it 'succesfully checks' do
        expect {
          get :check, format: :xml
        }.not_to raise_error

        expect(response).to be_ok
        expect(parse_xml(response)).to eq(
          'results' => [
            {
              'name' => 'Database',
              'message' => nil,
              'status' => 'OK'
            }
          ],
          'status' => 'ok',
          'timestamp' => time.to_s(:rfc2822)
        )
      end

      context 'failing' do
        before do
          Providers.stub_database_failure
        end

        it 'should fail' do
          expect {
            get :check, format: :xml
          }.not_to raise_error

          expect(response).not_to be_ok
          expect(response.status).to eq(503)

          expect(parse_xml(response)).to eq(
            'results' => [
              {
                'name' => 'Database',
                'message' => 'Exception',
                'status' => 'ERROR'
              }
            ],
            'status' => 'service_unavailable',
            'timestamp' => time.to_s(:rfc2822)
          )
        end
      end
    end
  end
end
