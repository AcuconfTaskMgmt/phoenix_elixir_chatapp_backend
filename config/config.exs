# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :chat_service,
  ecto_repos: [ChatService.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :chat_service, ChatServiceWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: ChatServiceWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: ChatService.PubSub,
  live_view: [signing_salt: "Kw7vr2Yv"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :chat_service, ChatServiceWeb.Auth.Guardian,
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "chat_service",
  verify_issuer: true,
  secret_key:
    System.get_env("GUARDIAN_SECRET") ||
      "06Aj3u80SLZm7aDBWz/NDmAMrJDBQU2NiaInqvO5jBiv+L4rksU/8V5J8B9S3q3Q"

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Use swagger configuration
config :chat_service, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      router: ChatServiceWeb.Router,
      endpoint: ChatServiceWeb.Endpoint
    ]
  }

config :phoenix_swagger, json_library: Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

config :elixir, :time_zone_database, Tz.TimeZoneDatabase
