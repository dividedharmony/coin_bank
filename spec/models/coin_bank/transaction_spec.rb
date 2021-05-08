# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoinBank::Transaction, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user).class_name("CoinBank::User").required }
    it { is_expected.to belong_to(:from_before_balance).class_name("CoinBank::Balance").required }
    it { is_expected.to belong_to(:from_after_balance).class_name("CoinBank::Balance").required }
    it { is_expected.to belong_to(:to_before_balance).class_name("CoinBank::Balance").required }
    it { is_expected.to belong_to(:to_after_balance).class_name("CoinBank::Balance").required }
  end

  describe "validations" do
    let(:transaction) { build(:transaction) }

    subject { transaction }

    it { is_expected.to validate_presence_of(:transacted_at) }
    it { is_expected.to validate_numericality_of(:from_amount) }
    it { is_expected.to validate_numericality_of(:to_amount) }
    it { is_expected.to validate_numericality_of(:fee_amount) }
    it { is_expected.to validate_numericality_of(:exchange_rate) }

    describe "currency matching on balances" do
      context "if the from balances do not match currencies" do
        let(:from_before_balance) { create(:balance) }
        let(:from_after_balance) { create(:balance) }
        let(:transaction) do
          build(
            :transaction,
            from_before_balance: from_before_balance,
            from_after_balance: from_after_balance
          )
        end

        it "is not valid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:from_after_balance]).to include(
            "does not match the from_before_balance currency"
          )
        end
      end

      context "if the to balances do not match currencies" do
        let(:to_before_balance) { create(:balance) }
        let(:to_after_balance) { create(:balance) }
        let(:transaction) do
          build(
            :transaction,
            to_before_balance: to_before_balance,
            to_after_balance: to_after_balance
          )
        end

        it "is not valid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:to_after_balance]).to include(
            "does not match the to_before_balance currency"
          )
        end
      end

      context "if the from and to balances match currencies" do
        let(:from_currency) { create(:currency) }
        let(:to_currency) { create(:currency) }
        let(:from_before_balance) { create(:balance, currency: from_currency) }
        let(:from_after_balance) { create(:balance, currency: from_currency) }
        let(:to_before_balance) { create(:balance, currency: to_currency) }
        let(:to_after_balance) { create(:balance, currency: to_currency) }
        let(:transaction) do
          build(
            :transaction,
            from_before_balance: from_before_balance,
            from_after_balance: from_after_balance,
            to_before_balance: to_before_balance,
            to_after_balance: to_after_balance
          )
        end

        it { is_expected.to be_valid }
      end
    end
  end

  describe "#from_currency" do
    subject { transaction.from_currency }

    let(:from_before_balance) { create(:balance) }
    let(:transaction) { create(:transaction, from_before_balance: from_before_balance) }

    it { is_expected.to eq(from_before_balance.currency) }
  end

  describe "#to_currency" do
    subject { transaction.to_currency }

    let(:to_before_balance) { create(:balance) }
    let(:transaction) { create(:transaction, to_before_balance: to_before_balance) }

    it { is_expected.to eq(to_before_balance.currency) }
  end
end
