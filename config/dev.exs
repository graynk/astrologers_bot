import Config

config :astrologers_bot, work_mode: :polling

config :telegex, caller_adapter: {Finch, [receive_timeout: 15 * 1000]}

import_config "dev.secret.exs"
