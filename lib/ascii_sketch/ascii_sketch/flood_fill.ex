defmodule AsciiSketch.Canvas.FloodFill do
  @moduledoc false

  import Ecto.Changeset

  alias AsciiSketch.Canvas
  alias AsciiSketch.Canvas.Validations

  @behaviour Canvas.Change.Validator

  defstruct [:x, :y, :character]

  @types %{
    x: :integer,
    y: :integer,
    character: {:array, :integer}
  }
  @required Map.keys(@types)

  @impl true
  def changeset(params, %Canvas{} = canvas) do
    {%__MODULE__{}, @types}
    |> cast(params, @required)
    |> Validations.validate_coordinates(:x, canvas_axis: {:x, canvas})
    |> Validations.validate_coordinates(:y, canvas_axis: {:y, canvas})
    |> Validations.validate_character(:character)
    |> validate_required(@required)
  end
end
