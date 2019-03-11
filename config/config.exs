# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :die_scheite_api, DieScheiteApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9LAAOCr7mG78WRIJme9z1Gg7GAR39krbEcZJEsMbM5IOiENXCXoxwmakAb6nRO61",
  render_errors: [view: DieScheiteApiWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: DieScheiteApi.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time [$level] $message\n",
  metadata: []

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
