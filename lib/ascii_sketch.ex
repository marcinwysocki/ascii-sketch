defmodule AsciiSketch do
  @moduledoc """
  AsciiSketch keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias AsciiSketch.Canvas
  alias AsciiSketch.Canvas.Rectangle
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

  @spec draw_rectangle(binary(), map()) ::
          {:ok, Canvas, map()} | {:error, Changeset, map()} | {:error, term(), map()}
  def draw_rectangle(canvas_id, rectangle_params) do
    {time, result} =
      :timer.tc(fn ->
        with canvas when not is_nil(canvas) <- get(canvas_id),
             %Changeset{valid?: true} = rect_changeset <-
               Rectangle.changeset(rectangle_params, canvas),
             %Rectangle{} = rectangle <- Changeset.apply_changes(rect_changeset),
             updated_canvas <- Canvas.apply_change(canvas, rectangle) do
          Repo.update(updated_canvas, returning: [:updated_at])
        else
          nil -> {:error, :canvas_not_found}
          %Changeset{valid?: false} = changeset -> {:error, changeset}
          error -> error
        end
      end)

    Tuple.append(result, %{time_ms: :erlang.convert_time_unit(time, :microsecond, :millisecond)})
  end
end
