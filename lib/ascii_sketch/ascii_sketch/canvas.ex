defmodule AsciiSketch.Canvas do
  use Ecto.Schema
  import Ecto.Changeset

  alias AsciiSketch.Canvas.Change
  alias AsciiSketch.Canvas.Validations

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "canvases" do
    field :canvas, :string
    field :width, :integer
    field :height, :integer
    field :lines, {:array, {:array, :integer}}, virtual: true
    field :empty_character, {:array, :integer}, virtual: true

    timestamps()
  end

  def new(opts) do
    config =
      :ascii_sketch
      |> Application.get_env(__MODULE__)
      |> Keyword.merge(opts)
      |> Enum.into(%{})

    %__MODULE__{}
    |> cast(config, [:canvas, :width, :height, :empty_character])
    |> Validations.validate_coordinates(:height)
    |> Validations.validate_coordinates(:width)
    |> Validations.validate_character(:empty_character)
    |> make_empty_lines()
    |> serialize_lines()
    |> validate_required([:lines, :width, :height])
  end

  def apply_change(%__MODULE__{lines: lines} = canvas, change) do
    new_lines = Change.apply(change, lines)

    canvas
    |> cast(%{lines: new_lines}, [:lines])
    |> serialize_lines()
  end

  def deserialize(%__MODULE__{canvas: canvas_string} = canvas) do
    lines =
      canvas_string
      |> String.split("\n")
      |> Enum.map(&String.to_charlist/1)

    Map.put(canvas, :lines, lines)
  end

  defp serialize_lines(%Ecto.Changeset{valid?: true, changes: %{lines: lines}} = changeset) do
    canvas = Enum.join(lines, "\n")

    put_change(changeset, :canvas, canvas)
  end

  defp serialize_lines(changeset), do: changeset

  defp make_empty_lines(
         %Ecto.Changeset{
           valid?: true,
           changes: %{width: width, height: height, empty_character: character}
         } = changeset
       ) do
    lines = for _ <- 1..height, do: make_empty_line(width, character)

    put_change(changeset, :lines, lines)
  end

  defp make_empty_lines(changeset), do: changeset

  defp make_empty_line(width, character) do
    Enum.reduce(1..width, '', fn _, acc -> acc ++ character end)
  end

  defimpl String.Chars do
    def to_string(%AsciiSketch.Canvas{canvas: canvas}), do: canvas
  end

  defimpl Jason.Encoder do
    def encode(
          %AsciiSketch.Canvas{} = canvas,
          opts
        ) do
      canvas
      |> Map.from_struct()
      |> Map.drop([:__meta__, :lines, :empty_character])
      |> Jason.Encode.map(opts)
    end
  end
end
