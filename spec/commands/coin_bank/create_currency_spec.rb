# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoinBank::CreateCurrency, :vcr do
  describe '.call' do
    subject { described_class.call(params) }

    context 'if given symbol is blank' do
      let(:params) { {} } # blank params

      it 'returns an error message wrapped in a Failure result' do
        expect(subject).not_to be_success
        expect(subject.message).to eq(
          "No cryptocurrency symbol given. Please give a symbol for an existent cryptocurrency."
        )
      end
    end

    context 'if given symbol is present' do
      let(:params) do
        {
          coin_bank_currency: {
            symbol: given_symbol
          }
        }
      end

      context 'if the query to coin market cap fails' do
        let(:given_symbol) { "NOT REAL SYMBOL" }

        it 'returns an error message wrapped in a Failure result' do
          expect(subject).not_to be_success
          expect(subject.message).to eq(
            '"symbol" should only include comma-separated alphanumeric cryptocurrency symbols'
          )
        end
      end

      context 'if the query to coin market cap succeeds' do
        let(:given_symbol) { "BTC" }

        context 'if currency is not valid' do
          before do
            create(
              :currency,
              name: "Other Bitcoin",
              symbol: "BTC",
              slug: "bitcoin"
            )
          end

          it 'returns an error message wrapped in a Failure monad' do
            expect(subject).not_to be_success
            expect(subject.message).to eq(
              "Symbol has already been taken\nSlug has already been taken"
            )
          end
        end

        context 'if currency is valid' do
          it 'returns a newly persisted currency wrapped in a Success monad' do
            expect(subject).to be_success
            currency = subject.value!
            aggregate_failures do
              expect(currency.name).to eq('Bitcoin')
              expect(currency.slug).to eq('bitcoin')
              expect(currency.symbol).to eq('BTC')
              expect(currency.logo_url).to eq('https://s2.coinmarketcap.com/static/img/coins/64x64/1.png')
              expect(currency.cmc_id).to eq('1')
            end
          end
        end
      end
    end
  end
end
