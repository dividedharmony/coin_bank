# frozen_string_literal: true

require "rails_helper"

RSpec.describe Accounting::Valuation do
  let(:usd_currency) { create(:currency, :usd) }
  let(:other_currencies) { create_list(:currency, 2) }

  describe '#calculate' do
    let(:currency) { create(:currency, :unstable) }

    subject { described_class.new(currency).to_d }

    before do
      # irrelevant transaction to ensure that other transactions do not
      # interfere with calculations
      create(
        :transaction,
        from_currency: usd_currency,
        to_currency: create(:currency, :unstable),
        native_amount: 20_000
      )
    end

    context 'if there are no value-add transactions' do
      context 'if there are no value-remove transactions' do
        it { is_expected.to be_zero }
      end

      context 'if there are value-remove transactions' do
        before do
          create(
            :transaction,
            from_currency: currency,
            to_currency: usd_currency,
            native_amount: 34.5,
          )
          create(
            :transaction,
            from_currency: currency,
            to_currency: other_currencies.last,
            native_amount: 22.25,
          )
        end

        it 'returns a negative number' do
          # calculates 
          is_expected.to eq(-56.75)
        end
      end
    end

    context 'if there are value-add transactions' do
      before do
        create(
          :transaction,
          from_currency: other_currencies.first,
          to_currency: currency,
          native_amount: 43.25
        )
        create(
          :transaction,
          from_currency: usd_currency,
          to_currency: currency,
          native_amount: 92.11
        )
      end

      context 'if there are no value-remove transactions' do
        it 'returns a positive number' do
          is_expected.to eq(135.36)
        end
      end

      context 'if there are value-remove transactions' do
        before do
          create(
            :transaction,
            from_currency: currency,
            to_currency: other_currencies.first,
            native_amount: 2.5
          )
          create(
            :transaction,
            from_currency: currency,
            to_currency: other_currencies.last,
            native_amount: 4.5
          )
        end

        it 'subtracts the value-remove total from the value-add total' do
          is_expected.to eq(128.36)
        end
      end
    end
  end
end
