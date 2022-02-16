# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoinbaseIntegration::Query::Trades do
  let(:mock_output) { double('STDOUT') }
  let(:trades_query) { described_class.new(mock_output) }

  before do
    allow(mock_output).to receive(:puts).with(instance_of(String))
  end

  describe '#retrieve' do
    let(:mock_client) { instance_double(CoinbaseIntegration::Client) }

    subject { trades_query.retrieve }

    before do
      expect(CoinbaseIntegration::Client).to receive(:new) { mock_client }
    end

    context 'if client fails' do
      before do
        expect(mock_client)
          .to receive(:trades) do
            Results::Failure.new(object: nil, message: 'Unable to connect.')
          end
      end

      it 'raises an error' do
        expect { subject }.to raise_error(StandardError, 'Unable to connect.')
      end
    end

    context 'if client does not fail' do
      context 'if zero account objects are retrieved' do
        before do
          expect(mock_client)
            .to receive(:trades) do
              Results::Success.new(
                object: CoinbaseIntegration::Resource.new({ 'data' => [] }),
                message: nil
              )
            end
        end

        it 'returns a Failure result' do
          expect(subject).to be_failure
          expect(subject.message).to eq('No trades retrieved.')
        end
      end

      context 'if at least one account is retrieved' do
        let(:payload) do
          {
            'data' => [
              {
                'created_at' => '2021-05-23T01:09:12Z',
                'display_input_amount' => {
                  'amount' => '15.00',
                  'currency' => 'USD'
                },
                'id' => '1ed7e1fd-5f0a-what-up-de6886cc4949',
                'input_amount' => {
                  'amount' => '14.99744294',
                  'currency' => 'DAI'
                },
                'output_amount' => {
                  'amount' => '0.02874100',
                  'currency' => 'BTC'
                },
                'exchange_rate' => {
                  'amount' => '0.00191600',
                  'currency' => 'BTC'
                },
                'unit_price' => {
                  'target_to_fiat' => {
                    'amount' => '52155.46',
                    'currency' => 'USD'
                  },
                  'target_to_source' => {
                    'amount' => '52181.35395428',
                    'currency' => 'DAI'
                  }
                },
                'fee' => {
                  'amount' => '0.00',
                  'currency' => 'USD'
                },
                'status' => 'completed',
                'updated_at' => '2021-05-23T01:09:18Z',
                'user_warnings' => [],
                'applied_subscription_benefit' => false,
                'fee_without_subscription_benefit' => nil
              },
              {
                'created_at' => '2021-05-25T01:09:12Z',
                'display_input_amount' => {
                  'amount' => '15.00',
                  'currency' => 'USD'
                },
                'id' => '1ed7e1fd-yo-dawg-de6886cc4949',
                'input_amount' => {
                  'amount' => '2.990000',
                  'currency' => 'DAI'
                },
                'output_amount' => {
                  'amount' => '498.000000',
                  'currency' => 'BTC'
                },
                'exchange_rate' => {
                  'amount' => '200.000000',
                  'currency' => 'BTC'
                },
                'unit_price' => {
                  'target_to_fiat' => {
                    'amount' => '52155.46',
                    'currency' => 'USD'
                  },
                  'target_to_source' => {
                    'amount' => '52181.35395428',
                    'currency' => 'DAI'
                  }
                },
                'fee' => {
                  'amount' => '0.00',
                  'currency' => 'USD'
                },
                'status' => 'completed',
                'updated_at' => '2021-05-25T01:09:18Z',
                'user_warnings' => [],
                'applied_subscription_benefit' => false,
                'fee_without_subscription_benefit' => nil
              }
            ]
          }
        end

        before do
          expect(mock_client)
            .to receive(:trades) do
              Results::Success.new(
                object: CoinbaseIntegration::Resource.new(payload),
                message: nil
              )
            end
        end

        it 'returns a success result' do
          expect(subject).to be_success
          accounts = subject.value!
          expect(accounts.values).to contain_exactly(
            hash_including(
              'id' => '1ed7e1fd-5f0a-what-up-de6886cc4949',
              'created_at': '2021-05-23T01:09:12Z',
              'input_amount' => {
                'amount': '14.99744294',
                'currency': 'DAI'
              },
              'output_amount' => {
                'amount': '0.02874100',
                'currency': 'BTC'
              }
            ),
            hash_including(
              'id' => '1ed7e1fd-yo-dawg-de6886cc4949',
              'created_at': '2021-05-25T01:09:12Z',
              'input_amount' => {
                'amount': '2.990000',
                'currency': 'DAI'
              },
              'output_amount' => {
                'amount': '498.000000',
                'currency': 'BTC'
              }
            )
          )
        end
      end
    end
  end
end
