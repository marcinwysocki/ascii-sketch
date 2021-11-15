defmodule AsciiSketch.Canvas do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "canvases" do
    field :canvas, :string
    field :lines, {:array, {:array, :integer}}, virtual: true

    timestamps()
  end

  def new do
    config = Application.get_env(:ascii_sketch, __MODULE__)
    lines = make_empty_lines(config[:width], config[:height], config[:empty_character])

    case changeset(%{lines: lines}) do
      %Ecto.Changeset{valid?: true} = changes -> apply_changes(changes)
      %Ecto.Changeset{errors: errors} -> {:error, errors}
    end
  end

  @doc false
  def changeset(canvas \\ %__MODULE__{}, attrs) do
    canvas
    |> cast(attrs, [:canvas, :lines])
    |> maybe_serialize()
    |> validate_required([:canvas, :lines])
  end

  defp maybe_serialize(%Ecto.Changeset{valid?: true, changes: %{canvas: _}} = changeset),
    do: changeset

  defp maybe_serialize(%Ecto.Changeset{valid?: true, changes: %{lines: lines}} = changeset) do
    canvas = Enum.join(lines, "\n")

    put_change(changeset, :canvas, canvas)
  end

  defp maybe_serialize(changeset), do: changeset

  defp make_empty_lines(width, height, character) do
    for _ <- 1..height do
      make_empty_line(width, character)
    end
  end

  defp make_empty_line(width, character) do
    Enum.reduce(1..width, '', fn _, acc -> acc ++ character end)
  end
end
