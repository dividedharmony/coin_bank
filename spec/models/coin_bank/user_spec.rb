# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoinBank::User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:balances).class_name("CoinBank::Balance") }

    describe "#current_balances" do
      subject { user.current_balances }

      let(:user) { create(:user) }
      let(:other_user) { create(:user) }

      let(:currency_1) { create(:currency) }
      let(:currency_2) { create(:currency) }
      let(:currency_3) { create(:currency) }
      let(:currency_4) { create(:currency) }

      # Only one currency and one user
      let!(:balance_1) { create(:balance, user: user, currency: currency_1) }

      # Two balances, should only include latest
      let!(:balance_2) { create(:balance, user: user, currency: currency_2) }
      let!(:balance_3) { create(:balance, user: user, currency: currency_2) }

      # Two users, one currency
      let!(:balance_4) { create(:balance, user: user, currency: currency_3) }
      let!(:balance_5) { create(:balance, user: other_user, currency: currency_3) }

      # A currency our user has never used
      let!(:balance_6) { create(:balance, user: other_user, currency: currency_4) }

      it "only includes the latest balance for the given user" do
        expect(subject).to contain_exactly(balance_1, balance_3, balance_4)
      end
    end
  end

  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }
  end
end
