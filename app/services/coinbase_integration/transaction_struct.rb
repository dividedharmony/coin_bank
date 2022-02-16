# frozen_string_literal: true

module CoinbaseIntegration
  class TransactionStruct
    class UnknownTransactionType < StandardError
      def initialize(transaction_type)
        super("Unidentified transaction type #{transaction_type.inspect}")
      end
    end

    BUY_TYPE = 'buy'
    SELL_TYPE = 'sell'
    REWARD_TYPES = %w{send interest inflation_reward}.freeze

    def initialize(raw_transaction)
      @raw_transaction = raw_transaction
      @coinbase_uuid = raw_transaction.fetch('id')
      @type = raw_transaction.fetch('type')
      @amount_data = raw_transaction.fetch('amount')
      @native_amount_data = raw_transaction.fetch('native_amount')
      @amount_value = amount_data.fetch('amount').to_d
      @amount_currency_sym = amount_data.fetch('currency')
      @native_value = native_amount_data.fetch('amount').to_d
      @native_currency_sym = native_amount_data.fetch('currency')
      @transacted_at = raw_transaction.fetch('created_at').to_datetime
    end

    attr_reader :raw_transaction,
                :coinbase_uuid,
                :type,
                :amount_data,
                :native_amount_data,
                :amount_value,
                :amount_currency_sym,
                :native_value,
                :native_currency_sym,
                :transacted_at

    def from_currency_symbol
      case type
      when BUY_TYPE
        native_currency_sym
      when *REWARD_TYPES
        CoinBank::Currency::REWARDS_SYMBOL
      when SELL_TYPE
        amount_currency_sym
      else
        raise UnknownTransactionType, type
      end
    end

    def to_currency_symbol
      case type
      when *REWARD_TYPES, BUY_TYPE
        amount_currency_sym
      when SELL_TYPE
        native_currency_sym
      else
        raise UnknownTransactionType, type
      end
    end

    # opposite logic to +to_amount+
    def from_amount
      from_non_native? ? amount_value : native_value
    end

    # opposite logic to +from_amount+
    def to_amount
      from_non_native? ? native_value : amount_value
    end

    def exchange_rate
      return BigDecimal(0) if from_amount.zero?
      to_amount / from_amount
    end

    private

    def from_non_native?
      type == SELL_TYPE
    end
  end
end
