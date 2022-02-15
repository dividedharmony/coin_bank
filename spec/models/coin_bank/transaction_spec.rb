# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoinBank::Transaction, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user).class_name("CoinBank::User").required }
    it { is_expected.to belong_to(:from_currency).class_name("CoinBank::Currency").required }
    it { is_expected.to belong_to(:to_currency).class_name("CoinBank::Currency").required }
    it { is_expected.to have_many(:fees).class_name("CoinBank::Fee") }
  end

  describe "validations" do
    let(:transaction) { build(:transaction) }

    subject { transaction }

    it { is_expected.to validate_presence_of(:transacted_at) }
    it { is_expected.to validate_numericality_of(:from_amount) }
    it { is_expected.to validate_numericality_of(:to_amount) }
    it { is_expected.to validate_numericality_of(:exchange_rate) }
  end

  describe 'accept fee nested attributes' do
    let(:user) { create(:user) }
    let(:only_transaction_attr) do
      attributes_for(
        :transaction,
        user_id: user.id,
        from_currency_id: create(:currency).id,
        to_currency_id: create(:currency).id
      )
    end
    let(:fee_attr) do
      attributes_for(
        :fee,
        user_id: user.id,
        currency_id: create(:currency).id,
        amount: fee_amount
      )
    end
    let(:with_nested_attr) do
      only_transaction_attr.merge(
        fees_attributes: [
          fee_attr
        ]
      )
    end

    subject { described_class.new(with_nested_attr).save! }

    context 'if amount is blank' do
      let(:fee_amount) { nil }

      it 'rejects the fee atttributes' do
        expect { subject }.not_to change { CoinBank::Fee.count }.from(0)
      end
    end

    context 'if amount is less than or equal to zero' do
      let(:fee_amount) { 0 }

      it 'rejects the fee atttributes' do
        expect { subject }.not_to change { CoinBank::Fee.count }.from(0)
      end
    end

    context 'if amount is greater than zero' do
      let(:fee_amount) { 0.01 }

      it 'rejects the fee atttributes' do
        expect { subject }.to change { CoinBank::Fee.count }.from(0).to(1)
        transaction = CoinBank::Transaction.last
        expect(transaction.fees.last.amount).to eq(0.01)
      end
    end
  end
end
