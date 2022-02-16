# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoinbaseIntegration::Query::AccountBuys do
  let(:account_id) { 'fake-account-id' }
  let(:mock_output) { double('STDOUT') }
  let(:account_buys) { described_class.new(mock_output, account_id) }

  before do
    allow(mock_output).to receive(:puts).with(instance_of(String))
  end

  describe '#retrieve' do
    let(:mock_client) { instance_double(CoinbaseIntegration::Client) }

    subject { account_buys.retrieve }

    before do
      expect(CoinbaseIntegration::Client).to receive(:new) { mock_client }
    end

    context 'if client fails' do
      before do
        expect(mock_client)
          .to receive(:buys)
          .with(account_id, starting_after_uuid: nil) do
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
            .to receive(:buys)
            .with(account_id, starting_after_uuid: nil) do
              Results::Success.new(
                object: CoinbaseIntegration::Resource.new({ 'data' => [] }),
                message: nil
              )
            end
        end

        it 'returns a Failure result' do
          expect(subject).to be_failure
          expect(subject.message).to eq('No buys retrieved.')
        end
      end

      context 'if at least one account is retrieved' do
        let(:first_payload) do
          {
            'data' => [
              {
                'id' => '93c6ca6b-munchlax-1d3ecbe8d11d',
                'status' => 'completed',
                'created_at' => '2021-05-21T11:45:23Z',
                'updated_at' => '2021-05-21T11:45:30Z',
                'resource' => 'buy',
                'committed' => true,
                'instant' => true,
                'fee' => {
                  'amount' => '30.84',
                  'currency' => 'USD'
                },
                'amount' => {
                  'amount' => '5.59283131',
                  'currency' => 'DAI'
                },
                'total' => {
                  'amount' => '36.00',
                  'currency' => 'USD'
                },
                'subtotal' => {
                  'amount' => '5.59',
                  'currency' => 'USD'
                },
                'unit_price' => {
                  'amount' => '1.0059',
                  'currency' => 'USD',
                  'scale' => 4
                },
                'hold_days' => 0,
                'next_step' => nil,
                'is_first_buy' => false,
                'requires_completion_step' => false
              },
              {
                'id' => 'a3c6ca6b-mimikyu-1d3ecbe8d11d',
                'status' => 'completed',
                'created_at' => '2021-05-22T11:45:23Z',
                'updated_at' => '2021-05-22T11:45:30Z',
                'resource' => 'buy',
                'committed' => true,
                'instant' => true,
                'fee' => {
                  'amount' => '32.84',
                  'currency' => 'USD'
                },
                'amount' => {
                  'amount' => '4.59283131',
                  'currency' => 'DAI'
                },
                'total' => {
                  'amount' => '39.00',
                  'currency' => 'USD'
                },
                'subtotal' => {
                  'amount' => '4.59',
                  'currency' => 'USD'
                },
                'unit_price' => {
                  'amount' => '1.0059',
                  'currency' => 'USD',
                  'scale' => 4
                },
                'hold_days' => 0,
                'next_step' => nil,
                'is_first_buy' => false,
                'requires_completion_step' => false
              }
            ],
            'pagination' => {
              'next_starting_after' => '123-next-buy-uuid-456'
            }
          }
        end
        let(:second_payload) do
          {
            'data' => [
              {
                'id' => 'b3c6ca6b-bulbasaur-1d3ecbe8d11d',
                'status' => 'completed',
                'created_at' => '2021-05-23T11:45:23Z',
                'updated_at' => '2021-05-23T11:45:30Z',
                'resource' => 'buy',
                'committed' => true,
                'instant' => true,
                'fee' => {
                  'amount' => '132.84',
                  'currency' => 'USD'
                },
                'amount' => {
                  'amount' => '104.59283131',
                  'currency' => 'DAI'
                },
                'total' => {
                  'amount' => '239.00',
                  'currency' => 'USD'
                },
                'subtotal' => {
                  'amount' => '104.59',
                  'currency' => 'USD'
                },
                'unit_price' => {
                  'amount' => '1.0059',
                  'currency' => 'USD',
                  'scale' => 4
                },
                'hold_days' => 0,
                'next_step' => nil,
                'is_first_buy' => false,
                'requires_completion_step' => false
              }
            ],
            'pagination' => {
              'next_starting_after' => nil
            }
          }
        end

        before do
          expect(mock_client)
            .to receive(:buys)
            .with(account_id, starting_after_uuid: nil) do
              Results::Success.new(
                object: CoinbaseIntegration::Resource.new(first_payload),
                message: nil
              )
            end
          expect(mock_client)
            .to receive(:buys)
            .with(account_id, starting_after_uuid: '123-next-buy-uuid-456') do
              Results::Success.new(
                object: CoinbaseIntegration::Resource.new(second_payload),
                message: nil
              )
            end
        end

        it 'returns a success result' do
          expect(subject).to be_success
          buys = subject.value!
          expect(buys.to_h).to include({
            '93c6ca6b-munchlax-1d3ecbe8d11d' => hash_including(
              'id' => '93c6ca6b-munchlax-1d3ecbe8d11d',
              'created_at' => '2021-05-21T11:45:23Z',
              'fee' => {
                'amount' => '30.84',
                'currency' => 'USD'
              },
              'amount' => {
                'amount' => '5.59283131',
                'currency' => 'DAI'
              },
              'total' => {
                'amount' => '36.00',
                'currency' => 'USD'
              },
              'subtotal' => {
                'amount' => '5.59',
                'currency' => 'USD'
              }
            ),
            'a3c6ca6b-mimikyu-1d3ecbe8d11d' => hash_including(
              'id' => 'a3c6ca6b-mimikyu-1d3ecbe8d11d',
              'created_at' => '2021-05-22T11:45:23Z',
              'fee' => {
                'amount' => '32.84',
                'currency' => 'USD'
              },
              'amount' => {
                'amount' => '4.59283131',
                'currency' => 'DAI'
              },
              'total' => {
                'amount' => '39.00',
                'currency' => 'USD'
              },
              'subtotal' => {
                'amount' => '4.59',
                'currency' => 'USD'
              }
            ),
            'b3c6ca6b-bulbasaur-1d3ecbe8d11d' => hash_including(
              'id' => 'b3c6ca6b-bulbasaur-1d3ecbe8d11d',
              'created_at' => '2021-05-23T11:45:23Z',
              'fee' => {
                'amount' => '132.84',
                'currency' => 'USD'
              },
              'amount' => {
                'amount' => '104.59283131',
                'currency' => 'DAI'
              },
              'total' => {
                'amount' => '239.00',
                'currency' => 'USD'
              },
              'subtotal' => {
                'amount' => '104.59',
                'currency' => 'USD'
              }
            )
          })
        end
      end
    end
  end
end
