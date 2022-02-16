# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoinbaseIntegration::Query::Accounts do
  let(:mock_output) { double('STDOUT') }
  let(:accounts_query) { described_class.new(mock_output) }

  before do
    allow(mock_output).to receive(:puts).with(instance_of(String))
  end

  describe '#retrieve' do
    let(:mock_client) { instance_double(CoinbaseIntegration::Client) }

    subject { accounts_query.retrieve }

    before do
      expect(CoinbaseIntegration::Client).to receive(:new) { mock_client }
    end

    context 'if client fails' do
      before do
        expect(mock_client)
          .to receive(:accounts)
          .with(starting_after_uuid: nil) do
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
            .to receive(:accounts)
            .with(starting_after_uuid: nil) do
              Results::Success.new(
                object: CoinbaseIntegration::Resource.new({ 'data' => [] }),
                message: nil
              )
            end
        end

        it 'returns a Failure result' do
          expect(subject).to be_failure
          expect(subject.message).to eq('No accounts retrieved.')
        end
      end

      context 'if at least one account is retrieved' do
        let(:first_payload) do
          {
            'data' => [
              {
                'id' => 'ffe6501b-mega-fake-887893b70e05',
                'name' => 'GTC Wallet',
                'primary' => true,
                'type' => 'wallet',
                'currency' => {
                  'code' => 'GTC',
                  'name' => 'Gitcoin',
                  'color' => '#02E2AC',
                  'sort_index' => 181,
                  'exponent' => 8,
                  'type' => 'crypto',
                  'asset_id' => 'super-fake',
                  'slug' => 'gitcoin'
                },
                'balance' => {
                  'amount' => '0.00000000',
                  'currency' => 'GTC'
                },
                'created_at' => '2021-08-17T19:49:11Z',
                'updated_at' => '2021-08-17T19:49:11Z',
                'resource' => 'account',
                'allow_deposits' => true,
                'allow_withdrawals' => true
              },
              {
                'id' => 'ffe6501b-ultra-fake-888893b70e05',
                'name' => 'LOL Wallet',
                'primary' => true,
                'type' => 'wallet',
                'currency' => {
                  'code' => 'LOL',
                  'name' => 'LeagueCoin',
                  'color' => '#02E2AC',
                  'sort_index' => 182,
                  'exponent' => 8,
                  'type' => 'crypto',
                  'asset_id' => 'super-duper-fake',
                  'slug' => 'leaguecoin'
                },
                'balance' => {
                  'amount' => '0.00000000',
                  'currency' => 'LOL'
                },
                'created_at' => '2021-09-17T19:49:11Z',
                'updated_at' => '2021-09-17T19:49:11Z',
                'resource' => 'account',
                'allow_deposits' => true,
                'allow_withdrawals' => true
              }
            ],
            'pagination' => {
              'next_starting_after' => '123-next-account-uuid-456'
            }
          }
        end
        let(:second_payload) do
          {
            'data' => [
              {
                'id' => 'ffe6501b-omega-fake-887893b70e06',
                'name' => 'OMG Wallet',
                'primary' => true,
                'type' => 'wallet',
                'currency' => {
                  'code' => 'OMG',
                  'name' => 'GawdCoin',
                  'color' => '#02E2AC',
                  'sort_index' => 183,
                  'exponent' => 8,
                  'type' => 'crypto',
                  'asset_id' => 'super-mooper-fake',
                  'slug' => 'gawdcoin'
                },
                'balance' => {
                  'amount' => '100.00000000',
                  'currency' => 'OMG'
                },
                'created_at' => '2021-10-17T19:49:11Z',
                'updated_at' => '2021-10-17T19:49:11Z',
                'resource' => 'account',
                'allow_deposits' => true,
                'allow_withdrawals' => true
              }
            ],
            'pagination' => {
              'next_starting_after' => nil
            }
          }
        end

        before do
          expect(mock_client)
            .to receive(:accounts)
            .with(starting_after_uuid: nil) do
              Results::Success.new(
                object: CoinbaseIntegration::Resource.new(first_payload),
                message: nil
              )
            end
          expect(mock_client)
            .to receive(:accounts)
            .with(starting_after_uuid: '123-next-account-uuid-456') do
              Results::Success.new(
                object: CoinbaseIntegration::Resource.new(second_payload),
                message: nil
              )
            end
        end

        it 'returns a success result' do
          expect(subject).to be_success
          accounts = subject.value!
          expect(accounts.values).to contain_exactly(
            hash_including(
              'id' => 'ffe6501b-mega-fake-887893b70e05',
              'name' => 'GTC Wallet',
              'currency' => hash_including(
                'code' => 'GTC',
                'name' => 'Gitcoin'
              )
            ),
            hash_including(
              'id' => 'ffe6501b-ultra-fake-888893b70e05',
              'name' => 'LOL Wallet',
              'currency' => hash_including(
                'code' => 'LOL',
                'name' => 'LeagueCoin'
              )
            ),
            hash_including(
              'id' => 'ffe6501b-omega-fake-887893b70e06',
              'name' => 'OMG Wallet',
              'currency' => hash_including(
                'code' => 'OMG',
                'name' => 'GawdCoin'
              )
            )
          )
        end
      end
    end
  end
end
