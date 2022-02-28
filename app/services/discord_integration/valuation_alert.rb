# frozen_string_literal: true

module DiscordIntegration
  class ValuationAlert
    class << self
      def formatted_messages
        valuation_statuses.map do |val_stat|
          "**#{val_stat.currency_symbol}** - #{val_stat.percent_of_target}/#{val_stat.alert_threshold} --- ($#{val_stat.actual_value}/$#{val_stat.target_value})"
        end
      end

      private

      attr_reader :alert_threshold

      def valuation_statuses
        ValuationStatus.all.select(&:alert?)
      end
    end
  end
end
