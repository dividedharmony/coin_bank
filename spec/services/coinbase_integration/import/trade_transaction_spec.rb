# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoinbaseIntegration::Import::TradeTransaction do
  let(:currencies) { instance_double(CoinbaseIntegration::Currencies) }
  let(:trade_transaction) { described_class.new(currencies) }

  describe '#import!' do
    let(:user) { create(:user) }

    subject { trade_transaction.import!(user, raw_trade) }

    context 'if fee is blank' do
      let(:dai_currency) { create(:currency, symbol: 'DAI') }
      let(:btc_currency) { create(:currency, symbol: 'BTC') }
      let(:raw_trade) do
        {
          'created_at' => '2021-04-24T01:09:12Z',
          'display_input_amount' => {
            'amount' => '14.51',
            'currency' => 'USD'
          },
          'id' => '1ed7e-yabba-dabba-do-cc4949',
          'input_amount' => {
            'amount' => '14.99744294',
            'currency' => 'DAI'
          },
          'output_amount' => {
            'amount' => '0.00028741',
            'currency' => 'BTC'
          },
          'exchange_rate' => {
            'amount' => '0.00001916',
            'currency' => 'BTC'
          }
        }
      end

      before do
        expect(currencies).to receive(:fetch).with('DAI') { dai_currency }
        expect(currencies).to receive(:fetch).with('BTC') { btc_currency }
      end
      
      it 'creates the transaction without the fee' do
        expect { subject }.to change { CoinBank::Transaction.count }.from(0).to(1)
        aggregate_failures do
          expect(subject.user).to eq(user)
          expect(subject.from_currency).to eq(dai_currency)
          expect(subject.to_currency).to eq(btc_currency)
          expect(subject.from_amount).to eq(BigDecimal('14.99744294'))
          expect(subject.to_amount).to eq(BigDecimal('0.00028741'))
          expect(subject.exchange_rate).to eq(BigDecimal('0.00001916'))
          expect(subject.native_amount).to eq(14.51)
          expect(subject.transacted_at).to eq('2021-04-24T01:09:12Z'.to_datetime)
          expect(subject.coinbase_uuid).to eq('1ed7e-yabba-dabba-do-cc4949')
          expect(subject.fees).to be_empty
        end
      end
    end

    context 'if fee is present' do
      let(:usd_currency) { create(:currency, symbol: 'USD') }
      let(:rar_currency) { create(:currency, symbol: 'RAR') }
      let(:dvd_currency) { create(:currency, symbol: 'DVD') }
      let(:raw_trade) do
        {
          'created_at' => '2021-04-26T01:09:12Z',
          'display_input_amount' => {
            'amount' => '16.02',
            'currency' => 'USD'
          },
          'id' => '1ed7e-fire-and-ice-cc4948',
          'input_amount' => {
            'amount' => '29.99744294',
            'currency' => 'RAR'
          },
          'output_amount' => {
            'amount' => '0.00078741',
            'currency' => 'DVD'
          },
          'exchange_rate' => {
            'amount' => '0.00004416',
            'currency' => 'DVD'
          },
          'fee' => {
            'amount' => '30.01',
            'currency' => 'USD'
          }
        }
      end

      before do
        expect(currencies).to receive(:fetch).with('RAR') { rar_currency }
        expect(currencies).to receive(:fetch).with('DVD') { dvd_currency }
        expect(currencies).to receive(:fetch).with('USD') { usd_currency }
      end

      it 'creates the transaction with the fee' do
        expect { subject }.to change { CoinBank::Transaction.count }.from(0).to(1)
        aggregate_failures do
          expect(subject.user).to eq(user)
          expect(subject.from_currency).to eq(rar_currency)
          expect(subject.to_currency).to eq(dvd_currency)
          expect(subject.from_amount).to eq(BigDecimal('29.99744294'))
          expect(subject.to_amount).to eq(BigDecimal('0.00078741'))
          expect(subject.exchange_rate).to eq(BigDecimal('0.00004416'))
          expect(subject.native_amount).to eq(16.02)
          expect(subject.transacted_at).to eq('2021-04-26T01:09:12Z'.to_datetime)
          expect(subject.coinbase_uuid).to eq('1ed7e-fire-and-ice-cc4948')
          expect(subject.fees.count).to eq(1)
        end
        fee = subject.fees.first
        expect(fee.amount).to eq(30.01)
        expect(fee.currency).to eq(usd_currency)
      end
    end
  end
end
