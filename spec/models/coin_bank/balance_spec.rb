# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoinBank::Balance, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user).class_name("CoinBank::User").required }
    it { is_expected.to belong_to(:currency).class_name("CoinBank::Currency").required }
  end

  describe "validations" do
    subject { build(:balance) }

    it { is_expected.to validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
  end

  describe "scopes" do
    describe ".latest_per_currency" do
      subject { described_class.latest_per_currency }

      context "if there are no balances" do
        it { is_expected.to be_empty }
      end

      context "if there is at least one balance" do
        let!(:currency_1) { create(:currency) }
        let!(:currency_2) { create(:currency) }
        # no balances for existent currency
        let!(:currency_3) { create(:currency) }

        # one currency, one balance
        let!(:balance_1) { create(:balance, currency: currency_1) }

        # one currency, multiple balances
        let!(:balance_2) { create(:balance, currency: currency_2) }
        let!(:balance_3) { create(:balance, currency: currency_2) }

        it { is_expected.to contain_exactly(balance_1, balance_3) }
      end
    end
  end
end
