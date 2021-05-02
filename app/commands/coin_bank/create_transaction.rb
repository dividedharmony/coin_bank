# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module CoinBank
  class CreateTransaction
    class << self
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      def call(current_user: nil, params:)
        if current_user
          user = current_user
        else
          user = yield get_user(params.dig(:coin_bank_transaction, :user_id))
        end
        from_amount, to_amount = yield get_amounts_to_change(params)
        from_currency, to_currency = yield get_currencies(params)
        fee_amount = params.dig(:coin_bank_transaction, :fee_amount) || 0
        exchange_rate = yield calculate_exchange_rate(from_amount, to_amount)
        from_before_balance = yield get_before_balance(
          user, 
          from_currency
        )
        to_before_balance = yield get_before_balance(
          user, 
          to_currency
        )
        from_after_balance = yield create_after_balance(
          user,
          from_before_balance,
          from_amount,
          addition: false
        )
        to_after_balance = yield create_after_balance(
          user,
          to_before_balance,
          to_amount,
          addition: true
        )
        transacted_at = params.dig(:coin_bank_transaction, :transacted_at) || Time.zone.now
        new_transaction = CoinBank::Transaction.new(
          user: user,
          from_before_balance: from_before_balance,
          from_after_balance: from_after_balance,
          to_before_balance: to_before_balance,
          to_after_balance: to_after_balance,
          from_amount: from_amount,
          to_amount: to_amount,
          exchange_rate: exchange_rate,
          fee_amount: fee_amount,
          transacted_at: transacted_at
        )
        if new_transaction.save
          Success(new_transaction)
        else
          Failure(new_transaction.errors.full_messages.join("\n"))
        end
      end

      private

      def get_user(user_id)
        user = CoinBank::User.find_by(id: user_id)
        if user.nil?
          Failure("Please specify a user.")
        else
          Success(user)
        end
      end

      def get_amounts_to_change(params)
        from_amount = params.dig(:coin_bank_transaction, :from_amount)
        to_amount = params.dig(:coin_bank_transaction, :to_amount)
        if from_amount.nil?
          Failure("Please specify an amount to withdraw from the 'From Balance'.")
        elsif to_amount.nil?
          Failure("Please specify an amount to add to the 'To Balance'.")
        elsif from_amount.zero? && to_amount.zero?
          Failure("A transaction must have an amount to add or subtract from one balance or another.")
        else
          Success([from_amount, to_amount])
        end
      end

      def calculate_exchange_rate(from_amount, to_amount)
        return Success(0) if from_amount.zero?
        Success(to_amount.to_d / from_amount.to_d)
      end

      def get_currencies(params)
        from_currency_id = params.dig(:coin_bank_transaction, :from_currency_id)
        to_currency_id = params.dig(:coin_bank_transaction, :to_currency_id)
        from_currency = CoinBank::Currency.find_by(id: from_currency_id)
        to_currency = CoinBank::Currency.find_by(id: to_currency_id)
        if from_currency.nil?
          Failure('Please specify a "From" currency.')
        elsif to_currency.nil?
          Failure('Please specify a "To" currency.')
        else
          Success([from_currency, to_currency])
        end
      end

      def get_before_balance(user, currency)
        balance = user.current_balances.find_by(currency: currency) ||
          CoinBank::Balance.new(user: user, currency: currency, amount: 0)
        if balance.persisted? || balance.save
          Success(balance)
        else
          Failure(balance.errors.full_messages.join("\n"))
        end
      end

      def create_after_balance(user, before_balance, abs_amount_to_change, addition:)
        amount_to_change = addition ? abs_amount_to_change : -abs_amount_to_change
        amount = before_balance.amount + amount_to_change
        new_balance = CoinBank::Balance.new(
          user: user,
          currency: before_balance.currency,
          amount: amount
        )
        if new_balance.save
          Success(new_balance)
        else
          Failure(new_balance.errors.full_messages.join("\n"))
        end
      end
    end
  end
end
