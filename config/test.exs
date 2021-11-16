import Config

config :ascii_sketch, AsciiSketch.Canvas,
  width: 5,
  height: 5,
  empty_character: '+'

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :ascii_sketch, AsciiSketch.Repo,
  username: "sketch",
  password: "sketch",
  database: "ascii_sketch_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ascii_sketch, AsciiSketchWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "fHjGogEE9t3+TfVGhymTNwWi01N8i2HgwYsI8uTGouc3/h4+ulEe1t3oNpNo4Qzb",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
