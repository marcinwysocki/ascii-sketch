defmodule AsciiSketch do
  @moduledoc """
  AsciiSketch keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias AsciiSketch.Canvas
  alias AsciiSketch.Canvas.Change
  alias AsciiSketch.Repo
  alias Ecto.Changeset

  def create(opts \\ []) do
    opts
    |> Canvas.new()
    |> Repo.insert()
  end

  def get(id) when is_binary(id) do
    case Repo.get(Canvas, id) do
      nil -> nil
      canvas -> Canvas.deserialize(canvas)
    end
  end

  def get(_), do: {:error, :id_not_binary}

  def draw(canvas_id, change_validator, params) do
    {time, result} =
      :timer.tc(fn ->
        with canvas when not is_nil(canvas) <- get(canvas_id),
             %Changeset{valid?: true} = changeset <-
               Change.Validator.changeset(change_validator, params, canvas),
             change <- Changeset.apply_changes(changeset),
             updated_canvas <- Canvas.apply_change(canvas, change) do
          Repo.update(updated_canvas, returning: [:updated_at])
        else
          nil -> {:error, :canvas_not_found}
          %Changeset{valid?: false} = changeset -> {:error, changeset}
          error -> error
        end
      end)

    result
    |> Tuple.append(%{time_ms: :erlang.convert_time_unit(time, :microsecond, :millisecond)})
    |> maybe_broadcast_event()
  end

  defp maybe_broadcast_event({:ok, canvas, meta} = result) do
    Phoenix.PubSub.broadcast(
      AsciiSketch.PubSub,
      "canvas:#{canvas.id}",
      {:drawing_applied, %{canvas: canvas, meta: meta}}
    )

    result
  end

  defp maybe_broadcast_event(result), do: result
end
