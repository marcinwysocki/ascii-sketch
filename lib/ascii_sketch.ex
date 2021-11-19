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

  @doc """
  Creates an empty canvas.

  It's possible to override the default `width`, `height` and `empty_character`
  by passing them through `opts`. Values from config will be used otherwise.
  """
  @spec create(opts :: keyword()) :: {:ok, %Canvas{}} | {:error, %Ecto.Changeset{}}
  def create(opts \\ []) do
    opts
    |> Canvas.new()
    |> Repo.insert()
  end

  @doc """
  Returns a canvas by id
  """
  @spec get(id :: String.t()) :: nil | {:error, :id_not_binary} | %Canvas{}
  def get(id) when is_binary(id) do
    case Repo.get(Canvas, id) do
      nil -> nil
      canvas -> Canvas.deserialize(canvas)
    end
  end

  def get(_), do: {:error, :id_not_binary}

  @doc """
  Adds a drawing to the canvas.

  `change_validator` must be a change module implementing both `AsciiSketch.Canvas.Change.Validator` behaviour
  and `AsciiSketch.Canvas.Change` protocol.

  `params` must conform to `change_validator` module's structure and validations.

  In case of success, a `:drawing_applied` event will be broadcasted to a `canvas:<canvas_id>` topic.
  """
  @spec draw(canvas_id :: String.t(), change_validator :: module(), params :: %{atom() => any()}) ::
          {:ok, %Canvas{}, %{time_ms: pos_integer()}} | {:error, any(), %{time_ms: pos_integer()}}
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
