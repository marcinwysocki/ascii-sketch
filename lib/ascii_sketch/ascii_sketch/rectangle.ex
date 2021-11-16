defmodule AsciiSketch.Canvas.Rectangle do
  @moduledoc false

  import Ecto.Changeset

  alias AsciiSketch.Canvas
  alias AsciiSketch.Canvas.Validations

  defstruct [:x, :y, :width, :height, :fill, :outline]

  @types %{
    x: :integer,
    y: :integer,
    height: :integer,
    width: :integer,
    fill: {:array, :integer},
    outline: {:array, :integer}
  }
  @required Map.keys(@types)

  def changeset(params, %Canvas{} = canvas) do
    {%__MODULE__{}, @types}
    |> cast(params, @required)
    |> Validations.validate_character(:fill)
    |> Validations.validate_character(:outline)
    |> Validations.validate_coordinates(:x, canvas_axis: {:x, canvas})
    |> Validations.validate_coordinates(:y, canvas_axis: {:y, canvas})
    |> validate_required(@required)
  end

  defimpl AsciiSketch.Canvas.Change do
    alias AsciiSketch.Canvas.Rectangle

    def apply(%Rectangle{} = rect, lines) do
      {head, modified} = Enum.split(lines, rect.y)
      {modified, tail} = Enum.split(modified, rect.height)

      {head, modified, tail}

      {first_line, rest} = List.pop_at(modified, 0)
      {last_line, body} = List.pop_at(rest, length(rest) - 1)

      head ++
        make_outline(first_line, rect.outline, rect.width, rect.x) ++
        make_body(body, rect.outline, rect.fill, rect.width, rect.x) ++
        make_outline(last_line, rect.outline, rect.width, rect.x) ++ tail
    end

    defp make_outline(line, nil, _, _), do: [line]

    defp make_outline(line, char, width, x) do
      with {head, drawing, tail} <- split_line(line, width, x),
           outline <- Enum.map(drawing, fn _ -> char end) do
        [List.to_charlist(head ++ outline ++ tail)]
      end
    end

    defp make_body(body, outline, fill, width, x) do
      for line <- body do
        with {head, drawing, tail} <- split_line(line, width, x),
             right_outline_char_index <- length(drawing) - 1,
             drawed_line <- draw_body_line(drawing, outline, fill, right_outline_char_index) do
          List.to_charlist(head ++ drawed_line ++ tail)
        end
      end
    end

    defp draw_body_line(drawing, outline, fill, right_outline_char_index) do
      [
        Enum.with_index(
          drawing,
          &do_draw_body_line(&1, &2, outline, fill, right_outline_char_index)
        )
      ]
    end

    defp do_draw_body_line(prev, 0, outline, _, _), do: maybe_draw(outline, prev)
    defp do_draw_body_line(prev, idx, outline, _, idx), do: maybe_draw(outline, prev)
    defp do_draw_body_line(prev, _, _, fill, _), do: maybe_draw(fill, prev)

    defp maybe_draw(char, _) when not is_nil(char), do: char
    defp maybe_draw(_, prev), do: prev

    defp split_line(line, width, x) do
      with {head, rest} <- Enum.split(line, x),
           {drawing, tail} <- Enum.split(rest, width) do
        {head, drawing, tail}
      end
    end
  end
end
