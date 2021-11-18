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

  defimpl Canvas.Change do
    alias AsciiSketch.Canvas.FloodFill

    def apply(%FloodFill{character: [char_code], x: x, y: y} = fill, lines) do
      starting_char =
        lines
        |> Enum.fetch!(fill.y)
        |> Enum.fetch!(fill.x)

      height = length(lines)
      width = length(List.first(lines))

      starting_point = %{x: x, y: y}

      canvas = %{
        lines: lines,
        out_of_bounds?: fn
          %{x: x, y: y} when x >= 0 and y >= 0 -> x > width - 1 or y > height - 1
          _ -> true
        end
      }

      case flood_fill(canvas, starting_point, starting_char, char_code) do
        %{lines: lines} -> lines
        err -> err
      end
    end

    def flood_fill(canvas, starting_point, starting_char, fill_char) do
      unless canvas.out_of_bounds?.(starting_point) do
        with row <- Enum.fetch!(canvas.lines, starting_point.y),
             {:replaced, new_line} <-
               maybe_replace(row, starting_point.x, starting_char, fill_char),
             new_lines <- List.replace_at(canvas.lines, starting_point.y, new_line),
             new_canvas <- %{canvas | lines: new_lines} do
          new_canvas
          |> flood_fill(north(starting_point), starting_char, fill_char)
          |> flood_fill(north_east(starting_point), starting_char, fill_char)
          |> flood_fill(east(starting_point), starting_char, fill_char)
          |> flood_fill(south_east(starting_point), starting_char, fill_char)
          |> flood_fill(south(starting_point), starting_char, fill_char)
          |> flood_fill(south_west(starting_point), starting_char, fill_char)
          |> flood_fill(west(starting_point), starting_char, fill_char)
          |> flood_fill(north_west(starting_point), starting_char, fill_char)
        else
          {:skipped, _line} -> canvas
        end
      else
        canvas
      end
    end

    defp maybe_replace(line, x, starting_char, fill_char) do
      case Enum.fetch!(line, x) do
        ^starting_char -> {:replaced, List.replace_at(line, x, fill_char)}
        _ -> {:skipped, line}
      end
    end

    defp north(%{x: x, y: y}), do: %{x: x, y: y - 1}
    defp north_east(%{x: x, y: y}), do: %{x: x + 1, y: y - 1}
    defp east(%{x: x, y: y}), do: %{x: x + 1, y: y}
    defp south_east(%{x: x, y: y}), do: %{x: x + 1, y: y + 1}
    defp south(%{x: x, y: y}), do: %{x: x, y: y + 1}
    defp south_west(%{x: x, y: y}), do: %{x: x - 1, y: y + 1}
    defp west(%{x: x, y: y}), do: %{x: x - 1, y: y}
    defp north_west(%{x: x, y: y}), do: %{x: x - 1, y: y - 1}
  end
end
