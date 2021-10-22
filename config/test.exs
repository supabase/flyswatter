import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :fly_swatter, FlySwatterWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "h0JEC/bJThFXI3yc3T5leLIvisF4+h+fhsV93M0OMSR3ktO6Cn8F5ilTh2gX/P7B",
  server: false

# In test we don't send emails.
config :fly_swatter, FlySwatter.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
