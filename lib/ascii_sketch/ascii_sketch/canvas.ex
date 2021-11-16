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

  def new_changeset(opts) do
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
    |> maybe_serialize()
    |> validate_required([:lines, :width, :height])
  end

  def apply_change(%__MODULE__{lines: lines}, change) do
    Change.apply(change, lines)
  end

  defp maybe_serialize(%Ecto.Changeset{valid?: true, changes: %{canvas: _}} = changeset),
    do: changeset

  defp maybe_serialize(%Ecto.Changeset{valid?: true, changes: %{lines: lines}} = changeset) do
    canvas = Enum.join(lines, "\n")

    put_change(changeset, :canvas, canvas)
  end

  defp maybe_serialize(changeset), do: changeset

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
end
