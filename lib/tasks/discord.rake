# frozen_string_literal: true

namespace :discord do
  task post_holding_valuations: :environment do
    require 'discordrb'

    bot = Discordrb::Commands::CommandBot.new(
      token: ENV.fetch('DISCORD_TOKEN')
    )
    channel_id = ENV.fetch('DISCORD_CHANNEL_ID')
    bot.send_message(channel_id, DiscordIntegration::ValuationStatus.new.formatted_message)
  end
end
