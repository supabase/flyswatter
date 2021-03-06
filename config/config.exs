# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :fly_swatter, FlySwatterWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: FlySwatterWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: FlySwatter.PubSub,
  live_view: [signing_salt: "iL7NsAlS"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :fly_swatter, FlySwatter.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :tesla, :adapter, {Tesla.Adapter.Finch, name: FlySwatter.Finch, receive_timeout: 60_000}

config :fly_swatter, FlySwatter.LogflareClient,
  api_key: System.get_env("FS_LOGFLARE_API_KEY", "not_found"),
  source: System.get_env("FS_LOGFLARE_SOURCE", "not_found"),
  supabase_projects_endpoint_id: System.get_env("FS_LOGFLARE_ENDPOINT", "not_found")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
