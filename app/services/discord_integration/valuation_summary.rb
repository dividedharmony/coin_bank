# frozen_string_literal: true

require 'discordrb'

module DiscordIntegration
  class ValuationSummary
    class << self
      def formatted_message
        <<~TEXT
          Report date: _#{Time.now.strftime("%H:%M %B %d, %Y")}_
          #{formatted_stats}
          -- _integration version: 2022-02-26_ --
        TEXT
      end

      private

      def formatted_stats
        ValuationStatus.all.map do |valuation_status|
          alert = valuation_status.alert? ? '**ALERT**' : '.....'
          "#{alert} #{valuation_status.currency_symbol} - #{valuation_status.percent_of_target}   (#{valuation_status.actual_value}/#{valuation_status.target_value})"
        end.join("\n")
      end
    end
  end
end
