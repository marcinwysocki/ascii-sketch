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
  @required Map.keys(@types) -- [:fill, :outline]

  def changeset(params, %Canvas{} = canvas) do
    with rectangle <- base_changeset(@types),
         fill_and_outline <- validate_fill_and_outline(rectangle, params),
         dimensions <- validate_dimensions(rectangle, params, canvas) do
      fill_and_outline
      |> merge(dimensions)
      |> validate_required(@required)
    end
  end

  defp base_changeset(types) do
    {%__MODULE__{}, types}
    |> cast(%{}, [])
  end

  defp validate_fill_and_outline(changeset, params) do
    fill = Map.get(params, :fill)
    outline = Map.get(params, :outline)

    both_missing? = is_nil(fill) and is_nil(outline)

    cast_fields =
      cond do
        both_missing? -> [:fill, :outline]
        is_nil(fill) -> [:outline]
        is_nil(outline) -> [:fill]
        true -> [:fill, :outline]
      end

    changeset
    |> cast(params, cast_fields)
    |> add_error_if(both_missing?, :fill, "either fill or outline must be set")
    |> add_error_if(both_missing?, :outline, "either fill or outline must be set")
    |> maybe_validate(:fill, &Validations.validate_character/2)
    |> maybe_validate(:outline, &Validations.validate_character/2)
  end

  defp validate_dimensions(changeset, params, canvas) do
    changeset
    |> cast(params, [:x, :y, :width, :height])
    |> Validations.validate_coordinates(:x, canvas_axis: {:x, canvas})
    |> Validations.validate_coordinates(:y, canvas_axis: {:y, canvas})
    |> validate_fits_on_canvas(canvas)
  end

  defp maybe_validate(%Ecto.Changeset{changes: changes} = changeset, key, validator) do
    case Map.get(changes, key, nil) do
      nil -> changeset
      _change -> apply(validator, [changeset, key])
    end
  end

  defp validate_fits_on_canvas(
         %Ecto.Changeset{changes: %{x: x, y: y, width: width, height: height}} = changeset,
         %Canvas{} = canvas
       ) do
    msg = "must fit on the canvas"

    changeset
    |> add_error_if(x + width > canvas.width, :width, msg)
    |> add_error_if(y + height > canvas.height, :height, msg)
  end

  defp add_error_if(changeset, true, key, error), do: add_error(changeset, key, error)
  defp add_error_if(changeset, false, _, _), do: changeset

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
