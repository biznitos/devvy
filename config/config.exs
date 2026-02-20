import Config

config :devvy,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :devvy, DevvyWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: DevvyWeb.ErrorHTML, json: DevvyWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Devvy.PubSub,
  live_view: [signing_salt: "dn46qgtJ"]

# Register custom Liquid tags and filters
config :liquid,
  extra_filter_modules: [Devvy.Liquid.Filters],
  extra_tags: %{
    types: {Devvy.Liquid.Tags.TypesTag, Liquid.Tag},
    posts: {Devvy.Liquid.Tags.PostsTag, Liquid.Tag},
    partial: {Devvy.Liquid.Tags.PartialTag, Liquid.Tag},
    leads: {Devvy.Liquid.Tags.LeadsTag, Liquid.Tag},
    users: {Devvy.Liquid.Tags.UsersTag, Liquid.Tag},
    runner: {Devvy.Liquid.Tags.RunnerTag, Liquid.Tag}
  }

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config.
import_config "#{config_env()}.exs"
