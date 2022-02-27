# frozen_string_literal: true

module DiscordIntegration
  class ValuationAlert
    def initialize(alert_threshold)
      @alert_threshold = alert_threshold
    end

    def formatted_messages
      valuation_statuses.map do |val_stat|
        "**#{val_stat.currency_symbol}** - #{val_stat.percent_of_target} --- $#{val_stat.actual_value}/$#{val_stat.target_value}"
      end
    end

    private

    attr_reader :alert_threshold

    def valuation_statuses
      ValuationStatus.all.select do |valuation_status|
        valuation_status.percent_of_target >= alert_threshold
      end
    end
  end
end
