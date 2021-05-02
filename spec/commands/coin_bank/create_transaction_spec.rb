# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoinBank::CreateTransaction do
  describe ".call" do
    let(:current_user) { nil }
    let(:user_id) { nil }
    let(:from_currency_id) { nil }
    let(:to_currency_id) { nil }
    let(:from_amount) { nil }
    let(:to_amount) { nil }
    let(:fee_amount) { nil }
    let(:transacted_at) { nil }

    subject do
      described_class.call(
        current_user: current_user,
        params: {
          coin_bank_transaction: {
            user_id: user_id,
            from_currency_id: from_currency_id,
            to_currency_id: to_currency_id,
            from_amount: from_amount,
            to_amount: to_amount,
            fee_amount: fee_amount,
            transacted_at: transacted_at
          }
        }
      )
    end

    context "if user_id is not present" do
      it "returns an error message wrapped in a Failure monad" do
        expect(subject).not_to be_success
        expect(subject.failure).to eq("Please specify a user.")
      end
    end

    context "if user_id does not exist" do
      let(:user_id) { 999_999 }

      it "returns an error message wrapped in a Failure monad" do
        expect(subject).not_to be_success
        expect(subject.failure).to eq("Please specify a user.")
      end
    end

    context "if user_id exists" do
      let(:user) { create(:user) }
      let(:user_id) { user.id }

      context "if from_amount is nil" do
        it "returns an error message wrapped in a Failure monad" do
          expect(subject).not_to be_success
          expect(subject.failure).to eq("Please specify an amount to withdraw from the 'From Balance'.")
        end
      end

      context "if to_amount is nil" do
        let(:from_amount) { 0 }

        it "returns an error message wrapped in a Failure monad" do
          expect(subject).not_to be_success
          expect(subject.failure).to eq("Please specify an amount to add to the 'To Balance'.")
        end
      end

      context "if from_amount and to_amount are both zero" do
        let(:from_amount) { 0 }
        let(:to_amount) { 0 }

        it "returns an error message wrapped in a Failure monad" do
          expect(subject).not_to be_success
          expect(subject.failure).to eq(
            "A transaction must have an amount to add or subtract from one balance or another."
          )
        end
      end

      context "if from_amount and to_amount are not both zero" do
        let(:from_currency) { create(:currency, fiat: true) }
        let(:to_currency) { create(:currency) }
        let(:from_amount) { 10 }
        let(:to_amount) { 20 }

        context "if from_currency_id is blank" do
          it "returns an error message wrapped in a Failure monad" do
            expect(subject).not_to be_success
            expect(subject.failure).to eq('Please specify a "From" currency.')
          end
        end

        context "if from_currency_id does not exist" do
          let(:from_currency_id) { 999_999_999 }

          it "returns an error message wrapped in a Failure monad" do
            expect(subject).not_to be_success
            expect(subject.failure).to eq('Please specify a "From" currency.')
          end
        end

        context "if to_currency_id is blank" do
          let(:from_currency_id) { from_currency.id }

          it "returns an error message wrapped in a Failure monad" do
            expect(subject).not_to be_success
            expect(subject.failure).to eq('Please specify a "To" currency.')
          end
        end

        context "if to_currency_id does not exist" do
          let(:from_currency_id) { from_currency.id }
          let(:to_currency_id) { 999_888_777 }

          it "returns an error message wrapped in a Failure monad" do
            expect(subject).not_to be_success
            expect(subject.failure).to eq('Please specify a "To" currency.')
          end
        end

        context "if neither from_currency_id nor to_currency_id are blank" do
          let(:from_currency_id) { from_currency.id }
          let(:to_currency_id) { to_currency.id }

          context "if user already has a balance for the from_currency" do
            let(:from_amount) { 5 }
            let!(:from_before_balance) { create(:balance, user: user, currency: from_currency, amount: 11.23) }

            it "relates to the existing balance and subtracts the from_amount to its total" do
              expect { subject }.to change { user.balances.where(currency: from_currency).count }.from(1).to(2)
              expect(subject).to be_success

              transaction = subject.value!
              expect(transaction.from_before_balance).to eq(from_before_balance)
              expect(transaction.from_amount).to eq(5)
              expect(transaction.exchange_rate).to eq(4)

              from_after_balance = transaction.from_after_balance
              expect(from_after_balance.currency).to eq(from_currency)
              expect(from_after_balance.amount).to eq(6.23)
            end
          end

          context "if user does not already have a balance for the from_currency" do
            it "creates a zero-amount balance and relates to it" do
              expect { subject }.to change { user.balances.where(currency: from_currency).count }.from(0).to(2)
              expect(subject).to be_success
              transaction = subject.value!

              from_before_balance = transaction.from_before_balance
              expect(from_before_balance.currency).to eq(from_currency)
              expect(from_before_balance.amount).to eq(0)

              expect(transaction.from_amount).to eq(10)
              expect(transaction.exchange_rate).to eq(2)

              from_after_balance = transaction.from_after_balance
              expect(from_after_balance.currency).to eq(from_currency)
              expect(from_after_balance.amount).to eq(-10)
            end
          end

          context "if user already has a balance for the to_currency" do
            let(:to_amount) { 2 }
            let!(:to_before_balance) { create(:balance, user: user, currency: to_currency, amount: 40.23) }

            it "relates to the existing balance and adds to its amount" do
              expect { subject }.to change { user.balances.where(currency: to_currency).count }.from(1).to(2)
              expect(subject).to be_success

              transaction = subject.value!
              expect(transaction.to_before_balance).to eq(to_before_balance)
              expect(transaction.to_amount).to eq(2)
              expect(transaction.exchange_rate).to eq(0.2)

              to_after_balance = transaction.to_after_balance
              expect(to_after_balance.currency).to eq(to_currency)
              expect(to_after_balance.amount).to eq(42.23)
            end
          end

          context "if user does not already have a balance for the to_currency" do
            let(:to_amount) { 100 }

            it "creates a zero-amount balance and relates to it" do
              expect { subject }.to change { user.balances.where(currency: to_currency).count }.from(0).to(2)
              expect(subject).to be_success
              transaction = subject.value!

              to_before_balance = transaction.to_before_balance
              expect(to_before_balance.currency).to eq(to_currency)
              expect(to_before_balance.amount).to eq(0)

              expect(transaction.to_amount).to eq(100)
              expect(transaction.exchange_rate).to eq(10)

              to_after_balance = transaction.to_after_balance
              expect(to_after_balance.currency).to eq(to_currency)
              expect(to_after_balance.amount).to eq(100)
            end
          end

          context "if current_user is provided" do
            let(:current_user) { create(:user) }
            let(:user_id) { nil }

            it "uses the current_user instead of the user_id in the params" do
              expect { subject }.to change { current_user.balances.count }.from(0).to(4)
              transaction = CoinBank::Transaction.last
              expect(transaction.user).to eq(current_user)
            end
          end

          context "if current_user is not provided" do
            it "uses the current_user instead of the user_id in the params" do
              expect { subject }.to change { user.balances.count }.from(0).to(4)
              transaction = CoinBank::Transaction.last
              expect(transaction.user).to eq(user)
            end
          end

          context "if fee_amount is provided" do
            let(:fee_amount) { 22.55 }

            it "saves the fee_amount to the transaction" do
              expect(subject).to be_success
              transaction = subject.value!
              expect(transaction.fee_amount).to eq(22.55)
            end
          end

          context "if free_amount is not provided" do
            it "saves zero as the fee_amount to the transaction" do
              expect(subject).to be_success
              transaction = subject.value!
              expect(transaction.fee_amount).to be_zero
            end
          end

          context "if transacted_at is provided" do
            let(:transacted_at) { 2.days.ago }

            it "saves given transacted_at to the transaction" do
              expect(subject).to be_success
              transaction = subject.value!
              expect(transaction.transacted_at).to be_within(3.seconds).of(transacted_at)
            end
          end

          context "if transacted_at is not provided" do
            it "saves Time.zone.now as the transacted_at to the transaction" do
              expect(subject).to be_success
              transaction = subject.value!
              expect(transaction.transacted_at).to be_within(3.seconds).of(Time.zone.now)
            end
          end
        end
      end
    end
  end
end
