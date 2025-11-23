import Config

if config_env() == :prod do
  config :telegex, token: System.get_env("ASTROLOGERS_BOT_TOKEN")

  config :astrologers_bot, archive_id: System.get_env("ASTROLOGERS_PRIVATE_CHANNEL")
end
