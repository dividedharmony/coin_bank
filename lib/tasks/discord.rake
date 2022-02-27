# frozen_string_literal: true

namespace :discord do
  desc 'A general valuation summary of all holdings with target values'
  task post_holding_valuations: :environment do
    require 'discordrb'

    bot = Discordrb::Commands::CommandBot.new(
      token: ENV.fetch('DISCORD_TOKEN')
    )
    channel_id = ENV.fetch('DISCORD_CHANNEL_ID')
    bot.send_message(channel_id, DiscordIntegration::ValuationSummary.formatted_message)
  end

  desc 'Posts an alert if any valuations have exceeded a 0.93 valuation threshold'
  task alert_high_valuations: :environment do
    require 'discordrb'

    high_value_threshold = 0.92

    bot = Discordrb::Commands::CommandBot.new(
      token: ENV.fetch('DISCORD_TOKEN')
    )
    channel_id = ENV.fetch('DISCORD_CHANNEL_ID')
    developer_id = ENV.fetch('DEVELOPER_ID')

    messages = DiscordIntegration::ValuationAlert
      .new(high_value_threshold)
      .formatted_messages

    if messages.any?
      currency_string = messages.count == 1 ? 'currency' : 'currencies'
      combined_message = <<~TEXT
        <@#{developer_id}> ALERT **#{messages.count} #{currency_string}** have exceeded the #{high_value_threshold} threshold.
        #{messages.join("\n")}
      TEXT
      bot.send_message(channel_id, combined_message)
    end
  end
end
