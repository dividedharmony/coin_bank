# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoinbaseIntegration::Query::AllTransactions do
  let(:mock_output) { double('STDOUT') }
  let(:all_transactions) { described_class.new(mock_output) }

  before do
    allow(mock_output).to receive(:puts).with(instance_of(String))
  end

  describe '#retrieve' do
    let(:mock_accounts) { instance_double(CoinbaseIntegration::Query::Accounts) }

    subject { all_transactions.retrieve }

    before do
      expect(CoinbaseIntegration::Query::Accounts).to receive(:new) { mock_accounts }
    end

    context 'if accounts query fails' do
      before do
        expect(mock_accounts).to receive(:retrieve) do
          Results::Failure.new(object: nil, message: 'All accounts have been hacked.')
        end
      end

      it 'returns a Failure result' do
        expect(subject).to be_failure
        expect(subject.message).to eq('All accounts have been hacked.')
        expect(mock_output).to have_received(:puts).with('WARNING: All accounts have been hacked.')
      end
    end

    context 'if accounts query succeeds' do
      let(:first_mock_transactions) { instance_double(CoinbaseIntegration::Query::AccountTransactions) }
      let(:second_mock_transactions) { instance_double(CoinbaseIntegration::Query::AccountTransactions) }
      let(:accounts_retrieve_result) do
        instance_double(
          CoinbaseIntegration::Query::Accounts,
          values: [
            { 'id' => 'super-fake-account-id', 'name' => 'SUPERFAKE' },
            { 'id' => 'too-fake-account-id', 'name' => 'TOOFAKE' }
          ]
        )
      end
      let(:first_transactions_retrieve_result) do
        instance_double(
          CoinbaseIntegration::Query::AccountTransactions,
          to_h: {
            'super-fake-transaction-id' => { 
              'id' => 'super-fake-transaction-id',
              'type' => 'trade',
              'status' => 'completed',
              'amount' => {
                'amount' => '0.987000',
                'currency' => 'MKR'
              },
              'native_amount' => {
                'amount' => '12.34',
                'currency' => 'USD'
              }
            },
            'too-fake-transaction-id' => { 
              'id' => 'too-fake-transaction-id',
              'type' => 'interest',
              'status' => 'completed',
              'amount' => {
                'amount' => '0.1234',
                'currency' => 'OMG'
              },
              'native_amount' => {
                'amount' => '7.89',
                'currency' => 'LOL'
              }
            }
          }
        )
      end

      before do
        # mock accounts query
        expect(mock_accounts).to receive(:retrieve) do
          Results::Success.new(
            object: accounts_retrieve_result,
            message: nil
          )
        end
        # mock account transactions query
        expect(CoinbaseIntegration::Query::AccountTransactions).to receive(:new).with(mock_output, 'super-fake-account-id') do
          first_mock_transactions
        end
        expect(CoinbaseIntegration::Query::AccountTransactions).to receive(:new).with(mock_output, 'too-fake-account-id') do
          second_mock_transactions
        end
        expect(first_mock_transactions).to receive(:retrieve) do
          Results::Success.new(
            object: first_transactions_retrieve_result,
            message: nil
          )
        end
      end

      context 'if any account transactions query fails' do
        before do
          expect(second_mock_transactions).to receive(:retrieve) do
            Results::Failure.new(
              object: nil,
              message: 'Account is obviously fake.'
            )
          end
        end

        it 'returns a Failure result' do
          expect(subject).to be_failure
          expect(subject.message).to eq('[TOOFAKE]: Account is obviously fake.')
          expect(mock_output).to have_received(:puts).with(
            'WARNING: [TOOFAKE]: Account is obviously fake.'
          )
        end
      end

      context 'if all account transactions queries succeeds' do
        before do
          expect(second_mock_transactions).to receive(:retrieve) do
            Results::Success.new(
              object: second_transactions_retrieve_result,
              message: nil
            )
          end
        end

        context 'if zero account transactions are returned' do
          let(:first_transactions_retrieve_result) do
            instance_double(
              CoinbaseIntegration::Query::AccountTransactions,
              to_h: {}
            )
          end
          let(:second_transactions_retrieve_result) do
            instance_double(
              CoinbaseIntegration::Query::AccountTransactions,
              to_h: {}
            )
          end

          it 'returns a Failure result' do
            expect(subject).to be_failure
            expect(subject.message).to eq('No transactions to import.')
            expect(mock_output).to have_received(:puts).with(
              'WARNING: No transactions to import.'
            )
          end
        end

        context 'if at least one account transaction is returned' do
          let(:second_transactions_retrieve_result) do
            instance_double(
              CoinbaseIntegration::Query::AccountTransactions,
              to_h: {
                'charizard-transaction-id' => { 
                  'id' => 'charizard-transaction-id',
                  'type' => 'pokemon',
                  'status' => 'completed',
                  'amount' => {
                    'amount' => '2.468',
                    'currency' => 'CHAR'
                  },
                  'native_amount' => {
                    'amount' => '75.31',
                    'currency' => 'USD'
                  }
                },
                'squirtle-transaction-id' => { 
                  'id' => 'squirtle-transaction-id',
                  'type' => 'digimon',
                  'status' => 'completed',
                  'amount' => {
                    'amount' => '99.9999',
                    'currency' => 'DIGI'
                  },
                  'native_amount' => {
                    'amount' => '1.11',
                    'currency' => 'CAD'
                  }
                }
              }
            )
          end

          it 'returns a Success result' do
            expect(subject).to be_success
            transaction_store = subject.value!
            expect(transaction_store.values).to contain_exactly(
              { 
                'id' => 'super-fake-transaction-id',
                'type' => 'trade',
                'status' => 'completed',
                'amount' => {
                  'amount' => '0.987000',
                  'currency' => 'MKR'
                },
                'native_amount' => {
                  'amount' => '12.34',
                  'currency' => 'USD'
                }
              },
              { 
                'id' => 'too-fake-transaction-id',
                'type' => 'interest',
                'status' => 'completed',
                'amount' => {
                  'amount' => '0.1234',
                  'currency' => 'OMG'
                },
                'native_amount' => {
                  'amount' => '7.89',
                  'currency' => 'LOL'
                }
              },
              { 
                'id' => 'charizard-transaction-id',
                'type' => 'pokemon',
                'status' => 'completed',
                'amount' => {
                  'amount' => '2.468',
                  'currency' => 'CHAR'
                },
                'native_amount' => {
                  'amount' => '75.31',
                  'currency' => 'USD'
                }
              },
              { 
                'id' => 'squirtle-transaction-id',
                'type' => 'digimon',
                'status' => 'completed',
                'amount' => {
                  'amount' => '99.9999',
                  'currency' => 'DIGI'
                },
                'native_amount' => {
                  'amount' => '1.11',
                  'currency' => 'CAD'
                }
              }
            )
            expect(mock_output).to have_received(:puts).with(
              'Iterating through account transactions...'
            )
            expect(mock_output).to have_received(:puts).with(
              'Finished retrieving from api...'
            )
          end
        end
      end
    end
  end
end
