# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoinbaseIntegration::Query::AccountTransactions do
  let(:account_id) { 'fake-account-id' }
  let(:mock_output) { double('STDOUT') }
  let(:account_transactions) { described_class.new(mock_output, account_id) }

  before do
    allow(mock_output).to receive(:puts).with(instance_of(String))
  end

  describe '#retrieve' do
    let(:mock_client) { instance_double(CoinbaseIntegration::Client) }

    subject { account_transactions.retrieve }

    before do
      expect(CoinbaseIntegration::Client).to receive(:new) { mock_client }
    end

    context 'if client fails' do
      before do
        expect(mock_client)
          .to receive(:transactions)
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
            .to receive(:transactions)
            .with(account_id, starting_after_uuid: nil) do
              Results::Success.new(
                object: CoinbaseIntegration::Resource.new({ 'data' => [] }),
                message: nil
              )
            end
        end

        it 'returns a Failure result' do
          expect(subject).to be_failure
          expect(subject.message).to eq('No transactions retrieved.')
        end
      end

      context 'if at least one account is retrieved' do
        let(:first_payload) do
          {
            'data' => [
              {
                'id' => 'b69bbb72-krabby-patties-1c24b5e138ce',
                'type' => 'interest',
                'status' => 'completed',
                'amount' => {
                  'amount' => '0.06381622',
                  'currency' => 'DAI'
                },
                'native_amount' => {
                  'amount' => '0.06',
                  'currency' => 'USD'
                },
                'created_at' => '2022-01-21T12:29:38Z',
                'updated_at' => '2022-01-21T12:29:38Z',
                'resource' => 'transaction',
                'instant_exchange' => false,
                'details' => {
                  'title' => 'Dai reward',
                  'subtitle' => 'From Coinbase',
                  'header' => 'Received 0.03381622 DAI ($0.03)',
                  'health' => 'positive'
                },
                'hide_native_amount' => false
              },
              {
                'id' => 'b21ba00c-0944-krabby-pizza-3869ce20228f',
                'type' => 'trade',
                'status' => 'completed',
                'amount' => {
                  'amount' => '0.13153200',
                  'currency' => 'MKR'
                },
                'native_amount' => {
                  'amount' => '684.00',
                  'currency' => 'USD'
                },
                'created_at' => '2021-05-11T11:04:16Z',
                'updated_at' => '2021-05-11T11:04:17Z',
                'resource' => 'transaction',
                'instant_exchange' => false,
                'trade' => {
                  'id' => '4b137c1a-trade-uuid-54d8b19115f4',
                  'resource' => 'trade',
                },
                'hide_native_amount' => false
              }
            ],
            'pagination' => {
              'next_starting_after' => '123-next-transaction-uuid-456'
            }
          }
        end
        let(:second_payload) do
          {
            'data' => [
              {
                'id' => 'b21ba00c-nope-3869ce20228f',
                'type' => 'trade',
                'status' => 'completed',
                'amount' => {
                  'amount' => '0.00138532',
                  'currency' => 'MKR'
                },
                'native_amount' => {
                  'amount' => '6.85',
                  'currency' => 'USD'
                },
                'created_at' => '2021-05-12T11:04:16Z',
                'updated_at' => '2021-05-12T11:04:17Z',
                'resource' => 'transaction',
                'instant_exchange' => false,
                'trade' => {
                  'id' => '4b137c1a-more-tradez-54d8b19115f4',
                  'resource' => 'trade',
                },
                'hide_native_amount' => false
              }
            ],
            'pagination' => {
              'next_starting_after' => nil
            }
          }
        end

        before do
          expect(mock_client)
            .to receive(:transactions)
            .with(account_id, starting_after_uuid: nil) do
              Results::Success.new(
                object: CoinbaseIntegration::Resource.new(first_payload),
                message: nil
              )
            end
          expect(mock_client)
            .to receive(:transactions)
            .with(account_id, starting_after_uuid: '123-next-transaction-uuid-456') do
              Results::Success.new(
                object: CoinbaseIntegration::Resource.new(second_payload),
                message: nil
              )
            end
        end

        it 'returns a success result' do
          expect(subject).to be_success
          transactions = subject.value!
          # binding.pry
          expect(transactions.to_h).to include({
            'b69bbb72-krabby-patties-1c24b5e138ce' => hash_including(
              'id' => 'b69bbb72-krabby-patties-1c24b5e138ce',
              'type' => 'interest',
              'amount' => {
                'amount' => '0.06381622',
                'currency' => 'DAI'
              },
              'native_amount' => {
                'amount' => '0.06',
                'currency' => 'USD'
              }
            ),
            'b21ba00c-0944-krabby-pizza-3869ce20228f' => hash_including(
              'id' => 'b21ba00c-0944-krabby-pizza-3869ce20228f',
              'type' => 'trade',
              'amount' => {
                'amount' => '0.13153200',
                'currency' => 'MKR'
              },
              'native_amount' => {
                'amount' => '684.00',
                'currency' => 'USD'
              }
            ),
            'b21ba00c-nope-3869ce20228f' => hash_including(
              'id' => 'b21ba00c-nope-3869ce20228f',
              'type' => 'trade',
              'amount' => {
                'amount' => '0.00138532',
                'currency' => 'MKR'
              },
              'native_amount' => {
                'amount' => '6.85',
                'currency' => 'USD'
              }
            )
          })
        end
      end
    end
  end
end
