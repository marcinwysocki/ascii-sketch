defmodule AsciiSketch.Canvas.Validations do
  import Ecto.Changeset

  def validate_coordinates(%Ecto.Changeset{} = changeset, key, opts \\ []) do
    changeset = validate_number(changeset, key, greater_than_or_equal_to: 0)

    case opts do
      [] ->
        changeset

      [canvas_axis: {axis, canvas}] ->
        coordinate = get_change(changeset, key)

        if out_of_bounds?(canvas, coordinate, axis) do
          add_error(changeset, key, "out of bounds on axis %{axis}", axis: axis)
        else
          changeset
        end
    end
  end

  defp out_of_bounds?(canvas, coodrdinate, axis) do
    dimension =
      case axis do
        :x -> canvas.width
        :y -> canvas.height
        _ -> :error
      end

    out_of_bounds?(dimension, coodrdinate)
  end

  defp out_of_bounds?(:error, _), do: true
  defp out_of_bounds?(dimension, coordinate) when coordinate > dimension, do: true
  defp out_of_bounds?(_, _), do: false

  def validate_character(%Ecto.Changeset{} = changeset, key) do
    character = get_change(changeset, key)

    cond do
      not is_list(character) ->
        add_error(changeset, key, "must be a charlist")

      length(character) != 1 ->
        add_error(changeset, key, "must be a single character")

      not List.ascii_printable?(character) ->
        add_error(changeset, key, "must be ASCII printable")

      true ->
        changeset
    end
  end
end
