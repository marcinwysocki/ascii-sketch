defmodule AsciiSketch.Repo do
  use Ecto.Repo,
    otp_app: :ascii_sketch,
    adapter: Ecto.Adapters.Postgres
end
