import Config

config :devvy, DevvyWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: String.to_integer(System.get_env("PORT") || "3000")],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "2oephZc5WJz1pPQns+hRpw6x0O2UzQxI2fF+WYIzr6+xhLe/JugP28nYUfjpg7jY",
  watchers: []

# Watch static, templates, AND sites/ directory for live reload
config :devvy, DevvyWeb.Endpoint,
  live_reload: [
    web_console_logger: true,
    patterns: [
      ~r"sites/.*(liquid|json)$",
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/devvy_web/(controllers|components)/.*(ex|heex)$"
    ]
  ]

config :devvy, dev_routes: true

config :logger, :default_formatter, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime
