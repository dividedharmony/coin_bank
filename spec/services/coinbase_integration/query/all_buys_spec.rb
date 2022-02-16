# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoinbaseIntegration::Query::AllBuys do
  let(:mock_output) { double('STDOUT') }
  let(:all_buys) { described_class.new(mock_output) }

  before do
    allow(mock_output).to receive(:puts).with(instance_of(String))
  end

  describe '#retrieve' do
    let(:mock_accounts) { instance_double(CoinbaseIntegration::Query::Accounts) }

    subject { all_buys.retrieve }

    before do
      expect(CoinbaseIntegration::Query::Accounts).to receive(:new) { mock_accounts }
    end

    context 'if accounts query fails' do
      before do
        expect(mock_accounts).to receive(:retrieve) do
          Results::Failure.new(object: nil, message: 'All accounts are being wierd right now.')
        end
      end

      it 'returns a Failure result' do
        expect(subject).to be_failure
        expect(subject.message).to eq('All accounts are being wierd right now.')
        expect(mock_output).to have_received(:puts).with('WARNING: All accounts are being wierd right now.')
      end
    end

    context 'if accounts query succeeds' do
      let(:first_mock_buy_query) { instance_double(CoinbaseIntegration::Query::AccountBuys) }
      let(:second_mock_buy_query) { instance_double(CoinbaseIntegration::Query::AccountBuys) }
      let(:accounts_retrieve_result) do
        instance_double(
          CoinbaseIntegration::Query::Accounts,
          values: [
            { 'id' => 'super-fake-account-id', 'name' => 'SUPERFAKE' },
            { 'id' => 'too-fake-account-id', 'name' => 'TOOFAKE' }
          ]
        )
      end
      let(:first_buys_retrieve_result) do
        instance_double(
          CoinbaseIntegration::Query::AccountTransactions,
          to_h: {
            'b3c6ca6b-bulbasaur-1d3ecbe8d11d' => { 
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
            },
            'a3c6ca6b-mimikyu-1d3ecbe8d11d' => { 
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
        expect(CoinbaseIntegration::Query::AccountBuys).to receive(:new).with(mock_output, 'super-fake-account-id') do
          first_mock_buy_query
        end
        expect(CoinbaseIntegration::Query::AccountBuys).to receive(:new).with(mock_output, 'too-fake-account-id') do
          second_mock_buy_query
        end
        expect(first_mock_buy_query).to receive(:retrieve) do
          Results::Success.new(
            object: first_buys_retrieve_result,
            message: nil
          )
        end
      end

      context 'if any account transactions query fails' do
        before do
          expect(second_mock_buy_query).to receive(:retrieve) do
            Results::Failure.new(
              object: nil,
              message: 'Account is super sus.'
            )
          end
        end

        it 'returns a Failure result' do
          expect(subject).to be_failure
          expect(subject.message).to eq('[TOOFAKE]: Account is super sus.')
          expect(mock_output).to have_received(:puts).with(
            'WARNING: [TOOFAKE]: Account is super sus.'
          )
        end
      end

      context 'if all account transactions queries succeeds' do
        before do
          expect(second_mock_buy_query).to receive(:retrieve) do
            Results::Success.new(
              object: second_buys_retrieve_result,
              message: nil
            )
          end
        end

        context 'if zero account transactions are returned' do
          let(:first_buys_retrieve_result) do
            instance_double(
              CoinbaseIntegration::Query::AccountBuys,
              to_h: {}
            )
          end
          let(:second_buys_retrieve_result) do
            instance_double(
              CoinbaseIntegration::Query::AccountBuys,
              to_h: {}
            )
          end

          it 'returns a Failure result' do
            expect(subject).to be_failure
            expect(subject.message).to eq('No buys to import.')
            expect(mock_output).to have_received(:puts).with(
              'WARNING: No buys to import.'
            )
          end
        end

        context 'if at least one account transaction is returned' do
          let(:second_buys_retrieve_result) do
            instance_double(
              CoinbaseIntegration::Query::AccountTransactions,
              to_h: {
                'b3c6ca6b-bulbasaur-1d3ecbe8d11d' => { 
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
                },
                'a3c6ca6b-mimikyu-1d3ecbe8d11d' => { 
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
                },
                '93c6ca6b-munchlax-1d3ecbe8d11d' => { 
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
                },
                '93c6ca6b-riptide-1d3ecbe8d11e' => {
                  'id' => '93c6ca6b-riptide-1d3ecbe8d11e',
                  'created_at' => '2021-05-28T11:45:23Z',
                  'fee' => {
                    'amount' => '30.94',
                    'currency' => 'USD'
                  },
                  'amount' => {
                    'amount' => '5.79283131',
                    'currency' => 'DAI'
                  },
                  'total' => {
                    'amount' => '38.00',
                    'currency' => 'USD'
                  },
                  'subtotal' => {
                    'amount' => '7.59',
                    'currency' => 'USD'
                  }
                }
              }
            )
          end

          it 'returns a Success result' do
            expect(subject).to be_success
            buys_store = subject.value!
            expect(buys_store.values).to contain_exactly(
              { 
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
              },
              { 
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
              },
              { 
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
              },
              {
                'id' => '93c6ca6b-riptide-1d3ecbe8d11e',
                'created_at' => '2021-05-28T11:45:23Z',
                'fee' => {
                  'amount' => '30.94',
                  'currency' => 'USD'
                },
                'amount' => {
                  'amount' => '5.79283131',
                  'currency' => 'DAI'
                },
                'total' => {
                  'amount' => '38.00',
                  'currency' => 'USD'
                },
                'subtotal' => {
                  'amount' => '7.59',
                  'currency' => 'USD'
                }
              }
            )
            expect(mock_output).to have_received(:puts).with(
              'Iterating through account buys...'
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
