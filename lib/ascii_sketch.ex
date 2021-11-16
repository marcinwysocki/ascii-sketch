defmodule AsciiSketch do
  @moduledoc """
  AsciiSketch keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias AsciiSketch.Canvas
  alias AsciiSketch.Repo

  def create(opts \\ []) do
    opts
    |> Canvas.new_changeset()
    |> Repo.insert()
  end

  def get(id) when is_binary(id) do
    Repo.get(Canvas, id)
  end

  def get(_), do: {:error, :id_not_binary}
end
