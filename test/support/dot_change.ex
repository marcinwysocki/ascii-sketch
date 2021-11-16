defmodule AsciiSketch.Test.Support.Dot do
  @moduledoc """
  A simple implementation of a change for testing purposes
  """
  defstruct [:x, :y, :character]

  defimpl AsciiSketch.Canvas.Change do
    def apply(
          %{x: column, y: row, character: character},
          lines
        ) do
      updated_row =
        lines
        |> Enum.fetch!(row)
        |> List.replace_at(column, character)
        |> List.to_charlist()

      List.replace_at(lines, row, updated_row)
    end
  end
end
