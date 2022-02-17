# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoinbaseIntegration::Import::PersistTransactions do
  let(:user) { create(:user) }
  let(:mock_output) { double('STDOUT') }
  let(:persist_transactions) { described_class.new(output: mock_output, user: user) }

  before do
    allow(mock_output).to receive(:puts).with(instance_of(String))
    # initialize currencies
    create(:currency, symbol: 'USD')
    create(:currency, symbol: 'COINBASE REWARDS')
  end

  describe '#call' do
    let(:mock_trades_query) { instance_double(CoinbaseIntegration::Query::Trades) }

    subject { persist_transactions.call }

    before do
      expect(CoinbaseIntegration::Query::Trades).to receive(:new).with(mock_output) { mock_trades_query }
    end

    context 'if trades query fails' do
      before do
        expect(mock_trades_query).to receive(:retrieve) do
          Results::Failure.new(
            object: nil,
            message: 'Everything is wrong.'
          )
        end
      end

      it 'raises an error' do
        expect { subject }.to raise_error(
          CoinbaseIntegration::Import::PersistTransactions::QueryFailed,
          'WARNING: Everything is wrong.'
        )
      end
    end

    context 'if trades query succeeds' do
      let(:mock_all_transactions) { instance_double(CoinbaseIntegration::Query::AllTransactions) }
      let(:raw_trade) do
        {
          'id' => '2b3c-star-wars-5z7x',
          'input_amount' => {
            'amount' => '0.00016900',
            'currency' => 'BTC'
          },
          'output_amount' => {
            'amount' => '7.276517',
            'currency' => 'ADA'
          },
        }
      end
      let(:trades_result) do
        instance_double(
          CoinbaseIntegration::Query::Trades,
          to_h: { '2b3c-star-wars-5z7x' => raw_trade }
        )
      end

      before do
        expect(mock_trades_query).to receive(:retrieve) do
          Results::Success.new(
            object: trades_result,
            message: nil
          )
        end
        expect(
          CoinbaseIntegration::Query::AllTransactions
        ).to receive(:new).with(mock_output) { mock_all_transactions }
      end

      context 'if AllTransactions query fails' do
        before do
          expect(mock_all_transactions).to receive(:retrieve) do
            Results::Failure.new(
              object: nil,
              message: 'All transactions have been deleted.'
            )
          end
        end

        it 'fails' do
          expect(subject).to be_failure
          expect(subject.message).to eq('All transactions have been deleted.')
        end
      end

      context 'if AllTransactions query succeeds' do\
        let(:all_transactions_result) do
          {
            '2222-rapid-fire-4444' => raw_transaction
          }
        end

        before do
          expect(mock_all_transactions).to receive(:retrieve) do
            Results::Success.new(
              object: all_transactions_result,
              message: nil
            )
          end
        end

        context 'if a given transaction is a trade' do
          let(:raw_transaction) do
            {
              'id' => '2222-rapid-fire-4444',
              'type' => 'trade',
              'trade' => {
                'id' => trade_id
              }
            }
          end

          context 'if transaction cannot be paired with a trade' do
            let(:trade_id) { 'star-trek-2009-xygh12' }

            it 'raises an error' do
              expect { subject }.to raise_error(
                CoinbaseIntegration::Import::PersistTransactions::TradeNotFound,
                "Could not find trade object with 'id' star-trek-2009-xygh12"
              )
            end
          end

          context 'if transaction can be paired with a trade' do
            let(:trade_id) { '2b3c-star-wars-5z7x' }

            it 'imports the transaction' do
              expect_any_instance_of(
                CoinbaseIntegration::Import::TradeTransaction
              ).to receive(:import!).with(user, raw_trade)
              subject
            end
          end
        end

        context 'if a given transaction is not a trade' do
          let(:raw_transaction) do
            {
              'id' => '2222-rapid-fire-4444',
              'type' => 'interest',
              'amount' => {
                'amount' => '0.00096080',
                'currency' => 'MKR'
              },
              'native_amount' => {
                'amount' => '4.89',
                'currency' => 'USD'
              }
            }
          end

          it 'imports the transaction' do
            expect_any_instance_of(
              CoinbaseIntegration::Import::NonTradeTransaction
            ).to receive(:import!).with(user, raw_transaction)
            subject
          end
        end
      end
    end
  end
end
